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
%% Solve the scaled stationary bipolar DD equation system using Gummel algorithm.
%%
%% [n, p, V, Fn, Fp, Jn, Jp, it, res] = secs1d_tran_dd_gummel_map (x, tspan, vbcs, D, Na, Nd, 
%%                                                                 pin, nin, Vin, Fnin, 
%%                                                                 Fpin, l2, er, u0n, 
%%                                                                 uminn, vsatn, betan, 
%%                                                                 Nrefn, u0p, uminp, vsatp, 
%%                                                                 betap, Nrefp, theta, tn, tp, 
%%                                                                 Cn, Cp, an, ap, Ecritnin, Ecritpin, 
%%                                                                 toll, maxit, ptoll, pmaxit)         
%%
%%     input: 
%%            x                        spatial grid
%%            tspan = [tmin, tmax]     time integration interval
%%            vbcs = {fhnbc, fpbc}     cell aray of function handles to compute applied potentials as a function of time
%%            D, Na, Nd                doping profile
%%            pin                      initial guess for hole concentration
%%            nin                      initial guess for electron concentration
%%            Vin                      initial guess for electrostatic potential
%%            Fnin                     initial guess for electron Fermi potential
%%            Fpin                     initial guess for hole Fermi potential
%%            l2                       scaled Debye length squared
%%            er                       relative electric permittivity
%%            u0n, uminn, vsatn, Nrefn electron mobility model coefficients
%%            u0p, uminp, vsatp, Nrefp hole mobility model coefficients
%%            theta                    intrinsic carrier density
%%            tn, tp, Cn, Cp, 
%%            an, ap, 
%%            Ecritnin, Ecritpin       generation recombination model parameters
%%            toll                     tolerance for Gummel iterarion convergence test
%%            maxit                    maximum number of Gummel iterarions
%%            ptoll                    convergence test tolerance for the non linear
%%                                     Poisson solver
%%            pmaxit                   maximum number of Newton iterarions
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

function [n, p, V, Fn, Fp, Jn, Jp, tout, numit, res] = secs1d_tran_dd_gummel_map (x, tspan, vbcs, D, Na, Nd, pin, nin, Vin, 
                                                                                  Fnin, Fpin, l2, er, u0n, uminn,
                                                                                  vsatn, betan, Nrefn, u0p, 
                                                                                  uminp, vsatp, betap, Nrefp,
                                                                                  theta, tn, tp, Cn, Cp, an, ap, 
		                                                                  Ecritnin, Ecritpin, toll, maxit, 
                                                                                  ptoll, pmaxit)

  p  = pin;
  n  = nin;
  V  = Vin;
  Fp = Fpin;
  Fn = Fnin;
  dx  = diff (x);
  dxm = (dx(1:end-1) + dx(2:end));

  Nnodes = numel (x);
  Nelements = Nnodes -1;

  dV = diff (V);
  E  = - dV ./ dx;
  [Bp, Bm] = bimu_bernoulli (dV);

  mobility = mobility_model (x, Na, Nd, Nrefn, E, u0n, uminn, vsatn, betan);
  Jn = mobility .* (n(2:end) .* Bp - n(1:end-1) .* Bm) ./ dx; 

  mobility = mobility_model (x, Na, Nd, Nrefp, E, u0p, uminp, vsatp, betap);
  Jp = -mobility .* (p(2:end) .* Bm - p(1:end-1) .* Bp) ./ dx;

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
      V0 = V(:, tstep) = Fn0 + log (n0);
      Jn(:,tstep) = Jn(:,tstep - 1);
      Jp(:,tstep) = Jp(:,tstep - 1);

      for it = 1:maxit

        [V(:,tstep), n(:,tstep), p(:,tstep)] = secs1d_nlpoisson_newton (x, [1:Nnodes], V(:,tstep), 
                                                                        n(:,tstep), p(:,tstep), 
                                                                        Fn(:,tstep), Fp(:,tstep), 
                                                                        D, l2, er, ptoll, pmaxit); 
      
        dV = diff (V(:, tstep));
        E  = - dV ./ dx;
        [Bp, Bm] = bimu_bernoulli (dV);
              
        [Rn, Rp, Gn, Gp, II] = generation_recombination_model (x, n(:, tstep), p(:, tstep),
	                                                       E, Jn(:,tstep), Jp(:,tstep), tn, tp, theta, 
                                                               Cn, Cp, an, ap, Ecritnin, Ecritpin); 
        
        mobility = mobility_model (x, Na, Nd, Nrefn, E, u0n, uminn, vsatn, betan);
        
        A = bim1a_advection_diffusion (x, mobility, 1, 1, V(:, tstep));
        M = bim1a_reaction (x, 1, Rn + 1/dt);
        R = bim1a_rhs (x, 1, Gn + n(:,tstep-1)/dt) + bim1a_rhs (x, II, 1);
        
        A = A + M;
        
        n(2:end-1,tstep) = A(2:end-1, 2:end-1) \ (R(2:end-1) - A(2:end-1, [1 end]) * n([1 end],tstep));
        Fn(:,tstep) = V(:,tstep) - log (n(:,tstep));
        Jn(:,tstep) =  mobility .* (n(2:end,tstep) .* Bp - n(1:end-1,tstep) .* Bm) ./ dx; 


        [Rn, Rp, Gn, Gp, II] = generation_recombination_model (x, n(:, tstep), p(:, tstep), 
	                                                       E, Jn(:,tstep), Jp(:,tstep), tn, tp, theta, 
                                                               Cn, Cp, an, ap, Ecritnin, Ecritpin);
        
        mobility = mobility_model (x, Na, Nd, Nrefp, E, u0p, uminp, vsatp, betap);
        
        A = bim1a_advection_diffusion (x, mobility, 1, 1, -V(:, tstep));
        M = bim1a_reaction (x, 1, Rp + 1/dt);
        R = bim1a_rhs (x, 1, Gp + p(:,tstep-1)/dt) + bim1a_rhs (x, II, 1);
        A = A + M;
        
        p(2:end-1,tstep) = A(2:end-1, 2:end-1) \ (R(2:end-1) - A(2:end-1, [1 end]) * p([1 end], tstep));
        Fp(:,tstep) = V(:,tstep) + log (p(:,tstep));
        Jp(:,tstep) = -mobility .* (p(2:end,tstep) .* Bm - p(1:end-1,tstep) .* Bp) ./ dx;
                
        nrfn   = norm (Fn(:,tstep) - Fn0, inf);
        assert (nrfn <= 10);

        nrfp   = norm (Fp(:,tstep) - Fp0, inf);
        assert (nrfp <= 10);

        nrv    = norm (V(:,tstep)  - V0,  inf);
        res(it,tstep) = max  ([nrfn; nrfp; nrv]);
        
        if (res(it,tstep) < toll)
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

      figure (2)
      plot (tout, Jn(end,:) + Jp(end,:))
      drawnow

    catch

      warning (lasterr)
      dt /= 2;
      t = tout(--tstep);
      
    end_try_catch

  endwhile  

endfunction

function u = mobility_model (x, Na, Nd, Nref, E, u0, umin, vsat, beta)

  Neff = Na + Nd;
  Neff = (Neff(1:end-1) + Neff(2:end)) / 2;
  
  ubar = umin + (u0 - umin) ./ (1 + (Neff ./ Nref) .^ beta);
  u    = 2 * ubar ./ (1 + sqrt (1 + 4 * (ubar .* abs (E) ./ vsat) .^ 2));

endfunction

function [Rn, Rp, Gn, Gp, II] = generation_recombination_model (x, n, p, E, Jn, Jp, tn, tp, 
                                                                theta, Cn, Cp, an, ap, Ecritn, 
                                                                Ecritp)
  
  denomsrh   = tn .* (p + theta) + tp .* (n + theta);
  factauger  = Cn .* n + Cp .* p;
  fact       = (1 ./ denomsrh + factauger);

  Rn = p .* fact;
  Rp = n .* fact;

  Gn = theta .^ 2 .* fact;
  Gp = Gn;

  II = an * exp(-Ecritn./abs(E)) .* abs (Jn) + ap * exp(-Ecritp./abs(E)) .* abs (Jp);

endfunction

%!function fn = vbcs_1 (t, tbar, n, ni, Vth, vbar, nbar);
%!    fn = [0; 0];
%!    fn(1) = t*tbar/10;
%!    fn(2) = 0;
%!    v  = fn + Vth * log (n / ni);
%!    vv = v / vbar;
%!    nn = n / nbar;
%!    fn = vv - log (nn);
%!endfunction
%!function fp = vbcs_2 (t, tbar, p, ni, Vth, vbar, nbar);
%!    fp = [0; 0];
%!    fp(1) = t*tbar/10;
%!    fp(2) = 0;
%!    v  = fp - Vth * log (p / ni);
%!    vv = v / vbar;
%!    pp = p / nbar;
%!    fp = vv + log (pp);
%!endfunction
%!demo
%!
%!  % physical constants and parameters
%!  secs1d_physical_constants;
%!  secs1d_silicon_material_properties;
%!  
%!  % geometry
%!  L  = 10e-6;          % [m] 
%!  xm = L/2;
%!  
%!  Nelements = 500;
%!  x         = linspace (0, L, Nelements+1)';
%!  sinodes   = [1:length(x)];
%!  
%!  % tolerances for convergence checks
%!  toll  = 1e-4;
%!  maxit = 1000;
%!  ptoll = 1e-12;
%!  pmaxit = 1000;
%!  
%!  % dielectric constant (silicon)
%!  er = esir * ones (Nelements, 1);
%!  
%!  % doping profile [m^{-3}]
%!  Na = 1e23 * (x <= xm);
%!  Nd = 1e23 * (x > xm);
%!  
%!  % avoid zero doping
%!  D  = Nd - Na;  
%!  
%!  % scaling factors
%!  xbar = L;                       %% [m]
%!  nbar = norm(D, 'inf');          %% [m^{-3}]
%!  Vbar = Vth;                     %% [V]
%!  mubar = max (u0n, u0p);         %% [m^2 V^{-1} s^{-1}]
%!  tbar = xbar^2 / (mubar * Vbar); %% [s]
%!  Rbar = nbar / tbar;             %% [m^{-3} s^{-1}]
%!  Ebar = Vbar / xbar;             %% [V m^{-1}]
%!  Jbar = q * mubar * nbar * Ebar; %% [A m^{-2}]
%!  CAubar = Rbar / nbar^3;         %% [m^6 s^{-1}]
%!  abar = 1/xbar;                  %% [m^{-1}]
%!  
%!  % scaling procedure
%!  l2 = e0 * Vbar / (q * nbar * xbar^2);
%!  theta = ni / nbar;
%!  
%!  xin = x / xbar;
%!  Din = D / nbar;
%!  Nain = Na / nbar;
%!  Ndin = Nd / nbar;
%!  
%!  tnin = tn / tbar;
%!  tpin = tp / tbar;
%!  
%!  u0nin = u0n / mubar;
%!  uminnin = uminn / mubar;
%!  vsatnin = vsatn / (mubar * Ebar);
%!  
%!  u0pin = u0p / mubar;
%!  uminpin = uminp / mubar;
%!  vsatpin = vsatp / (mubar * Ebar);
%!  
%!  Nrefnin = Nrefn / nbar;
%!  Nrefpin = Nrefp / nbar;
%!  
%!  Cnin     = Cn / CAubar;
%!  Cpin     = Cp / CAubar;
%!  
%!  anin     = an / abar;
%!  apin     = ap / abar;
%!  Ecritnin = Ecritn / Ebar;
%!  Ecritpin = Ecritp / Ebar;
%!  
%!  tmin = 0;
%!  tmax = 200;
%!  tspan = [tmin, tmax];
%!  
%!  p = abs (D) / 2 .* (1 + sqrt (1 + 4 * (ni./abs(D)) .^2)) .* (x <= xm) + ...
%!      ni^2 ./ (abs (D) / 2 .* (1 + sqrt (1 + 4 * (ni ./ abs (D)) .^2))) .* (x > xm);
%!    
%!  n = abs (D) / 2 .* (1 + sqrt (1 + 4 * (ni ./ abs (D)) .^ 2)) .* (x > xm) + ...
%!      ni ^ 2 ./ (abs (D) / 2 .* (1 + sqrt (1 + 4 * (ni ./ abs (D)) .^2))) .* (x <= xm);
%!  
%!  Fp = 0 * (x <= xm);
%!  Fn = Fp;
%!  
%!  V = Fn + Vth * log (n / ni);
%!  
%!  
%!  vbcs = {(@(t) vbcs_1 (t, tbar, n([1 end]), ni, Vth, Vbar, nbar)), (@(t) vbcs_2 (t, tbar, p([1 end]), ni, Vth, Vbar, nbar))};
%!  
%!  %% scaling procedure
%!  pin = p / nbar;
%!  nin = n / nbar;
%!  Vin = V / Vbar;
%!  tin = tspan / tbar;
%!  Fnin = (Vin - log (nin));
%!  Fpin = (Vin + log (pin));
%!  
%!  %% initial guess via stationary simulation
%!  [nin, pin, Vin, Fnin, Fpin] = ...
%!      secs1d_dd_gummel_map (xin, Din, Nain, Ndin, pin, nin, Vin, Fnin, Fpin, ...
%!                            l2, er, u0nin, uminnin, vsatnin, betan, Nrefnin, ...
%!                            u0pin, uminpin, vsatpin, betap, Nrefpin, theta, ...
%!           	              tnin, tpin, Cnin, Cpin, anin, apin, ...
%!           	              Ecritnin, Ecritpin, toll, 3, ptoll, pmaxit); 
%!  
%!  %% (pseudo)transient simulation
%!  [nout, pout, Vout, Fnout, Fpout, Jnout, Jpout, tout, it, res] = ...
%!      secs1d_tran_dd_gummel_map (xin, tin, vbcs, Din, Nain, Ndin, pin, nin, Vin, 
%!                                 Fnin, Fpin, l2, er, u0nin, uminnin,
%!                                 vsatnin, betan, Nrefnin, u0pin, 
%!                                 uminpin, vsatpin, betap, Nrefpin,
%!                                 theta, tnin, tpin, Cnin, Cpin, anin, apin, 
%!  		                   Ecritnin, Ecritpin, toll, maxit, 
%!                                 ptoll, pmaxit);
%!  
%!  
%!  %% Descaling procedure
%!  n    = nout*nbar;
%!  p    = pout*nbar;
%!  V    = Vout*Vbar;
%!  t    = tout*tbar;
%!  Fn   = V - Vth*log(n/ni);
%!  Fp   = V + Vth*log(p/ni);
%!  dV   = diff(V, [], 1);
%!  dx   = diff(x);
%!  E    = -dV./dx;
%!     
%!  %% band structure
%!  Efn  = -Fn;
%!  Efp  = -Fp;
%!  Ec   =  Vth*log(Nc./n)+Efn;
%!  Ev   = -Vth*log(Nv./p)+Efp;
%!     
%!  vvector  = Fn(1, :);
%!  ivector  = Jbar * (Jnout(end, :) + Jpout(end, :));
%!  ivectorn = Jbar * (Jnout(1, :)   + Jpout(1, :));
%!  
%!  figure
%!  plot (vvector, ivector, vvector, ivectorn)
%!  legend('J_L','J_0')
%!  drawnow