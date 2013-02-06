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

  V  = Vin;
  n  = nin;
  p  = pin;
  Fn = Fnin;
  Fp = Fpin;
  dx  = diff (device.x);

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
  
  while (t < tmax)
    
    try

      t = tout(++tstep) = min (t + dt, tmax);

      if (tstep <= 2)
        Fn0 = Fn(:,tstep-1);
        Fp0 = Fp(:,tstep-1);
      else
        Fn0 = Fn(:, tstep-2) .* (tout(tstep-1) - t)/(tout(tstep-1) - tout(tstep-2)) + ...
            Fn(:, tstep-1) .* (t - tout(:, tstep-2))/(tout(:, tstep-1) - tout(:, tstep-2));
        Fp0 = Fp(:, tstep-2) .* (tout(tstep-1) - t)/(tout(tstep-1) - tout(tstep-2)) + ...
            Fp(:, tstep-1) .* (t - tout(:, tstep-2))/(tout(:, tstep-1) - tout(:, tstep-2));
      endif

      Fn0([1 end]) = vbcs{1} (t);
      Fp0([1 end]) = vbcs{2} (t);

      Fn(:, tstep) = Fn0;
      Fp(:, tstep) = Fp0;

      n0 = n(:, tstep) = n(:, tstep - 1);
      p0 = p(:, tstep) = p(:, tstep - 1);
      V0 = V(:, tstep) = Fn0 + constants.Vth * log (n0 ./ device.ni);

      Jn(:,tstep) = Jn(:,tstep - 1);
      Jp(:,tstep) = Jp(:,tstep - 1);

      for it = 1:algorithm.maxit

        [V(:,tstep), n(:,tstep), p(:,tstep)] = ...
            secs1d_nlpoisson_newton_noscale (device, material, constants, algorithm,
                                             V(:,tstep), n(:,tstep), p(:,tstep), 
                                             Fn(:,tstep), Fp(:,tstep)); 
      
        dV = diff (V(:, tstep));
        E  = - dV ./ dx;

        [Bp, Bm] = bimu_bernoulli (dV);
              
        [Rn, Rp, Gn, Gp, II] = generation_recombination_model ...
            (device, material, constants, algorithm, E, Jn(:,tstep), Jp(:,tstep), 
             V(:,tstep), n(:,tstep), p(:,tstep), Fn(:,tstep), Fp(:,tstep)); 

        [mobilityn, mobilityp] = compute_mobilities ...
            (device, material, constants, algorithm, E, V(:,tstep), 
             n(:,tstep), p(:,tstep), Fn(:,tstep), Fp(:,tstep));

        A = bim1a_advection_diffusion (device.x, mobilityn, 
                                       constants.Vth, 1, V(:,tstep) / constants.Vth);
        A += bim1a_reaction (device.x, 1, Rn + 1/dt);
        R = bim1a_rhs (device.x, 1, Gn + n(:, tstep-1)/dt) + bim1a_rhs (device.x, II, 1);
        
        n(2:end-1,tstep) = A(2:end-1, 2:end-1) \ (R(2:end-1) - A(2:end-1, [1 end]) * n([1 end],tstep));
        Fn(:,tstep) = V(:,tstep) - constants.Vth * log (n(:,tstep) ./ device.ni);
        
        A = bim1a_advection_diffusion (device.x, mobilityp,
                                       constants.Vth, 1, -V(:,tstep)  / constants.Vth);
        A += bim1a_reaction (device.x, 1, Rp + 1/dt);
        R = bim1a_rhs (device.x, 1, Gp + p(:, tstep-1)/dt) + bim1a_rhs (device.x, II, 1);


        p(2:end-1,tstep) = A(2:end-1, 2:end-1) \ (R(2:end-1) - A(2:end-1, [1 end]) * p([1 end], tstep));
        Fp(:,tstep) = V(:,tstep) + constants.Vth * log (p(:,tstep)  ./ device.ni);
                
        [Jn(:,tstep), Jp(:,tstep)] = compute_currents ...
            (device, material, constants, algorithm,
             mobilityn, mobilityp, V(:,tstep), n(:,tstep), p(:,tstep), 
             Fn(:,tstep), Fp(:,tstep));

        nrfn   = norm (Fn(:,tstep) - Fn0, inf);
        assert (nrfn <= algorithm.maxnpincr);

        nrfp   = norm (Fp(:,tstep) - Fp0, inf);
        assert (nrfp <= algorithm.maxnpincr);

        nrv    = norm (V(:,tstep)  - V0,  inf);
        res(it, tstep) = max  ([nrfn; nrfp; nrv]);
        
        if (res(it, tstep) < algorithm.toll)
          break
        endif
        
        V0  =  V(:,tstep);
        p0  =  p(:,tstep) ;
        n0  =  n(:,tstep);
        Fn0 = Fn(:,tstep);
        Fp0 = Fp(:,tstep);  
        
      endfor

      dt *= 1.5;
      numit(tstep) = it;

      figure (1),
      plot (tout, Jn(1,:) + Jp(1,:))
      drawnow

     %% figure (2)
     %% plot (tout, Jn(end,:) + Jp(end,:))
     %% drawnow

    catch

      warning (lasterr)
      dt /= 2;
      t = tout(--tstep);
      
    end_try_catch
    
  endwhile  
  
endfunction

function [Jn, Jp] = compute_currents (device, material, constants, algorithm,
                                      mobilityn, mobilityp, V, n, p, Fn, Fp)
  dV = diff (V);
  dx = diff (device.x);
  [Bp, Bm] = bimu_bernoulli (dV ./ constants.Vth);

  Jn =  constants.q * constants.Vth * mobilityn .* ...
      (n(2:end, end) .* Bp - n(1:end-1, end) .* Bm) ./ dx; 

  Jp = -constants.q * constants.Vth * mobilityp .* ...
      (p(2:end, end) .* Bm - p(1:end-1, end) .* Bp) ./ dx; 

endfunction

%% function u = mobility_model (x, Na, Nd, Nref, E, u0, umin, vsat, beta)
%% 
%%   Neff = Na + Nd;
%%   Neff = (Neff(1:end-1) + Neff(2:end)) / 2;
%%   
%%   ubar = umin + (u0 - umin) ./ (1 + (Neff ./ Nref) .^ beta);
%%   u    = 2 * ubar ./ (1 + sqrt (1 + 4 * (ubar .* abs (E) ./ vsat) .^ 2));
%% 
%% endfunction

function [mobilityn, mobilityp] = compute_mobilities (device, material,
                                                      constants, algorithm, E, 
                                                      V, n, p, Fn, Fp)

  mobilityn = secs1d_mobility_model_noscale (device.x, n, p, device.Na, device.Nd, 
                                             %material.Nrefn, 
                                             E,
                                             %material.u0n, material.uminn, 
                                             %material.vsatn, material.betan
                                             'n');

  mobilityp = secs1d_mobility_model_noscale (device.x, n, p, device.Na, device.Nd, 
                                             %material.Nrefn, 
                                             E,
                                             %material.u0n, material.uminn, 
                                             %material.vsatn, material.betan
                                             'p');

endfunction

function [Rn, Rp, Gn, Gp, II] = generation_recombination_model (device, material,
                                                                constants, algorithm,
                                                                E, Jn, Jp, V, n, p, Fn, Fp)
  
  denomsrh   = material.tn .* (p + device.ni) + material.tp .* (n + device.ni);
  factauger  = material.Cn .* n + material.Cp .* p;
  fact       = (1 ./ denomsrh + factauger);

  Rn = p .* fact;
  Rp = n .* fact;

  Gn = device.ni .^ 2 .* fact;
  Gp = Gn;

  II = material.an * exp(-material.Ecritn./abs(E)) .* abs (Jn / constants.q) + ... 
      material.ap * exp(-material.Ecritp./abs(E)) .* abs (Jp / constants.q);

endfunction


