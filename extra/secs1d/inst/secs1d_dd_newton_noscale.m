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
%% [n, p, V, Fn, Fp, Jn, Jp, it, res] = secs1d_dd_newton_noscale ...
%%    (device, material, constants, algorithm, Vin, nin, pin, Fnin, Fpin) 
%%
%%     input: 
%%            device.x                 spatial grid
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
%%            algorithm.toll           tolerance for Gummel iterarion convergence test
%%            algorithm.maxit          maximum number of Gummel iterarions
%%
%%     output: 
%%       n     electron concentration
%%       p     hole concentration
%%       V     electrostatic potential
%%       Fn    electron Fermi potential
%%       Fp    hole Fermi potential
%%       Jn    electron current density
%%       Jp    hole current density
%%       it    number of Gummel iterations performed
%%       res   total potential increment at each step

function [n, p, V, Fn, Fp, Jn, Jp, it, res] = secs1d_dd_newton_noscale ...  
      (device, material, constants, algorithm, Vin, nin, pin, Fnin, Fpin)

  Nnodes     = numel (device.x);
  V  = Vin; n = nin; p = pin;

  [res, jac] = residual_jacobian (device, material, constants, 
                                  algorithm, V, n, p);

  for it = 1 : algorithm.maxit
	    
    delta = - jac \ res;

    dv = delta(1:Nnodes-2)                * algorithm.colscaling(1);
    dn = delta((Nnodes-2)+(1:Nnodes-2))   * algorithm.colscaling(2);
    dp = delta(2*(Nnodes-2)+(1:Nnodes-2)) * algorithm.colscaling(3);

    ndv = norm (dv, inf);
    ndn = norm (dn, inf);
    ndp = norm (dp, inf);

    tkv = 1;
    if (ndv > algorithm.maxnpincr)
      tkv = algorithm.maxnpincr / ndv;
    endif

    tkn = tkv;
    [howmuch, where] = min (n(2:end-1) + tkn * dn);
    if (howmuch <= 0)
      tkn = - .9 * n(2:end-1)(where) / dn(where)
    endif

    tkp = tkn;
    [howmuch, where] = min (p(2:end-1) + tkp * dp);
    if (howmuch <= 0)
      tkp = - .9 * p(2:end-1)(where) / dp(where)
    endif

    tk = min ([tkv, tkn, tkp])

    V(2:end-1) += tk * dv;
    n(2:end-1) += tk * dn;
    p(2:end-1) += tk * dp;

    [res, jac] = residual_jacobian (device, material, constants, 
                                    algorithm, V, n, p);

    resvec(it) = reldnorm = ...
        ndv / norm (V, inf) + ...
        ndn / norm (n, inf) + ...
        ndp / norm (p, inf);
      
    figure (2)
    semilogy (1:it, resvec)
    drawnow

    figure (3)
    semilogy (device.x, n, device.x, p)
    drawnow
    pause

    if (reldnorm <= algorithm.toll)
      break
    endif

  endfor

  [mobilityn, mobilityp] = compute_mobilities ...
      (device, material, constants, algorithm, V, n, p);

  [Jn, Jp] = compute_currents ...
      (device, material, constants, algorithm, mobilityn, 
       mobilityp, V, n, p);

  Fp = V + constants.Vth * log (p ./ device.ni);
  Fn = V - constants.Vth * log (n ./ device.ni);

  res = resvec;

endfunction


function [Rn, Rp, Gn, Gp, II] = generation_recombination_model ...
      (device, material, constants, algorithm, mobilityn, 
       mobilityp,V, n, p)
  
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
                                         algorithm, V, n, p)

  [mobilityn, mobilityp] = compute_mobilities ...
      (device, material, constants, algorithm, V, n, p);
  
  [Rn, Rp, Gn, Gp, II] = generation_recombination_model ...
      (device, material, constants, algorithm, mobilityn, 
       mobilityp, V, n, p);

  nm         = (n(2:end) + n(1:end-1)) / 2;
  pm         = (p(2:end) + p(1:end-1)) / 2;

  Nnodes     = numel (device.x);
  Nelements  = Nnodes - 1;

  epsilon    = material.esi * ones (Nelements, 1) / constants.q;
  
  A11 = bim1a_laplacian (device.x, epsilon, 1);
  A12 = bim1a_reaction (device.x, 1, 1);
  A13 = - A12;
  R1  = A11 * V + bim1a_rhs (device.x, 1, n - p - device.D);

  A21 = - bim1a_laplacian (device.x, mobilityn .* nm, 1);
  A22 = bim1a_advection_diffusion ...
      (device.x, mobilityn * constants.Vth, 1, 1, V / constants.Vth) + ...
      bim1a_reaction (device.x, 1, Rn);
  A23 = bim1a_reaction (device.x, 1, Rp);
  R2  = A22 * n + bim1a_rhs (device.x, 1, Rn .* n - Gn);

  A31 = bim1a_laplacian (device.x, mobilityp .* pm, 1);
  A32 = bim1a_reaction (device.x, 1, Rn);
  A33 = bim1a_advection_diffusion ...
      (device.x, mobilityp * constants.Vth , 1, 1, - V / constants.Vth) + ...
      bim1a_reaction (device.x, 1, Rp);
  R3  = A33 * p + bim1a_rhs (device.x, 1, Rp .* p - Gp);

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
