function [V, n, p, Fn, Fp, Jn, Jp, Itot, tout] = ...
         secs1d_coupled_circuit_newton_reordered2 (device, material, constants, algorithm, 
                            Vin, nin, pin, tspan, va)  

  tags = {'V', 'n', 'p', 'F'};

  rejected = 0;
  Nnodes = numel (device.x);
  dt = (tspan(2) - tspan(1)) / 1000  
  t(tstep = 1) = tspan (1);
  [V, n, p] = deal (Vin, nin, pin);  
  
  [A, B, C, r, F, contacts] = va (t);
  
  M = bim1a_reaction (device.x, 1, 1);

  while (t < tspan(2))

    reject = false;
    t = tout(++tstep) = min (t + dt, tspan(2)); 
    incr0 = 4 * algorithm.maxnpincr;
    
    [A, B, C, r] = va (t);
    
    [V0, n0, p0, F0] = predict (device, material, constants, ...
                                algorithm, V, n, p, F, tstep, ...
                                tout, A, B, C, r);
    
    [V2, n2, p2, F2] = deal (V0, n0, p0, F0);

    for in = 1 : algorithm.maxit

      [V1, n1, p1, F1] = deal (V2, n2, p2, F2);

      res = compute_residual (device, material, constants, ...
                              algorithm, V2, n2, p2, F2, ...
                              V(:, tstep-1), n(:, tstep-1), p(:, tstep-1), ...
                              F(:, tstep-1), dt, ...
                              A, B, C, r, contacts); 

      jac = compute_jacobian (device, material, constants, ...
                              algorithm, V2, n2, p2, F2, ...
                              dt, A, B, C, r, contacts);

      J = sparse(rows(jac{1, 1}), columns(jac{1, 1}));

      %% figure(99);hold on;
      %% ccc2 = ["o";"*";"+";"d"];
      %% ccc1 = ["b";"r";"g";"k"];
      for iii = 1:4
        for jjj = 1:4
      %%    spy(jac{iii, jjj}, [ccc1(iii), ccc2(jjj)]);
      %%    Legend{jjj+4*iii-4}=["Jac(", num2str(iii), ", ", num2str(jjj), ")"];
          J+=jac{iii, jjj};
        end
      end
      %% legend(Legend, 'Location', 'East')
      %% grid on;
      %% figure(98);
      %% subplot(1, 2, 1);
      %% surf(log10(abs(J)+eps));
      %% view(0, -90);
      %% colorbar;
      %% hold on;

      %% subplot(1, 2, 2);
      %% P=ones(numel(algorithm.colscaling)+1);
      %% P(1:end-1, 1:end-1)=algorithm.colscaling'*(1./algorithm.rowscaling);
      %% surf(log10(P));
      %% view(0, -90);
      %% colorbar;
      %% hold on;
      %% full(J)
      %% 
      %% save jacobian_reordered2.data J res
      %% return
      %% pause

      delta = - J \ res;

      dn = dp = dV = zeros(rows (n), 1);
      dF = zeros (numel(F), 1);

      dV = delta (1:Nnodes)                  * algorithm.colscaling(1);
      dn = delta (Nnodes+1:2*(Nnodes))     * algorithm.colscaling(2);
      dp = delta (2*(Nnodes)+1:3*(Nnodes)) * algorithm.colscaling(3);
      dF = delta (3*(Nnodes)+1:end)          * algorithm.colscaling(4);
      %dV = delta (1:3:3*Nnodes) * algorithm.colscaling(1);
      %dn = delta (2:3:3*Nnodes) * algorithm.colscaling(2);
      %dp = delta (3:3:3*Nnodes) * algorithm.colscaling(3);
      %dF = delta (3*Nnodes+1:end) * algorithm.colscaling(4);

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
        error ('relaxation parameter too small')
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

      incr1v = norm (V2 - V1, inf) / (norm (V0, inf) + algorithm.colscaling(1));
      incr1n = norm (log (n2./n1), inf) / (norm (log (n0), inf) + log (algorithm.colscaling(2)));
      incr1p = norm (log (p2./p1), inf) / (norm (log (p0), inf) + log (algorithm.colscaling(3)));
      incr1F = norm (F2 - F1, inf) / (norm (F0, inf) + algorithm.colscaling(4));

      [incr1, whichone] = max ([incr1v, incr1n, incr1p, incr1F]);
      resnlin(in) = incr1;
      if (in > 3 && resnlin(in) > resnlin(in-3))
        printf (['----------\nnewton is diverging\n', ...
                 'problems on ', tags{whichone}, ...
                 '\n tstep #', num2str(tstep), ...
                 '\n----------\n'])
        reject = true;
        pause
        break;
      endif

      incr0v = norm (V2 - V0, inf) / (norm (V0, inf) + algorithm.colscaling(1));
      incr0n = norm (log (n2./n0), inf) / (norm (log (n0), inf) + log (algorithm.colscaling(2)));
      incr0p = norm (log (p2./p0), inf) / (norm (log (p0), inf) + log (algorithm.colscaling(3)));
      incr0F = norm (F2 - F0, inf) / (norm (F0, inf) + algorithm.colscaling(4));

      [incr0, whichone] = max ([incr0v, incr0n, incr0p, incr0F]);
      
      if (incr0 > algorithm.maxnpincr)
        printf (['----------\nnewton step too large\n',...
                 'problems on ', tags{whichone}, ...
                 '\n','tstep #', num2str(tstep), ...
                 '\n----------\n'])
        pause
        reject = true;
        break;
      endif

      if (incr1 < algorithm.toll)
        printf ('iteration %d, time step %d, model time %g: convergence reached incr = %g\n', in, tstep, t, incr1)
        break;
      endif
      
    endfor %% newton step
    
    if (reject)

      ++rejected;
      t = tout (--tstep);
      dt /= 2;

      printf (['----------\nreducing time step\n', ...
                 'time   ', num2str(t), ' s\n', ...
                 'tstep #', num2str(tstep), '\n', ...
                 'new dt ', num2str(dt), ' s\n', ...
                 '----------\n'])
    else

      Fp(:, tstep) = V2 + constants.Vth * log (p2 ./ device.ni);
      Fn(:, tstep) = V2 - constants.Vth * log (n2 ./ device.ni);        
      [V(:, tstep), n(:, tstep), p(:, tstep), F(:, tstep)] = deal (V2, n2, p2, F2);

      [mobilityn, mobilityp] = compute_mobilities ...
                                 (device, material, constants, algorithm, V2, n2, p2);  

      [Jn(:, tstep), Jp(:, tstep)] = compute_currents ...
                                       (device, material, constants, algorithm, mobilityn, 
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
    
      dt *= .75 * sqrt (algorithm.maxnpincr / incr0)

    endif

  endwhile %% time step
  printf ('total number of rejected time steps: %d\n', rejected)
endfunction

function res_full = compute_residual ...
                 (device, material, constants, ...
                  algorithm, V, n, p, F, ...
                  V0, n0, p0, F0, deltat, ...
                  A, B, C, r, contacts)

  Nnodes    = numel (device.x);
  Nelements = Nnodes - 1;
  Nextvars  = numel(F);
  %%% node ordering
  %% indexing1 = 1:3:3*Nnodes;
  %% indexing2 = 2:3:3*Nnodes;
  %% indexing3 = 3:3:3*Nnodes;
  %%% staggered ordering
  indexing1 = 1:Nnodes;
  indexing2 = (1:Nnodes) + Nnodes;
  indexing3 = (1:Nnodes) + 2 * Nnodes;
  indexing4 = (1:Nextvars) + 3 * Nnodes;
  totN = indexing4(end);
  
  [mobilityn, mobilityp] = compute_mobilities ...
                           (device, material, constants, algorithm, V, n, p);  
  
  [Rn, Rp, Gn, Gp, II] = generation_recombination_model ...
                           (device, material, constants, algorithm, ...
                            mobilityn, mobilityp, V, n, p);
  
  epsilon = material.esi * ones (Nelements, 1);
  
  A11 = bim1a_laplacian (device.x, epsilon, 1);
  res1 = A11 * V + bim1a_rhs (device.x, 1, constants.q * (n - p - device.D));
  res1(1) = A11(1, 1) * (V(1) + constants.Vth*log(p(1)./device.ni(1))-F(contacts(1)));
  res1(end) = A11(end, end) * (V(end)+constants.Vth*log(p(end)./device.ni(end))-F(contacts(2)));

  A22 = bim1a_advection_diffusion ...
          (device.x, mobilityn * constants.Vth, 1, 1, V / constants.Vth);
  res2 = A22 * n + bim1a_rhs (device.x, 1, (Rn  + 1/deltat) .* n - (Gn + n0 * 1/ deltat));
  res2([1, end]) = (n([1, end]) - n0([1, end])).*([A22(1, 1); A22(end, end)]);

  A33 = bim1a_advection_diffusion ...
          (device.x, mobilityp * constants.Vth , 1, 1, - V / constants.Vth);
  res3 = A33 * p + bim1a_rhs (device.x, 1, (Rp + 1/deltat) .* p - (Gp + p0 * 1/ deltat));
  res3([1, end]) = (p([1, end]) - p0([1, end])).*([A33(1, 1); A33(end, end)]);

  I1  = - constants.q * (A22(1,:) * n - A33(1,:) * p);
  I2  = - constants.q * (A22(end,:) * n -  A33(end,:) * p);
  
  %% if (columns (V) >= 2)
    I1 += (1/deltat) * constants.e0 * material.esir * ...
          ((V(2) - V(1)) -
           (V0(2) - V0(1))) / ...
          (device.x(2) - device.x(1));
    I2 += (1/deltat) * constants.e0 * material.esir * ...
          ((V(end) - V(end-1)) -
           (V0(end) - V0(end-1))) / ...
          (device.x(end) - device.x(end-1));
  %% endif

  [I1;I2]

  res4 = (A * (F - F0)) / deltat ...
         + B * F ...
         + C ...
         + r * ([I1; I2] * device.W);

%%   Jn = -constants.q * A22([1, end], :) * n;
%%   Jp =  constants.q * A33([1, end], :) * p;
%%   
%%   Jd = ((constants.e0 * material.esir) / deltat) * ...
%%        ((V([1, end-1]) - V([2, end])) - ...
%%         (V0([1, end-1]) - V0([2, end]))) ./ ...
%%        (device.x([1, end-1]) - device.x([2, end]));
%%        %(device.x([2, end]) - device.x([1, end-1]));
%%   
%%   Jtot = Jn + Jp + Jd
%% 
%%   circuit_scaling = eye(size(A));% sparse(diag(1 ./ max(abs(A / deltat + B), [], 2)));
%%   res4 = ((A * (F - F0)) / deltat ...
%%          + B * F ...
%%          + C); ...
%%          %+ r * Jtot(:) * device.W);
%%   res4(contacts) += [1; 0] .* Jtot * device.W;
%% 
%%   res4 = circuit_scaling * res4;

  res_full = zeros(totN, 1);
  res_full(indexing1) = res1 / algorithm.rowscaling(1);
  res_full(indexing2) = res2 / algorithm.rowscaling(2);
  res_full(indexing3) = res3 / algorithm.rowscaling(3);
  res_full(indexing4) = res4 / algorithm.rowscaling(4);

endfunction

function Jacob = compute_jacobian ...
                 (device, material, constants, ...
                  algorithm, V, n, p, F, ...
                  %V0, n0, p0, F0, ...
                  deltat, A, B, C, r, contacts)

  Nnodes    = numel (device.x);
  Nelements = Nnodes - 1;
  Nextvars  = numel(F);
  [mobilityn, mobilityp] = compute_mobilities ...
                             (device, material, constants, algorithm, V, n, p);
  
  [Rn, Rp, Gn, Gp, II] = generation_recombination_model ...
                           (device, material, constants, algorithm, ...
                            mobilityn, mobilityp, V, n, p);

  nm         = 2./(1./n(2:end) + 1./n(1:end-1));
  pm         = 2./(1./p(2:end) + 1./p(1:end-1));

  epsilon    = material.esi * ones (Nelements, 1);
  
  %%% node ordering
  %% indexing1 = 1:3:3*Nnodes;
  %% indexing2 = 2:3:3*Nnodes;
  %% indexing3 = 3:3:3*Nnodes;
  %%% staggered ordering
  indexing1 = 1:Nnodes;
  indexing2 = (1:Nnodes) + Nnodes;
  indexing3 = (1:Nnodes) + 2 * Nnodes;
  indexing4 = (1:Nextvars) + 3 * Nnodes;
  totN = indexing4(end);

  Cscale = algorithm.colscaling;
  Rscale = algorithm.rowscaling;

  JVV = bim1a_laplacian (device.x, epsilon, 1);
  JVV(1, 2:end) = 0;
  JVV(end, 1:end-1) = 0;
  [iii, jjj, vvv] = find(JVV);
  Jacob{1, 1} = sparse(indexing1(iii), indexing1(jjj), Cscale(1) * vvv / Rscale(1), totN, totN);

  JVn = constants.q * bim1a_reaction (device.x, 1, 1);
  JVn([1, end], :) = 0;
  [iii, jjj, vvv] = find(JVn);
  Jacob{1, 2} = sparse(indexing1(iii), indexing2(jjj), Cscale(2) * vvv / Rscale(1), totN, totN);

  Jacob{1, 3} = sparse(indexing1(iii), indexing3(jjj), -Cscale(3) * vvv / Rscale(1), totN, totN);
  
  Jacob{1, 4} = sparse (indexing1([1, Nnodes]), indexing4(contacts), Cscale(4) * [-JVV(1, 1); -JVV(end, end)] / Rscale(1), totN, totN);
  
  A21 = - bim1a_laplacian (device.x, mobilityn .* nm, 1);
  JnV = A21; JnV([1,end],:) = 0;
  [iii, jjj, vvv] = find(JnV);
  Jacob{2, 1} = sparse(indexing2(iii), indexing1(jjj), Cscale(1) * vvv / Rscale(2), totN, totN);

  A22 = bim1a_advection_diffusion (device.x, mobilityn * constants.Vth, 1, 1, V / constants.Vth);
  
  Jnn = A22 + bim1a_reaction (device.x, 1, Rn + (1 / deltat));
  Jnn(1, 2:end) = 0; Jnn(end, 1:end-1) = 0; 
  [iii, jjj, vvv] = find(Jnn);
  Jacob{2, 2} = sparse(indexing2(iii), indexing2(jjj), Cscale(2) * vvv / Rscale(2), totN, totN);
  
  Jnp = bim1a_reaction (device.x, 1, Rp);
  Jnp([1, end], :) = 0; 
  [iii, jjj, vvv] = find(Jnp);
  Jacob{2, 3} = sparse(indexing2(iii), indexing3(jjj), Cscale(3) * vvv / Rscale(2), totN, totN);
  
  Jacob{2, 4} = sparse (totN, totN);

  A31 = bim1a_laplacian (device.x, mobilityp .* pm, 1);
  JpV = A31; JpV([1,end],:) = 0;
  [iii, jjj, vvv] = find(JpV);
  Jacob{3, 1} = sparse(indexing3(iii), indexing1(jjj), Cscale(1) * vvv / Rscale(3), totN, totN);

  Jpn = bim1a_reaction (device.x, 1, Rn);
  Jpn([1, end], :) = 0;
  [iii, jjj, vvv] = find(Jpn);
  Jacob{3, 2} = sparse(indexing3(iii), indexing2(jjj), Cscale(2) * vvv / Rscale(3), totN, totN);


  A33 = bim1a_advection_diffusion (device.x, mobilityp * constants.Vth , 1, 1, - V / constants.Vth);

  Jpp = A33 + bim1a_reaction (device.x, 1, Rp + (1 / deltat));
  Jpp(1, 2:end) = 0; Jpp(end, 1:end-1) = 0;
  [iii, jjj, vvv] = find(Jpp);
  Jacob{3, 3} = sparse(indexing3(iii), indexing3(jjj), Cscale(3) * vvv / Rscale(3), totN, totN);

  Jacob{3, 4} = sparse (totN, totN);
  
  circuit_scaling = speye(size(A));%sparse(diag(1 ./ max(abs(A / deltat + B), [], 2)));

  dV = V([2, end]) - V([1, end-1]);
  dx =  device.x([2, end]) - device.x([1, end-1]);
  %% %% mUn = mobilityn([1, end]);
  %% %% mUp = mobilityp([1, end]);
  %% %% [Bp, Bm, dBp, dBm] = secs1d_bernoulli (dV ./ constants.Vth);

  dJdV = sparse(numel(contacts), numel(V));
  dJdV(1, [1, 2]) = ((constants.e0 * material.esir) / (deltat * dx(1))) * [-1, 1] * -1;
  %% %% dJdV(1, [1, 2]) += (constants.q / dx(1)) * ...
  %% %%                  ((mUn(1) * n(2) + mUp(1) * p(1)) * dBp(1) - ...
  %% %%                   (mUn(1) * n(1) + mUp(1) * p(2)) * dBm(1)) * [-1, 1] * -1;
  dJdV(2, [end-1, end]) = ((constants.e0 * material.esir) / (deltat * dx(end))) * [-1, 1] * 1;
  %% %% dJdV(2, [end-1, end]) += (constants.q / dx(end)) * ...
  %% %%                        ((mUn(end) * n(end) + mUp(end) * p(end-1)) * dBp(end) - ...
  %% %%                         (mUn(end) * n(end-1) + mUp(end) * p(end)) * dBm(end)) * [-1, 1] * 1;
  %% %% JxV = sparse(circuit_scaling * r * dJdV * device.W);
  JxV = sparse(circuit_scaling * r * device.W * constants.q * ...
        (- A21([1, end], :) + A31([1, end], :)));
  JxV(contacts,:) += dJdV;
  [iii, jjj, vvv] = find(JxV);
  Jacob{4, 1} = sparse(indexing4(iii), indexing1(jjj), Cscale(1) * vvv / Rscale(4), totN, totN);
  
  %% dJdn = sparse(numel(contacts), numel(n));
  %% dJdn(1, [1, 2])       = (mUn(1) * constants.q * constants.Vth / dx(1)) * [-dBm(1), dBp(1)] * -1;
  %% dJdn(2, [end-1, end]) = (mUn(end) * constants.q * constants.Vth / dx(end)) * [-dBm(end), dBp(end)] * 1;
  %% Jxn = sparse (r * device.W * dJdn);
  Jxn = sparse (circuit_scaling * r * device.W * (-constants.q) * A22([1, end], :));
  [iii, jjj, vvv] = find(Jxn);
  Jacob{4, 2} = sparse(indexing4(iii), indexing2(jjj), Cscale(2) * vvv / Rscale(4), totN, totN);
  
  %% dJdp = sparse(numel(contacts), numel(p));
  %% dJdp(1, [1, 2])       = (mUp(1) * constants.q * constants.Vth / dx(1)) * [dBp(1), -dBm(1)] * -1;
  %% dJdp(2, [end-1, end]) = (mUp(end) * constants.q * constants.Vth / dx(end)) * [dBp(end), -dBm(end)] * 1;
  %% Jxp =   sparse (r * device.W * dJdp);
  Jxp = sparse (circuit_scaling * r * device.W * constants.q * A33([1, end], :));
  [iii, jjj, vvv] = find(Jxp);
  Jacob{4, 3} = sparse(indexing4(iii), indexing3(jjj), Cscale(3) * vvv / Rscale(4), totN, totN);
  
  Jxx =   sparse (circuit_scaling * (A / deltat) + B);
  [iii, jjj, vvv] = find(Jxx);
  Jacob{4, 4} = sparse(indexing4(iii), indexing4(jjj), Cscale(4) * vvv / Rscale(4), totN, totN);

endfunction

function [Jn, Jp] = compute_currents (device, material, constants, algorithm, 
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
                                    (device, material, constants, algorithm, V, n, p)

  Fp = V + constants.Vth * log (p ./ device.ni);
  Fn = V - constants.Vth * log (n ./ device.ni);

  E = -diff (V) ./ diff (device.x);

  mobilityn = secs1d_mobility_model_noscale ...
                (device, material, constants, algorithm, E, V, n, p, Fn, Fp, 'n');

  mobilityp = secs1d_mobility_model_noscale ...
                (device, material, constants, algorithm, E, V, n, p, Fn, Fp, 'p');

endfunction

function [Rn, Rp, Gn, Gp, II] = generation_recombination_model ...
                                  (device, material, constants, algorithm, mobilityn, 
                                   mobilityp, V, n, p)
  
  [Rn_srh, Rp_srh, Gn_srh, Gp_srh] = secs1d_srh_recombination_noscale ...
                                       (device, material, constants, algorithm, n, p);

  [Rn_aug, Rp_aug, G_aug] = secs1d_auger_recombination_noscale ...
                              (device, material, constants, algorithm, n, p);
  
  Rn = Rn_srh + Rn_aug;
  Rp = Rp_srh + Rp_aug;
  
  Gp = Gn = Gn_srh + G_aug;

  Fp = V + constants.Vth * log (p ./ device.ni);
  Fn = V - constants.Vth * log (n ./ device.ni);

  E = -diff (V) ./ diff (device.x);

  [Jn, Jp] = compute_currents ...
               (device, material, constants, algorithm, mobilityn, 
                mobilityp, V, n, p);

  II = secs1d_impact_ionization_noscale ...
         (device, material, constants, algorithm, 
          E, Jn, Jp, V, n, p, Fn, Fp);

endfunction

function [V0, n0, p0, F0] = predict (device, material, constants, ...
                                     algorithm, V, n, p, F, tstep, ...
                                     tout, A, B, C, r)

  if (tstep > 2)

    it = [tstep - 2 : tstep - 1];
    t  = tout (it);
    dt = tout (tstep) - tout (tstep - 1);

    Fn(:, 1) = V(:, it(1)) - constants.Vth * log (n(:, it(1)) ./ device.ni);
    Fn(:, 2) = V(:, it(2)) - constants.Vth * log (n(:, it(2)) ./ device.ni);

    dFndt = diff (Fn, 1, 2) ./ diff (tout(it));
    dFdt  = diff (F(:, it(1:2)), 1, 2) ./ diff (tout(it));

    Fn0 = Fn(:, 2) + dFndt * dt;
    F0 = F(:, it(2)) + dFdt * dt;

  else

    Fn0 = V(:, tstep-1) - constants.Vth * log (n(:, tstep-1) ./ device.ni);
    F0  = F(:, tstep-1);

  endif

  n0 = n(:, tstep-1);
  p0 = p(:, tstep-1);

  %%Fn0([1 end]) = va (tout (tstep));

  V0 = Fn0 + constants.Vth * log (n0 ./ device.ni);
  
endfunction
