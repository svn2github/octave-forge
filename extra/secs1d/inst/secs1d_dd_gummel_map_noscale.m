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
%% Solve the unscaled stationary bipolar DD equation system using Gummel algorithm.
%%
%% [n, p, V, Fn, Fp, Jn, Jp, it, res] = ...
%%    secs1d_dd_gummel_map_noscale (device, material,
%%                                  constants, algorithm,
%%                                  Vin, nin, pin, Fnin, Fpin)       
%%
%%     input: 
%%            device.x                 spatial grid
%%            device.{D,Na,Nd}         doping profile
%%            pin                      initial guess for hole concentration
%%            nin                      initial guess for electron concentration
%%            Vin                      initial guess for electrostatic potential
%%            Fnin                     initial guess for electron Fermi potential
%%            Fpin                     initial guess for hole Fermi potential
%%            device.{u0n,uminn,vsatn,Nrefn}
%%                                     electron mobility model coefficients
%%            device.{u0p,uminp,vsatp,Nrefp}
%%                                     hole mobility model coefficients
%%            device.ni                intrinsic carrier density
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

function [n, p, V, Fn, Fp, Jn, Jp, it, res] = ...
      secs1d_dd_gummel_map_noscale (device, material,
                                    constants, algorithm,
                                    Vin, nin, pin, Fnin, Fpin)         

  p  = pin;
  n  = nin;
  V  = Vin;
  Fp = Fpin;
  Fn = Fnin;

  dx = diff (device.x);

  Nnodes = numel (device.x);
  Nelements = Nnodes -1;

  Jn = zeros (Nelements, 1);
  Jp = zeros (Nelements, 1);

  for it = 1 : algorithm.maxit
    
    [V(:,2), n(:,2), p(:,2)] = secs1d_nlpoisson_newton_noscale ...
        (device, material, constants, algorithm,
         V(:,1), n(:,1), p(:,1), Fn(:,1), Fp(:,1)); 
  
    dV = diff (V(:, 2));
    E  = -dV ./ dx;
    
    [Rn, Rp, Gn, Gp, II] = generation_recombination_model ...
        (device, material, constants, algorithm,
         E, Jn, Jp, V(:,2), n(:,2), p(:,2), Fn(:,1), Fp(:,1)); 
    
    [mobilityn, mobilityp] = compute_mobilities ...
        (device, material, constants, algorithm, E, 
         V(:,2), n(:,2), p(:,2), Fn(:,1), Fp(:,1));

    A = bim1a_advection_diffusion (device.x, mobilityn, 
                                   constants.Vth, 1, V(:, 2) / constants.Vth);
    A += bim1a_reaction (device.x, 1, Rn);
    R = bim1a_rhs (device.x, 1, Gn) + bim1a_rhs (device.x, II, 1);
  
    n(:,3) = nin;
    n(2:end-1,3) = A(2:end-1, 2:end-1) \ ...
        (R(2:end-1) - A(2:end-1, [1 end]) * nin ([1 end]));
    Fn(:,2) = V(:,2) - constants.Vth * log (n(:, 3) ./ device.ni);

    A = bim1a_advection_diffusion (device.x, mobilityp,
                                   constants.Vth, 1, -V(:, 2)  / constants.Vth);
    A += bim1a_reaction (device.x, 1, Rp);
    R = bim1a_rhs (device.x, 1, Gp) + bim1a_rhs (device.x, II, 1);

  
    p(:,3) = pin;
    p(2:end-1,3) = A(2:end-1, 2:end-1) \ ...
        (R(2:end-1) - A(2:end-1, [1 end]) * pin ([1 end]));
    Fp(:,2) = V(:,2) + constants.Vth * log (p(:,3) ./ device.ni);

    [Jn, Jp] = compute_currents ...
        (device, material, constants, algorithm,
         mobilityn, mobilityp, V(:,2), n(:,3), p(:,3), 
         Fn(:,2), Fp(:,2));
    
    nrfn   = norm (Fn(:,2) - Fn(:,1), inf);
    nrfp   = norm (Fp(:,2) - Fp(:,1), inf);
    nrv    = norm (V(:,2)  - V(:,1),  inf);
    res(it) = max  ([nrfn; nrfp; nrv]);

    if (res(it) < algorithm.toll)
      break
    endif
    
    V(:,1)  = V(:,end);
    p(:,1)  = p(:,end) ;
    n(:,1)  = n(:,end);
    Fn(:,1) = Fn(:,end);
    Fp(:,1) = Fp(:,end);  
    
  endfor

  n  = n(:,end);
  p  = p(:,end);
  V  = V(:,end);
  Fn = Fn(:,end);
  Fp = Fp(:,end);
  
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

  II =  secs1d_impact_ionization_noscale ...
      (device, material, constants, algorithm, 
       E, Jn, Jp, V, n, p, Fn, Fp);
  
endfunction



%!demo
%! % physical constants and parameters
%! constants = secs1d_physical_constants_fun ();
%! material = secs1d_silicon_material_properties_fun (constants);
%! 
%! % geometry
%! L  = 10e-6;          % [m] 
%! xm = L/2;
%! 
%! Nelements = 1000;
%! device.x       = linspace (0, L, Nelements+1)';
%! device.sinodes = [1:length(device.x)];
%! 
%! % doping profile [m^{-3}]
%! device.Na = 1e23 * (device.x <= xm);
%! device.Nd = 1e23 * (device.x > xm);
%! 
%! % avoid zero doping
%! device.D  = device.Nd - device.Na;  
%!  
%! % initial guess for n, p, V, phin, phip
%! V_p = -1;
%! V_n =  0;
%! 
%! Fp = V_p * (device.x <= xm);
%! Fn = Fp;
%! 
%! p = abs (device.D) / 2 .* (1 + sqrt (1 + 4 * (device.ni./abs(device.D)) .^2)) .* (device.x <= xm) + ...
%!     device.ni^2 ./ (abs (device.D) / 2 .* (1 + sqrt (1 + 4 * (device.ni ./ abs (device.D)) .^2))) .* (device.x > xm);
%! 
%! n = abs (device.D) / 2 .* (1 + sqrt (1 + 4 * (device.ni ./ abs (device.D)) .^ 2)) .* (device.x > xm) + ...
%!     device.ni ^ 2 ./ (abs (device.D) / 2 .* (1 + sqrt (1 + 4 * (device.ni ./ abs (device.D)) .^2))) .* (device.x <= xm);
%! 
%! V = Fn + constants.Vth * log (n ./ device.ni);
%! 
%! % tolerances for convergence checks
%! algorithm.toll  = 1e-3;
%! algorithm.maxit = 1000;
%! algorithm.ptoll = 1e-12;
%! algorithm.pmaxit = 1000;
%! 
%! % solve the problem using the full DD model
%! [n, p, V, Fn, Fp, Jn, Jp, it, res] = ...
%!       secs1d_dd_gummel_map_noscale (device, material,
%!                                     constants, algorithm,
%!                                     V, n, p, Fn, Fp);  
%! 
%! % band structure
%! Efn  = -Fn;
%! Efp  = -Fp;
%! Ec   = Vth*log(Nc./n)+Efn;
%! Ev   = -Vth*log(Nv./p)+Efp;
%! 
%! plot (x, Efn, x, Efp, x, Ec, x, Ev)
%! legend ('Efn', 'Efp', 'Ec', 'Ev')
%! axis tight
