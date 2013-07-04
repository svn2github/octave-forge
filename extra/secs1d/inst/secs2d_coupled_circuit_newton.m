function [V, n, p, Fn, Fp, Jn, Jp, Itot, tout] = ...
         secs2d_coupled_circuit_newton ...
           (device, material, constants, algorithm, 
            Vin, nin, pin, tspan, va)    
  
  tags = {'V', 'n', 'p', 'F'};
  rejected = 0;
  nnodes = columns (device.mesh.p);

  dt = (tspan(2) - tspan(1)) / 1000;
  t(tstep = 1) = tspan (1);

  [V, n, p] = deal (Vin, nin, pin);  
  
  [A, B, C, r, F, pins] = va (t);
  Nextvars  = numel(F);
  inodes = 1:nnodes;
  for iii = 1 : numel (pins);
    dnodes{iii} = bim2c_unknowns_on_side (msh, device.contacts{iii});
    if isempty(dnodes{iii});
      error("Error: circuit pin \#%d is not connected to the device. Check mesh boundary labeling.", iii)
    endif
    inodes = setdiff (inodes, dnodes{iii});
  endfor



  %%% node ordering
  indexing.V = 1:3:3*nnodes;
  indexing.n = 2:3:3*nnodes;
  indexing.p = 3:3:3*nnodes;
  %%% staggered ordering
  %% indexing.V = 1:nnodes;
  %% indexing.n = (1:nnodes) + nnodes;
  %% indexing.p = (1:nnodes) + 2 * nnodes;
  indexing.ext = (1:Nextvars) + 3 * nnodes;
  
  M = bim1a_reaction (device.x, 1, 1);

  while (t < tspan(2))

    reject = false;
    t = tout(++tstep) = min (t + dt, tspan(2)); 
    incr0 = 4 * algorithm.maxnpincr;
    
    [A, B, C, r] = va (t);
    
    [V0, n0, p0, F0] = predict (device, material, constants, 
                                algorithm, V, n, p, F, tstep,
                                tout, A, B, C, r);
    
    [V2, n2, p2, F2] = deal (V0, n0, p0, F0);

    for in = 1 : algorithm.maxit

      [V1, n1, p1, F1] = deal (V2, n2, p2, F2);

      res = compute_residual (device, material, constants, 
                              algorithm, V2, n2, p2, F2, 
                              V(:, tstep-1), n(:, tstep-1),
                              p(:, tstep-1), F(:, tstep-1), 
                              dt, A, B, C, r, pins, indexing); 

      jac = compute_jacobian (device, material, constants, 
                              algorithm, V2, n2, p2, F2, 
                              dt, A, B, C, r, pins, indexing);

      J = sparse(rows(jac{1, 1}), columns(jac{1, 1}));

      for iii = 1:4
        for jjj = 1:4
          J += jac{iii, jjj};
        end
      end

      delta = - J \ res;

      dn = dp = dV = zeros(rows (n), 1);
      dF = zeros (numel(F), 1);

      dV = delta (indexing.V) * algorithm.colscaling(1);
      dn = delta (indexing.n) * algorithm.colscaling(2);
      dp = delta (indexing.p) * algorithm.colscaling(3);
      dF = delta (indexing.ext) * algorithm.colscaling(4);

      tkv = 1; 
      tkn = 1;
      where = (n1 + dn <= 0);
      if (any (where))
        tkn = .9 * min (n1 ./ abs (dn))
      endif

      tkp = 1;
      where = (p1 + dp <= 0);
      if (any (where))       
        tkp = .9 * min (p1 ./ abs (dp))
      endif

      tk = min ([tkv, tkn, tkp]);
      if (tk <= 0)
        error ("relaxation parameter too small, die!")
      endif
      V2 += tk * dV;
      n2 += tk * dn;
      p2 += tk * dp;
      F2 += tk * dF;

      if (any (n2 <= 0) || any (p2 <= 0))
        error ('negative charge density')
        reject = true; 
        break;
      endif


      incr0v = norm (V2 - V0, inf) / ...
               (norm (V0, inf) + algorithm.colscaling(1));
      incr0n = norm (log (n2./n0), inf) / ...
               (norm (log (n0), inf) + log (algorithm.colscaling(2)));
      incr0p = norm (log (p2./p0), inf) / ...
               (norm (log (p0), inf) + log (algorithm.colscaling(3)));
      incr0F = norm (F2(pins) - F0(pins), inf) / ...
               (norm (F0(pins), inf) + algorithm.colscaling(4));

      [incr0, whichone] = max ([incr0v, incr0n, incr0p, incr0F]);
      if (incr0 > algorithm.maxnpincr)
        printf ("at time step %d, fixed point iteration %d, the ", tstep, in);
        printf ("increment in %s has grown too large\n", tags{whichone});
        reject = true;
        break;
      endif
      
      incr1v = norm (V2 - V1, inf) / ...
               (norm (V0, inf) + algorithm.colscaling(1));
      
      incr1n = norm (log (n2./n1), inf) / ...
               (norm (log (n0), inf) + log (algorithm.colscaling(2)));
      
      incr1p = norm (log (p2./p1), inf) / ...
               (norm (log (p0), inf) + log (algorithm.colscaling(3)));

      incr1F = norm (F2(pins) - F1(pins), inf) / ...
               (norm (F0(pins), inf) + algorithm.colscaling(4));
      
      [incr1, whichone] = max ([incr1v, incr1n, incr1p, incr1F]);
      resnlin(in) = incr1;
      if (in > 3 && resnlin(in) > resnlin(in-3))
        printf ("at time step %d, fixed point iteration %d, ", tstep, in);
        printf ("the Newton algorithm is diverging: ");
        printf ("the increment in %s is not decreasing\n", tags{whichone});
        reject = true;
        break;
      endif

      figure (1)
      semilogy (1:in, resnlin(1:in),'bo-');
      xlim([1,15]);
      ylim([5e-9,5e-2]);
      drawnow        

      if (incr1 < algorithm.toll)
        printf ("fixed point iteration %d, time step %d, ", in, tstep);
        printf ("model time %g: convergence reached incr = %g ", t, incr1);
        break;
      endif

    endfor %% newton step
    
    if (reject)

      ++rejected;
      t = tout (--tstep);
      dt /= 2;

      printf ("reducing time step\n");
      printf ("\ttime step #%d, ", tstep);
      printf ("model time %g s\n", t);
      printf ("\tnew dt %g s\n", dt);

    else

      Fp(:, tstep) = V2 + constants.Vth * log (p2 ./ device.ni);
      Fn(:, tstep) = V2 - constants.Vth * log (n2 ./ device.ni);        
      [V(:, tstep), n(:, tstep), p(:, tstep), F(:, tstep)] = ...
      deal (V2, n2, p2, F2);

      [mobilityn, mobilityp] = compute_mobilities ...
                                 (device, material, constants, 
                                  algorithm, V2, n2, p2);  

      [Jn(:, tstep), Jp(:, tstep)] = compute_currents ...
                                       (device, material, constants, 
                                        algorithm, mobilityn, 
                                        mobilityp, V2, n2, p2);

      Itot(:, tstep)  = Jn([1 end], tstep) + Jp([1 end], tstep);

      Itot(1, tstep) += (1/dt) * constants.e0 * material.esir * ...
                        ((V(2, tstep) - V(1, tstep)) -
                         (V(2, tstep-1) - V(1, tstep-1))) / ...
                        (device.x(2) - device.x(1));

      Itot(2, tstep) += (1/dt) * constants.e0 * material.esir * ...
                        ((V(end, tstep) - V(end-1, tstep)) -
                         (V(end, tstep-1) - V(end-1, tstep-1))) / ...
                        (device.x(end) - device.x(end-1));
      
      Itot(:, tstep) *= device.W;


      figure (2)
      plotyy (tout, Itot(2, :), tout, Fn(end, :)- Fn(1, :));
      drawnow
    
      dt *= .8 * sqrt (algorithm.maxnpincr / incr0);
      printf (" estimate for next time step size: dt = %g \n", dt);
    endif

  endwhile %% time step

  printf ('total number of rejected time steps: %d\n', rejected);

endfunction

function res_full = compute_residual ...
                      (device, material, constants, 
                       algorithm, V, n, p, F, 
                       V0, n0, p0, F0, deltat, 
                       A, B, C, r, pins, indexing)

  nnodes    = numel (device.x);
  Nelements = nnodes - 1;
  Nextvars  = numel(F);

  indexing1 = indexing.V;
  indexing2 = indexing.n; 
  indexing3 = indexing.p;
  indexing4 = indexing.ext; 
  totN = indexing4(end);
  
  [mobilityn, mobilityp] = compute_mobilities ...
                           (device, material, constants, 
                            algorithm, V, n, p);  
  
  [Rn, Rp, Gn, Gp, II] = generation_recombination_model ...
                           (device, material, constants, 
                            algorithm, mobilityn, mobilityp, 
                            V, n, p);
  
  epsilon = material.esi * ones (Nelements, 1);
  
  A11 = bim1a_laplacian (device.x, epsilon, 1);

  res1  = A11 * V;
  res1 += bim1a_rhs (device.x, 1, constants.q * (n - p - device.D));
  res1(1)   = A11(1, 1) * (V(1) + constants.Vth *
                                  log (p(1) ./ device.ni(1)) - 
                           F(pins(1)));
  res1(end) = A11(end, end) * (V(end) + constants.Vth *
                                        log (p(end) ./ device.ni(end)) -
                               F(pins(2)));

  A22 = bim1a_advection_diffusion ...
          (device.x, mobilityn * constants.Vth, 
           1, 1, V / constants.Vth);
  res2 = A22 * n;
  res2 += bim1a_rhs (device.x, 1, 
                     (Rn  + 1/deltat) .* n - (Gn + n0 * 1/ deltat));
  res2([1, end]) = (n([1, end]) - n0([1, end])) .* ...
                   ([A22(1, 1); A22(end, end)]);

  A33 = bim1a_advection_diffusion ...
          (device.x, mobilityp * constants.Vth , 
           1, 1, - V / constants.Vth);
  res3  = A33 * p;
  res3 += bim1a_rhs (device.x, 1, (Rp + 1/deltat) .* p - 
                                  (Gp + p0 * 1/ deltat));
  res3([1, end]) = (p([1, end]) - p0([1, end])) .* ...
                   ([A33(1, 1); A33(end, end)]);

  Jn = -constants.q * A22([1, end], :) * n;
  Jp =  constants.q * A33([1, end], :) * p;
  Jd = A11([1, end], :) * ((V-V0) / deltat);

  Jtot = Jn + Jp + Jd;

  circuit_scaling = eye(size(A));
  res4 = ((A * (F - F0)) / deltat ...
         + B * F ...
         + C ...
         + r * Jtot(:) * device.W);
  res4 = circuit_scaling * res4;

  res_full = zeros(totN, 1);
  res_full(indexing1) = res1 / algorithm.rowscaling(1);
  res_full(indexing2) = res2 / algorithm.rowscaling(2);
  res_full(indexing3) = res3 / algorithm.rowscaling(3);
  res_full(indexing4) = res4 / algorithm.rowscaling(4);

endfunction

function Jacob = compute_jacobian ...
                 (device, material, constants, 
                  algorithm, V, n, p, F, 
                  deltat, A, B, C, r, pins, indexing)

  nnodes    = numel (device.x);
  Nelements = nnodes - 1;
  Nextvars  = numel(F);
  [mobilityn, mobilityp] = ...
  compute_mobilities (device, material, constants, algorithm, V, n, p);
  
  [Rn, Rp, Gn, Gp, II] = ...
  generation_recombination_model (device, material, constants, algorithm, 
                                  mobilityn, mobilityp, V, n, p);

  nm         = 2 ./ (1 ./ n(2:end) + 1 ./ n(1:end-1));
  pm         = 2 ./ (1 ./ p(2:end) + 1 ./ p(1:end-1));

  epsilon    = material.esi * ones (Nelements, 1);
  
  indexing1 = indexing.V;
  indexing2 = indexing.n; 
  indexing3 = indexing.p;
  indexing4 = indexing.ext; 
  totN = indexing4(end);

  Cscale = algorithm.colscaling;
  Rscale = algorithm.rowscaling;

  A11 = bim1a_laplacian (device.x, epsilon, 1);
  JVV = A11;
  JVV(1, 2:end) = 0;
  JVV(end, 1:end-1) = 0;
  [iii, jjj, vvv] = find (JVV);
  Jacob{1, 1} = sparse(indexing1(iii), indexing1(jjj), 
                       Cscale(1) * vvv / Rscale(1), totN, totN);

  JVn = constants.q * bim1a_reaction (device.x, 1, 1);
  JVn([1, end], :) = 0;
  [iii, jjj, vvv] = find (JVn);
  Jacob{1, 2} = sparse(indexing1(iii), indexing2(jjj), 
                       Cscale(2) * vvv / Rscale(1), totN, totN);

  Jacob{1, 3} = sparse(indexing1(iii), indexing3(jjj), 
                       -Cscale(3) * vvv / Rscale(1), totN, totN);
  
  Jacob{1, 4} = sparse (indexing1([1, nnodes]), indexing4(pins), 
                        Cscale(4) * [-JVV(1, 1); -JVV(end, end)] / 
                        Rscale(1), totN, totN);
  
  A21 = - bim1a_laplacian (device.x, mobilityn .* nm, 1);
  JnV = A21; JnV([1,end],:) = 0;
  [iii, jjj, vvv] = find (JnV);
  Jacob{2, 1} = sparse(indexing2(iii), indexing1(jjj), 
                       Cscale(1) * vvv / Rscale(2), totN, totN);

  A22 = bim1a_advection_diffusion (device.x, mobilityn * constants.Vth, 
                                   1, 1, V / constants.Vth);
  
  Jnn = A22 + bim1a_reaction (device.x, 1, Rn + (1 / deltat));
  Jnn(1, 2:end) = 0; Jnn(end, 1:end-1) = 0; 
  [iii, jjj, vvv] = find (Jnn);
  Jacob{2, 2} = sparse(indexing2(iii), indexing2(jjj),
                       Cscale(2) * vvv / Rscale(2), totN, totN);
  
  Jnp = bim1a_reaction (device.x, 1, Rp);
  Jnp([1, end], :) = 0; 
  [iii, jjj, vvv] = find (Jnp);
  Jacob{2, 3} = sparse(indexing2(iii), indexing3(jjj), 
                       Cscale(3) * vvv / Rscale(2), totN, totN);
  
  Jacob{2, 4} = sparse (totN, totN);

  A31 = bim1a_laplacian (device.x, mobilityp .* pm, 1);
  JpV = A31; JpV([1,end],:) = 0;
  [iii, jjj, vvv] = find (JpV);
  Jacob{3, 1} = sparse(indexing3(iii), indexing1(jjj), 
                       Cscale(1) * vvv / Rscale(3), totN, totN);

  Jpn = bim1a_reaction (device.x, 1, Rn);
  Jpn([1, end], :) = 0;
  [iii, jjj, vvv] = find (Jpn);
  Jacob{3, 2} = sparse(indexing3(iii), indexing2(jjj), 
                       Cscale(2) * vvv / Rscale(3), totN, totN);


  A33 = bim1a_advection_diffusion (device.x, mobilityp * constants.Vth, 
                                   1, 1, - V / constants.Vth);

  Jpp = A33 + bim1a_reaction (device.x, 1, Rp + (1 / deltat));
  Jpp(1, 2:end) = 0; Jpp(end, 1:end-1) = 0;
  [iii, jjj, vvv] = find (Jpp);
  Jacob{3, 3} = sparse(indexing3(iii), indexing3(jjj), 
                       Cscale(3) * vvv / Rscale(3), totN, totN);

  Jacob{3, 4} = sparse (totN, totN);

  circuit_scaling = eye(size(A));

  JxV = sparse (circuit_scaling * r * device.W * ...
        (A11([1, end], :) + constants.q * (- A21([1, end], :) + A31([1, end], :))));
  [iii, jjj, vvv]  = find (JxV);
  Jacob{4, 1} = sparse(indexing4(iii), indexing1(jjj), 
                       Cscale(1) * vvv / Rscale(4), totN, totN);
  
  Jxn = sparse (circuit_scaling * r * device.W * 
                (-constants.q) * A22([1, end], :));
  [iii, jjj, vvv] = find(Jxn);
  Jacob{4, 2} = sparse(indexing4(iii), indexing2(jjj), 
                       Cscale(2) * vvv / Rscale(4), totN, totN);
  
  Jxp = sparse (circuit_scaling * r * device.W * constants.q * 
                A33([1, end], :));
  [iii, jjj, vvv] = find(Jxp);
  Jacob{4, 3} = sparse(indexing4(iii), indexing3(jjj), 
                       Cscale(3) * vvv / Rscale(4), totN, totN);
  
  Jxx =   sparse (circuit_scaling * (A / deltat) + B);
  [iii, jjj, vvv] = find(Jxx);
  Jacob{4, 4} = sparse(indexing4(iii), indexing4(jjj), 
                       Cscale(4) * vvv / Rscale(4), totN, totN);

endfunction

function [Jn, Jp] = compute_currents ...
                      (device, material, constants, algorithm, 
                       mobilityn, mobilityp, V, n, p, Fn, Fp)
  dV  = diff (V);
  dx = diff (device.x);

  [Bp, Bm] = bimu_bernoulli (dV ./ constants.Vth);

  Jn =  constants.q * constants.Vth * mobilityn .* ...
        (n(2:end) .* Bp - n(1:end-1) .* Bm) ./ dx; 

  Jp = -constants.q * constants.Vth * mobilityp .* ...
        (p(2:end) .* Bm - p(1:end-1) .* Bp) ./ dx; 
  
endfunction

function [mobilityn, mobilityp] = compute_mobilities ...
                                    (device, material, constants, 
                                     algorithm, V, n, p)

  Fp = V + constants.Vth * log (p ./ device.ni);
  Fn = V - constants.Vth * log (n ./ device.ni);

  E = -diff (V) ./ diff (device.x);

  mobilityn = secs1d_mobility_model_noscale ...
                (device, material, constants, algorithm, E, 
                 V, n, p, Fn, Fp, 'n');

  mobilityp = secs1d_mobility_model_noscale ...
                (device, material, constants, algorithm, E, 
                 V, n, p, Fn, Fp, 'p');

endfunction

function [Rn, Rp, Gn, Gp, II] = generation_recombination_model ...
                                  (device, material, constants,
                                   algorithm, mobilityn, mobilityp, 
                                   V, n, p)
  
  [Rn_srh, Rp_srh, Gn_srh, Gp_srh] = secs1d_srh_recombination_noscale ...
                                       (device, material, constants, 
                                        algorithm, n, p);

  [Rn_aug, Rp_aug, G_aug] = secs1d_auger_recombination_noscale ...
                              (device, material, constants, 
                               algorithm, n, p);
  
  Rn = Rn_srh + Rn_aug;
  Rp = Rp_srh + Rp_aug;
  
  Gp = Gn = Gn_srh + G_aug;

  Fp = V + constants.Vth * log (p ./ device.ni);
  Fn = V - constants.Vth * log (n ./ device.ni);

  E = -diff (V) ./ diff (device.x);

  [Jn, Jp] = compute_currents ...
               (device, material, constants, algorithm, 
                mobilityn, mobilityp, V, n, p);

  II = secs1d_impact_ionization_noscale ...
         (device, material, constants, algorithm, 
          E, Jn, Jp, V, n, p, Fn, Fp);

endfunction

function [V0, n0, p0, F0] = predict (device, material, constants, 
                                     algorithm, V, n, p, F, tstep,
                                     tout, A, B, C, r)

  if (tstep > 2)

    it = [tstep - 2 : tstep - 1];
    t  = tout (it);
    dt = tout (tstep) - tout (tstep - 1);

    Fn(:, 1) = V(:, it(1)) - ...
               constants.Vth * ...
               log (n(:, it(1)) ./ device.ni);
    Fn(:, 2) = V(:, it(2)) - ...
               constants.Vth * ...
               log (n(:, it(2)) ./ device.ni);

    dFndt = diff (Fn, 1, 2) ./ diff (tout(it));
    dFdt  = diff (F(:, it(1:2)), 1, 2) ./ diff (tout(it));

    Fn0 = Fn(:, 2) + dFndt * dt;
    F0 = F(:, it(2)) + dFdt * dt;

  else

    Fn0 = V(:, tstep-1) - ...
          constants.Vth * ...
          log (n(:, tstep-1) ./ device.ni);
    F0  = F(:, tstep-1);

  endif

  n0 = n(:, tstep-1);
  p0 = p(:, tstep-1);

  V0 = Fn0 + constants.Vth * ...
             log (n0 ./ device.ni);
  
endfunction
