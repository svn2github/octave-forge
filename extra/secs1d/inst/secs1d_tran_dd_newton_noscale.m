%% Copyright (C) 2004-2013  Carlo de Falco
%%
%% This file is part of 
%% SECS1D - A 1-D Drift--Diffusion Semiconductor Device Simulator
%%
%% SECS1D is free software; you can redistribute it and/or modify
%% it under the terms of the GNU General Public License as published by
%% the Free Software Foundation; either version 3 of the License, or
%% (at your option) any later version.
%%
%% SECS1D is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%% GNU General Public License for more details.
%%
%% You should have received a copy of the GNU General Public License
%% along with SECS1D; If not, see <http://www.gnu.org/licenses/>.

%% Solve the scaled stationary bipolar DD equation system using Newton's method.
%%
%% [n, p, V, Fn, Fp, Jn, Jp, it, res] = secs1d_tran_dd_newton_noscale ...
%%    (device, material, constants, algorithm, Vin, nin, pin, Fnin, Fpin, tspan, vbcs)
%%
%%     input: 
%%            device.x                 spatial grid
%%            tspan = [tmin, tmax]     time integration interval
%%            vbcs = {fhnbc, fpbc}     cell aray of function handles to compute applied potentials as a function of time
%%            device.{D,Na,Nd}         doping profile
%%            Vin                      initial guess for electrostatic potential
%%            nin                      initial guess for electron concentration
%%            pin                      initial guess for hole concentration
%%            Fnin                     initial guess for electron Fermi potential
%%            Fpin                     initial guess for hole Fermi potential
%%            material.{u0n, uminn, vsatn, Nrefn}
%%                                     electron mobility model coefficients
%%            material.{u0p, uminp, vsatp, Nrefp}
%%                                     hole mobility model coefficients
%%            device.ni                intrinsic carrier density
%%            material.{tn,tp,Cn,Cp,an,ap,Ecritnin,Ecritpin}
%%                                     generation recombination model parameters
%%            algorithm.toll           tolerance for Newton iterarion convergence test
%%            algorithm.maxit          maximum number of Newton iterarions
%%
%%     output: 
%%       n     electron concentration
%%       p     hole concentration
%%       V     electrostatic potential
%%       Fn    electron Fermi potential
%%       Fp    hole Fermi potential
%%       Jn    electron current density
%%       Jp    hole current density
%%       it    number of Newton iterations performed
%%       res   total potential increment at each step

function [n, p, V, Fn, Fp, Jn, Jp, tout, numit, res] = ...
      secs1d_tran_dd_newton_noscale (device, material, constants, algorithm,
                                     Vin, nin, pin, Fnin, Fpin, tspan, vbcs)
  
  rejected = 0;

  V  = Vin;  n  = nin;  p  = pin;  Fn = Fnin;  Fp = Fpin;
  Nnodes = numel (device.x);
  Nelements = Nnodes -1;
  
  [mobilityn, mobilityp] = compute_mobilities ...
      (device, material, constants, algorithm, V, n, p);
  
  [Jn, Jp] = compute_currents ...
      (device, material, constants, algorithm, mobilityn, 
       mobilityp, V, n, p);

  tmax = tspan(2);
  tmin = tspan(1);
  dt = (tmax - tmin) / 200; %% initial time step

  tstep = 1;
  t = tout(tstep) = tmin;
  
  resist = 1e7 * 1e-3 ^ 2;

  while (t < tmax)
    
    try

      t = tout(++tstep) = min (t + dt, tmax);

      n0 = n(:, tstep - 1);
      p0 = p(:, tstep - 1);

      if (tstep <= 2)
        Fn0 = Fn(:,tstep-1);
        Fp0 = Fp(:,tstep-1);
      else
        Fn0 = Fn(:, tstep-2) .* (tout(tstep-1) - t)/(tout(tstep-1) - tout(tstep-2)) + ...
            Fn(:, tstep-1) .* (t - tout(:, tstep-2))/(tout(:, tstep-1) - tout(:, tstep-2));
        Fp0 = Fp(:, tstep-2) .* (tout(tstep-1) - t)/(tout(tstep-1) - tout(tstep-2)) + ...
            Fp(:, tstep-1) .* (t - tout(:, tstep-2))/(tout(:, tstep-1) - tout(:, tstep-2));
      endif

      Va = vbcs{1} (t);
      Jn(:,tstep) = Jn(:,tstep-1);
      Jp(:,tstep) = Jp(:,tstep-1);

      Fn0([1 end]) = Va;
      Fp0([1 end]) = Va;

      V0 = Fn0 + constants.Vth * log (n0 ./ device.ni);
      
      nrfnp = 4 * algorithm.maxnpincr; %% initialize so it is not undefined in case of exception

      # [V_gummel, n_gummel, p_gummel, Fn_gummel, ...
      #  Fp_gummel, Jn_gummel, Jp_gummel, Rn, Rp, Gn, Gp, II, mun, mup, ~, ~, nrfnp] =...
      #     __one_gummel_step__ (device, material, constants, algorithm, 
      #                          V0, n0, p0, Fn0, Fp0, Jn(:,tstep), Jp(:,tstep),
      #                          n(:, tstep - 1), p(:, tstep - 1), dt, 1);  



      [V(:,tstep), n(:,tstep), p(:,tstep), Fn(:,tstep), ...
       Fp(:,tstep), Jn(:,tstep), Jp(:,tstep), res_, it, nrfnp] =...
          __one_step__ (device, material, constants, algorithm, 
                        V0, n0, p0, Fn0, Fp0, Jn(:,tstep), Jp(:,tstep),
                        n(:, tstep - 1), p(:, tstep - 1), dt);  
                        
      assert (nrfnp <= algorithm.maxnpincr)

      figure (1)
      plot (tout, (mean (Jn(:, 1:tstep) + Jp(:, 1:tstep), 1)))
      drawnow
      
      res(tstep,1:it) = res_; 
      printf ("dt incremented by %g\n", .5 * sqrt (algorithm.maxnpincr / nrfnp))
      dt *= .5 * sqrt (algorithm.maxnpincr / nrfnp);
      numit(tstep) = it;      
      
    catch
      
      warning (lasterr)
      warning ("algorithm.maxnpincr = %17.17g, nrfnp = %17.17g, dt %17.17g reduced to %17.17g", 
               algorithm.maxnpincr, nrfnp, dt, dt * .5 * sqrt (algorithm.maxnpincr / nrfnp))
      
      dt *=  .5 * sqrt (algorithm.maxnpincr / nrfnp);
      
      t = tout(--tstep);
      if (dt < 100*eps)
        warning ("secs1d_tran_dd_newton_noscale: minimum time step reached.")
      endif
      rejected ++ ;

    end_try_catch
    
  endwhile  
  printf ("number of rejected time steps: %d\n", rejected)

endfunction


function  [V, n, p, Fn, Fp, Jn, Jp, res, it, nrfnp] = ...
      __one_step__ (device, material, constants, algorithm, 
                    V0, n0, p0, Fn0, Fp0, Jn0, Jp0, n_old, p_old, dt);  

  Fnref = Fn = Fn0;
  Fpref = Fp = Fp0;
  n  = n0;
  p  = p0;
  V  = V0;

  Jn = Jn0;
  Jp = Jp0;

  Nnodes     = numel (device.x);

  [res, jac] = residual_jacobian (device, material, constants, 
                                  algorithm, V, n, p, n_old, p_old, 
                                  dt);

  for it = 1 : algorithm.maxit
	    
    delta = - jac \ res;

    dv = delta(1:Nnodes-2)                * algorithm.colscaling(1);
    dn = delta((Nnodes-2)+(1:Nnodes-2))   * algorithm.colscaling(2);
    dp = delta(2*(Nnodes-2)+(1:Nnodes-2)) * algorithm.colscaling(3);
    
    ndv = norm (dv, inf);
    ndn = norm (dn, inf);
    ndp = norm (dp, inf);

    tkv = 1; 
    if (ndv > constants.Vth)
      tkv = constants.Vth / ndv;
    endif

    tkn = tkv;
    [howmuch, where] = min (n(2:end-1) + tkn * dn); 
    if (howmuch <= 0)
      tkn = - .9 * n(2:end-1)(where) / dn(where);
    endif

    tkp = tkn;
    [howmuch, where] = min (p(2:end-1) + tkp * dp); dp(where)
    if (howmuch <= 0)
      tkp = - .9 * p(2:end-1)(where) / dp(where);
    endif

    tk = min ([tkv, tkn, tkp]);
    
    V(2:end-1) += tk * dv;
    n(2:end-1) += tk * dn;
    p(2:end-1) += tk * dp;
 
    [res, jac] = residual_jacobian (device, material, constants, 
                                    algorithm, V, n, p, n_old, 
                                    p_old, % Rn, Rp, Gn, Gp, II, mun, mup, 
                                    dt);

    resvec(it) = reldnorm = ...
        ndv / norm (V, inf) + ...
        ndn / norm (n, inf) + ...
        ndp / norm (p, inf);

    figure (3)
    semilogy (1:it, resvec);
    drawnow

    Fp = V + constants.Vth * log (p ./ device.ni);
    Fn = V - constants.Vth * log (n ./ device.ni);
    nrfnp = max (norm (Fn - Fnref, inf), norm (Fp - Fpref, inf));

    if (reldnorm <= algorithm.toll)
      %|| (it > 5 && nrfnp > algorithm.maxnpincr))
      break
    endif

  endfor

  [mobilityn, mobilityp] = compute_mobilities ...
      (device, material, constants, algorithm, V, n, p);  

  [Jn, Jp] = compute_currents ...
      (device, material, constants, algorithm, mobilityn, 
       mobilityp, V, n, p);

  res = resvec;

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


function [res, jac] = residual_jacobian (device, material, constants, 
                                         algorithm, V, n, p, n0, p0, % Rn, Rp, Gn, Gp, II, mobilityn, mobilityp, 
                                         dt)

  %persistent mobilityn mobilityp Rn Rp Gn Gp II
  [mobilityn, mobilityp] = compute_mobilities ...
      (device, material, constants, algorithm, V, n, p);
    
  [Rn, Rp, Gn, Gp, II] = generation_recombination_model ...
      (device, material, constants, algorithm, mobilityn, 
       mobilityp, V, n, p);

  nm         = 2./(1./n(2:end) + 1./n(1:end-1));
  pm         = 2./(1./p(2:end) + 1./p(1:end-1));

  Nnodes     = numel (device.x);
  Nelements  = Nnodes - 1;

  epsilon    = material.esi * ones (Nelements, 1) / constants.q;
  
  A11 = bim1a_laplacian (device.x, epsilon, 1);
  A12 = bim1a_reaction (device.x, 1, 1);
  A13 = - A12;
  R1  = A11 * V + bim1a_rhs (device.x, 1, n - p - device.D);

  A21 = - bim1a_laplacian (device.x, mobilityn .* nm, 1);
  A22_stiff = bim1a_advection_diffusion ...
      (device.x, mobilityn * constants.Vth, 1, 1, V / constants.Vth);
  A22 = A22_stiff + ...
      bim1a_reaction (device.x, 1, Rn + 1/dt);
  A23 = bim1a_reaction (device.x, 1, Rp);
  R2  = A22_stiff * n + bim1a_rhs (device.x, 1, (Rn  + 1/dt) .* n - (Gn + n0 * 1/ dt));

  A31 = bim1a_laplacian (device.x, mobilityp .* pm, 1);
  A32 = bim1a_reaction (device.x, 1, Rn);
  A33_stiff = bim1a_advection_diffusion ...
      (device.x, mobilityp * constants.Vth , 1, 1, - V / constants.Vth);
  A33 = A33_stiff + ...
      bim1a_reaction (device.x, 1, Rp + 1/dt);
  R3  = A33_stiff * p + bim1a_rhs (device.x, 1, (Rp + 1/dt) .* p - (Gp + p0 * 1/ dt));

  N1 = algorithm.rowscaling(1);
  N2 = algorithm.rowscaling(2);
  N3 = algorithm.rowscaling(3);

  M1 = algorithm.colscaling(1);
  M2 = algorithm.colscaling(2);
  M3 = algorithm.colscaling(3);

  res = [R1(2:end-1)/N1; R2(2:end-1)/N2; R3(2:end-1)/N2];

  jac = [[A11(2:end-1, 2:end-1)*M1, A12(2:end-1, 2:end-1)*M2, A13(2:end-1, 2:end-1)*M3]/N1;
         [A21(2:end-1, 2:end-1)*M1, A22(2:end-1, 2:end-1)*M2, A23(2:end-1, 2:end-1)*M3]/N2;
         [A31(2:end-1, 2:end-1)*M1, A32(2:end-1, 2:end-1)*M2, A33(2:end-1, 2:end-1)*M3]/N3];
  
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


function [V, n, p, Fn, Fp, Jn, Jp, Rn, Rp, Gn, Gp, II, mobilityn, mobilityp, res, it, nrfnp] = __one_gummel_step__ ...
      (device, material, constants, algorithm, V0, n0, p0, Fn0,
       Fp0, Jn0, Jp0, n_old, p_old, dt, NIT); 

  Fnref = Fn = Fn0;
  Fpref = Fp = Fp0;
  n  = n0;
  p  = p0;
  V  = V0;
  Jn = Jn0;
  Jp = Jp0;

  dx = diff (device.x);
  Nnodes = numel (device.x);
  Nelements = Nnodes -1;
  
  for it = 1 : NIT

    [V, n, p] = secs1d_nlpoisson_newton_noscale ...
        (device, material, constants, algorithm, V, n, p, Fn, Fp); 

    [mobilityn, mobilityp] = compute_mobilities ...
        (device, material, constants, algorithm, V, n, p);
  
    [Rn, Rp, Gn, Gp, II] = generation_recombination_model ...
        (device, material, constants, algorithm, mobilityn, 
         mobilityp, V, n, p);
    

    An = bim1a_advection_diffusion (device.x, mobilityn, constants.Vth, 
                                   1, V / constants.Vth);
    An += bim1a_reaction (device.x, 1, Rn + 1/dt);
    R = bim1a_rhs (device.x, 1, Gn + n_old / dt) + ...
        bim1a_rhs (device.x, II, 1);
    
    n(2:end-1) = An(2:end-1, 2:end-1) \ (R(2:end-1) - 
                                        An(2:end-1, [1 end]) * n([1 end]));
    Fn = V - constants.Vth * log (n ./ device.ni);
    
    Ap = bim1a_advection_diffusion (device.x, mobilityp, constants.Vth,
                                   1, -V / constants.Vth);
    Ap += bim1a_reaction (device.x, 1, Rp + 1/dt);
    R = bim1a_rhs (device.x, 1, Gp + p_old / dt) + ...
        bim1a_rhs (device.x, II, 1);
    
    
    p(2:end-1) = Ap(2:end-1, 2:end-1) \ (R(2:end-1) -
                                        Ap(2:end-1, [1 end]) * p([1 end]));
    Fp = V + constants.Vth * log (p ./ device.ni);
    
    [Jn, Jp] = compute_currents ...
        (device, material, constants, algorithm, mobilityn, mobilityp, 
         V, n, p, Fn, Fp);
    
    nrfn   = norm (Fn - Fn0, inf);
    nrfp   = norm (Fp - Fp0, inf);

    nrfnp = max (norm (Fn - Fnref, inf), norm (Fp - Fpref, inf));
    
    nrv    = norm (V  - V0,  inf);
    res(it) = max  ([nrfn; nrfp; nrv]);
    
    if (res(it) < algorithm.toll
        || (nrfnp > algorithm.maxnpincr))
      break;
    endif
    
    V0  =  V;
    p0  =  p ;
    n0  =  n;
    Fn0 = Fn;
    Fp0 = Fp;  
    
  endfor

endfunction
