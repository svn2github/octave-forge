function [V, n, p, Fn, Fp, Jn, Jp, Itot, tout] = ...
         secs3d_coupled_circuit_newton ...
           (device, material, constants, algorithm, 
            Vin, nin, pin, tspan, va)    
  
  tags = {'V', 'n', 'p', 'F'};
  rejected = 0;
  nnodes = columns (device.msh.p);
  Nelements = columns (device.msh.t);
  dt = (tspan(2) - tspan(1)) / 1000;
  tout(tstep = 1) = t = tspan (1);

  [V, n, p] = deal (Vin, nin, pin);  
  
  [A, B, C, r, F, pins] = va (t);
  Nextvars  = numel(F);
  
  inodes = 1:nnodes;
  dnodes = sparse(numel(device.contacts), nnodes);
  for iii = 1 : numel (pins);
    this_dnodes = bim3c_unknowns_on_faces (
                   device.msh, device.contacts(iii));
    if (! sum(this_dnodes));
      error((["circuit pin #%d is not connected",
              " to the device. Check mesh bound"
              "ary labeling."])'(:)', iii)
    endif
    inodes = setdiff (inodes, this_dnodes);
    dnodes(iii, this_dnodes) = 1;
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
  
  while (t < tspan(2))

    reject = false;
    t = tout(++tstep) = min (t + dt, tspan(2)); 
    incr0 = 4 * algorithm.maxnpincr;
    
    [A, B, C, r] = va (t);
    
    [V0, n0, p0, F0] = predict (device, material, constants, 
                                algorithm, V, n, p, F, tstep,
                                tout);
    
    [V2, n2, p2, F2] = deal (V0, n0, p0, F0);

    for in = 1 : algorithm.maxit

      [V1, n1, p1, F1] = deal (V2, n2, p2, F2);

      res = __secs3d_newton_residual__ (device, material, constants, 
                                        algorithm, V2, n2, p2, F2, 
                                        V(:, tstep-1), n(:, tstep-1),
                                        p(:, tstep-1), F(:, tstep-1), 
                                        dt, A, B, C, r, pins,
                                        indexing, dnodes, inodes); 
      
      jac =  __secs3d_newton_jacobian__ (device, material, constants, 
                                         algorithm, V2, n2, p2, F2, 
                                         dt, A, B, C, r, pins,
                                         indexing, dnodes, inodes);

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
        tkn = .9 * min (n1(where) ./ abs (dn(where)));
      endif

      tkp = 1;
      where = (p1 + dp <= 0);
      if (any (where))       
        tkp = .9 * min (p1(where) ./ abs (dp(where)));
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

      [mobilityn, mobilityp] = __secs3d_newton_compute_mobilities__ ...
                                 (device, material, constants, 
                                  algorithm, V2, n2, p2);  

      [Jn(:, tstep), Jp(:, tstep)] = ...
      __secs3d_newton_compute_currents__ ...
        (device, material, constants, algorithm, mobilityn, 
         mobilityp, V2, n2, p2, Fn(:, tstep), Fp(:, tstep));

      A11 = bim3a_osc_laplacian (device.msh, material.esi * ones (Nelements, 1));
      A22 = bim3a_osc_advection_diffusion ...
              (device.msh, mobilityn * constants.Vth, 
               V(:, tstep) / constants.Vth);
      A33 = bim3a_osc_advection_diffusion ...
              (device.msh, mobilityp * constants.Vth , 
               - V(:, tstep) / constants.Vth);
                                        
      for iii = 1 : numel(pins)
          thisdnodes = find(dnodes(iii,:));
          Jn_pins(iii) = sum(-constants.q * A22(thisdnodes,:) * n(:, tstep));
          Jp_pins(iii) = sum(constants.q * A33(thisdnodes, :) * p(:, tstep));
          Jd_pins(iii) = sum(A11(thisdnodes, :) * (V(:, tstep)-V(:, max(tstep-1,0)) / dt));
      endfor
      Itot(:, tstep) = (Jn_pins + Jp_pins + Jd_pins)(:);
      
      figure (2)
      plotyy (tout, Itot(2, :), tout, F(pins(2), :) - F(pins(1), :));
      drawnow
    
      dt *= .8 * sqrt (algorithm.maxnpincr / incr0);
      printf ("\nestimate for next time step size: dt = %g \n", dt);
    endif

  endwhile %% time step

  printf ('total number of rejected time steps: %d\n', rejected);

endfunction


function [V0, n0, p0, F0] = predict (device, material, constants, 
                                     algorithm, V, n, p, F, tstep,
                                     tout)

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
