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

%% Solve the non-linear Poisson problem using Newton's algorithm.
%%
%% [V, n, p, res, niter] = secs1d_nlpoisson_newton_noscale ...
%%                           (device, material, constants, algorithm, ...
%%                            Vin, nin, pin, Fnin, Fpin)
%%
%%     input:  
%%             device.x          spatial grid
%%             device.sinodes    index of the nodes of the grid which are in the semiconductor subdomain
%%                               (remaining nodes are assumed to be in the oxide subdomain)
%%             device.D          doping profile
%%             algorithm.ptoll   tolerance for convergence test
%%             algorithm.pmaxit  maximum number of Newton iterations
%%             device.ni         intrinsic carrier density
%%             material.esi      oxide relative electric permittivity
%%             material.esio2    oxide relative electric permittivity
%%             constants.q       electron charge
%%             constants.Vth     thermal voltage
%%             Vin               initial guess for the electrostatic potential
%%             nin               initial guess for electron concentration
%%             pin               initial guess for hole concentration
%%             Fnin              initial guess for electron Fermi potential
%%             Fpin              initial guess for hole Fermi potential
%%
%%     output: 
%%             V       electrostatic potential
%%             n       electron concentration
%%             p       hole concentration
%%             res     residual norm at each step
%%             niter   number of Newton iterations

function [V, n, p, res, niter] = ...
      secs1d_nlpoisson_newton_noscale (device, material, 
                                       constants, algorithm, 
                                       Vin, nin, pin, Fnin, Fpin)

  dampit     = 10;
  dampcoeff  = 2;

  sielements = device.sinodes(1:end-1);
  Nnodes     = numel (device.x);
  Nelements  = Nnodes - 1;
  epsilon    = material.esio2 * ones (Nelements, 1);
  epsilon(sielements) = material.esi;
  epsilon   /= constants.q;

  V  = Vin;
  Fn = Fnin;
  Fp = Fpin;
  n  = device.ni .* exp (( V(device.sinodes) - Fn) / constants.Vth);
  p  = device.ni .* exp ((-V(device.sinodes) + Fp) / constants.Vth);

  L  = bim1a_laplacian (device.x, epsilon, 1);
  
  b =  zeros (Nelements, 1); 
  b(sielements) = 1;
  
  a =  zeros (Nnodes, 1);
  a(device.sinodes) = (n + p) / constants.Vth;

  M = bim1a_reaction (device.x, b, a);

  a = zeros (Nnodes,1);    
  a(device.sinodes) = (n - p - device.D);

  N = bim1a_rhs (device.x, b, a);

  A = L + M;
  R = L * V + N; 

  normr(1)   = norm (R(2:end-1), inf);
  normrnew   = normr (1);

  for newtit = 1 : algorithm.pmaxit
    
    dV = zeros (Nnodes, 1);
    dV(2:end-1) = - A(2:end-1, 2:end-1) \ R(2:end-1) ;
  
    tk = 1;
    for dit = 1:dampit
      Vnew   = V + tk * dV;
    
      n  = device.ni .* exp (( Vnew(device.sinodes) - Fn) / constants.Vth);
      p  = device.ni .* exp ((-Vnew(device.sinodes) + Fp) / constants.Vth);

      a  = zeros (Nnodes, 1); 
      a(device.sinodes) = (n + p) / constants.Vth;
      M  = bim1a_reaction (device.x, b, a);
      Anew  = L + M;

      a = zeros (Nnodes,1); 
      a(device.sinodes) = (n - p - device.D);
      N = bim1a_rhs (device.x, b, a);
      Rnew = L * Vnew  + N; 
    
      normrnew = norm (Rnew(2:end-1), inf);
      if (normrnew > normr(newtit))
        tk = tk / dampcoeff;
      else
        A = Anew;
        R = Rnew;
        break
      endif	
      
    endfor

    V               = Vnew;	
    normr(newtit+1) = normrnew;
    reldVnorm       = norm (tk*dV, inf) / norm (V, inf);

    if (reldVnorm <= algorithm.ptoll)
      break
    endif

  endfor

  res   = normr;
  niter = newtit;

endfunction

%!demo
%! constants = secs1d_physical_constants_fun ();
%! material = secs1d_silicon_material_properties_fun (constants);
%! 
%! tbulk= 1.5e-6;
%! tox = 90e-9;
%! L = tbulk + tox;
%! cox = material.esio2/tox;
%! 
%! Nx  = 50;
%! Nel = Nx - 1;
%! 
%! device.x = linspace (0, L, Nx)';
%! device.sinodes = find (device.x <= tbulk);
%! xsi = device.x(device.sinodes);
%! 
%! Nsi = length (device.sinodes);
%! Nox = Nx - Nsi;
%! 
%! NelSi   = Nsi - 1;
%! NelSiO2 = Nox - 1;
%! 
%! Na = 1e22;
%! device.D = - Na * ones (size (xsi));
%! p = Na * ones (size (xsi));
%! device.ni = material.ni*exp(secs1d_bandgap_narrowing_model(Na,0)/constants.Vth); 
%! n = (device.ni^2) ./ p;
%! Fn = Fp = zeros (size (xsi));
%! Vg =-10;
%! Nv = 80;
%!
%! for ii = 1:Nv
%!
%!     Vg = Vg + 0.2;
%!     vvect(ii) = Vg; 
%!     
%!     V = - material.Phims + Vg * ones (size (device.x));
%!     V(device.sinodes) = Fn + constants.Vth * log (n / device.ni);
%!     
%!     % Solution of Nonlinear Poisson equation
%!     
%!     % Algorithm parameters
%!     algorithm.ptoll  = 1e-5;
%!     algorithm.pmaxit = 10;
%!     
%!     [V, n, p, res, niter] = secs1d_nlpoisson_newton_noscale (device, material, constants, ...
%!                                                              algorithm, V, n, p, Fn, Fp);
%! 
%!     
%!     qtot(ii) = constants.q * trapz (xsi, p + device.D - n);
%! 
%!     vvectm = (vvect(2:ii)+vvect(1:ii-1))/2;
%!     C = - diff (qtot) ./ diff (vvect);
%!     plot(vvectm, C)
%!     xlabel('Vg [V]')
%!     ylabel('C [Farad]')
%!     title('C-V curve')
%!
%! endfor

