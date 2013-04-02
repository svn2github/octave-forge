%% Copyright (C) 2004-2012  Carlo de Falco
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

%%
%% Solve the unscaled transient bipolar DD equation system using Gummel algorithm.
%%
%% [n, p, V, Fn, Fp, Jn, Jp, it, res] = ...
%%           secs1d_tran_dd_gummel_map_noscale (device, material, constants, algorithm,
%%                                              Vin, nin, pin, Fnin, Fpin, tspan, vbcs)         
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
%%            device.ni              intrinsic carrier density
%%            material.{tn,tp,Cn,Cp,an,ap,Ecritnin,Ecritpin}
%%                                     generation recombination model parameters
%%            algorithm.toll           tolerance for Gummel iterarion convergence test
%%            algorithm.maxit          maximum number of Gummel iterarions
%%            algorithm.ptoll          convergence test tolerance for the non linear
%%                                     Poisson solver
%%            algorithm.pmaxit         maximum number of Newton iterarions
%%
%%     output: 
%%             n     electron concentration
%%             p     hole concentration
%%             V     electrostatic potential
%%             Fn    electron Fermi potential
%%             Fp    hole Fermi potential
%%             Jn    electron current density
%%             Jp    hole current density
%%             it    number of Gummel iterations performed
%%             res   total potential increment at each step

function [n, p, V, Fn, Fp, Jn, Jp, tout, numit, res] = ...
      secs1d_tran_dd_gummel_map_noscale (device, material, constants, algorithm,
                                         Vin, nin, pin, Fnin, Fpin, tspan, vbcs)

  rejected = 0;

  V  = Vin;
  n  = nin;
  p  = pin;
  Fn = Fnin;
  Fp = Fpin;
  dx = diff (device.x);

  Nnodes = numel (device.x);
  Nelements = Nnodes -1;

  dV = diff (V);
  E  = - dV ./ dx;

  [mobilityn, mobilityp] = compute_mobilities ...
      (device, material, constants, algorithm, 
       E, V, n, p, Fn, Fp);


  [Jn, Jp] = compute_currents ...
      (device, material, constants, algorithm,
       mobilityn, mobilityp, V, n, p, Fn, Fp);

  tmax = tspan(2);
  tmin = tspan(1);
  dt = (tmax - tmin) / 20; %% initial time step

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
      %if (tstep > 2)
      %  dt *= (algorithm.maxnpincr - res(tstep, 1)) / (res(tstep, 1) - res(tstep-1, 1));
      %endif
      printf ("dt incremented by %g\n", .5 * sqrt (algorithm.maxnpincr / nrfnp))
      dt *= .5 * sqrt (algorithm.maxnpincr / nrfnp);
      numit(tstep) = it;      
      
    catch
      
      warning (lasterr)
      warning ("algorithm.maxnpincr = %17.17g, nrfnp = %17.17g, dt reduced by %17.17g", 
               algorithm.maxnpincr, nrfnp, .5 * sqrt (algorithm.maxnpincr / nrfnp))
      dt *=  .5 * sqrt (algorithm.maxnpincr / nrfnp);
      t = tout(--tstep);
      if (dt < 100*eps)
        warning ("secs1d_tran_dd_gummel_map_noscale: minimum time step reached.")
        return
      endif
      rejected ++ ;

    end_try_catch
    
  endwhile  
  printf ("number of rejected time steps: %d\n", rejected)
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

%% FIXME: Velocity saturation and doping dependence are not mutually exclusive, they
%% should be combined using Mathiessen's rule!!

%%function u = mobility_model (x, Na, Nd, Nref, E, u0, umin, vsat, beta)
%%
%%  Neff = Na + Nd;
%%  Neff = (Neff(1:end-1) + Neff(2:end)) / 2;
%%  
%%  ubar = umin + (u0 - umin) ./ (1 + (Neff ./ Nref) .^ beta);
%%  u    = 2 * ubar ./ (1 + sqrt (1 + 4 * (ubar .* abs (E) ./ vsat) .^ 2));
%%
%%endfunction

function [mobilityn, mobilityp] = compute_mobilities ...
      (device, material, constants, algorithm, E, V, n, p, Fn, Fp)

  mobilityn = secs1d_mobility_model_noscale ...
      (device, material, constants, algorithm, E, V, n, p, Fn, Fp, 'n');

  mobilityp = secs1d_mobility_model_noscale ...
      (device, material, constants, algorithm, E, V, n, p, Fn, Fp, 'p');

endfunction

function [Rn, Rp, Gn, Gp, II] = generation_recombination_model ...
      (device, material, constants, algorithm, E, Jn, Jp, V, n, p, Fn, Fp)
  
  [Rn_srh, Rp_srh, Gn_srh, Gp_srh] = secs1d_srh_recombination_noscale ...
      (device, material, constants, algorithm, n, p);

  [Rn_aug, Rp_aug, G_aug] = secs1d_auger_recombination_noscale ...
      (device, material, constants, algorithm, n, p);
 
  Rn = Rn_srh + Rn_aug;
  Rp = Rp_srh + Rp_aug;
  
  Gp = Gn = Gn_srh + G_aug;

  II = secs1d_impact_ionization_noscale ...
      (device, material, constants, algorithm, 
       E, Jn, Jp, V, n, p, Fn, Fp);

endfunction


function [V, n, p, Fn, Fp, Jn, Jp, res, it, nrfnp] = __one_step__ ...
      (device, material, constants, algorithm, V0, n0, p0, Fn0,
       Fp0, Jn0, Jp0, n_old, p_old, dt); 

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
  
  for it = 1 : algorithm.maxit

    [V, n, p] = secs1d_nlpoisson_newton_noscale ...
        (device, material, constants, algorithm, V, n, p, Fn, Fp); 
      
    dV = diff (V);
    E  = - dV ./ dx;

    %% [Bp, Bm] = bimu_bernoulli (dV);
    
    [Rn, Rp, Gn, Gp, II] = generation_recombination_model ...
        (device, material, constants, algorithm, E, Jn, Jp, 
         V, n, p, Fn, Fp);
    
    [mobilityn, mobilityp] = compute_mobilities ...
        (device, material, constants, algorithm, E, V, n, p, Fn, Fp);

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
    
    figure (3)
    semilogy (1:it, res)
    drawnow

    V0  =  V;
    p0  =  p ;
    n0  =  n;
    Fn0 = Fn;
    Fp0 = Fp;  
    
  endfor

endfunction

  %% compute sensitivities
  # sielements = device.sinodes(1:end-1);
  # epsilon = material.esio2 * ones (Nelements, 1);
  # epsilon(sielements) = material.esi;
  
  # Le = bim1a_laplacian (device.x, epsilon / constants.q, 1);
  # M  = bim1a_reaction (device.x, 1, 1);

  # Ann = bim1a_advection_diffusion (device.x, mobilityn, constants.Vth, 
  #                                  1, V / constants.Vth);
  # Ann += bim1a_reaction (device.x, 1, Rn + 1/dt);
  # Anp =  bim1a_reaction (device.x, 1, Rp);

  # Ln =  bim1a_advection_diffusion (device.x, mobilityn, n, 1, 0);

  # App = bim1a_advection_diffusion (device.x, mobilityp, constants.Vth, 
  #                                 1, -V / constants.Vth);
  # App += bim1a_reaction (device.x, 1, Rp + 1/dt);
  # Apn =  bim1a_reaction (device.x, 1, Rn);
  # Lp =  bim1a_advection_diffusion (device.x, mobilityp, p, 1, 0);

  # mat = [ Le(2:end-1,2:end-1),    M(2:end-1,2:end-1),   -M(2:end-1,2:end-1);
  #        -Ln(2:end-1,2:end-1),  Ann(2:end-1,2:end-1),  Anp(2:end-1,2:end-1);
  #         Lp(2:end-1,2:end-1),  Apn(2:end-1,2:end-1),  App(2:end-1,2:end-1)];

  # dphi = zeros (Nnodes, 1);
  # dphi(1) = 1;
  # dn = dp = zeros (Nnodes, 1);

  # rhs = - [Le(2:end-1, 1); Ln(2:end-1, 1); Lp(2:end-1, 1)];
  # x = (mat) \ (rhs);

  # dphi(2:end-1) = x(1 : (Nnodes - 2));
  # dn(2:end-1) = x(Nnodes - 2 + 1 : 2 * (Nnodes - 2));
  # dp(2:end-1) = x(2 * (Nnodes - 2) + 1 : 3 * (Nnodes - 2));

  # djn_dV = constants.q * (Ln(1, :) * dphi + Ann(1, :) * dn + Anp(1, :) * dp);
  # djp_dV = constants.q * (Lp(1, :) * dphi + App(1, :) * dp + Apn(1, :) * dn);

  # dj_dV =  (-djn_dV + djp_dV);


