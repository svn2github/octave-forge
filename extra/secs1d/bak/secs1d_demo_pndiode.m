## Copyright (C) 2009  Carlo de Falco
##
## SECS1D - A 1-D Drift--Diffusion Semiconductor Device Simulator
##
## SECS1D is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## SECS1D is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with SECS1D; If not, see <http://www.gnu.org/licenses/>.
##
## author: Carlo de Falco <cdf _AT_ users.sourceforge.net>

function secs1d_demo_pndiode ()

  constants

  len = 1e-6;
  Nnodes = 1000;

  vmin = -2;
  vmax =  2;

  vstep=.4;

  istep = 1;
  va = vmin
  
  x = linspace(0,len,Nnodes)';
  xm = mean(x);
  
  Nd=1e25;
  Na=1e25;
  
  D = Nd * (x>xm) - Na * (x<=xm);

  nn = (Nd + sqrt(Nd^2+4*ni^2))/2;
  pp = (Na + sqrt(Na^2+4*ni^2))/2;
    
  xn = xm+1e-7;
  xp = xm-1e-7;

  %% Scaling coefficients
  xs  = len;
  ns  = norm(D,inf);
  idata.D = D/ns;
  Vs  = Vth;
  us  = un;
  Js  = xs / (us * Vs * q * ns);


  while va <= vmax
    
    vvect(istep) = va;
    
    n(:,istep) = nn * (x>=xn) + (ni^2)/pp * (x<xn);
    p(:,istep) = (ni^2)/nn * (x>xp) + pp * (x<=xp);
    
    Fn = va*(x<=xm);
    Fp = Fn;
    
    V(:,istep) = (Fn - Vth * log(p(:,istep)/ni)); 
  
    %% Scaling    
    xin   = x/xs;
    idata.n   = n(:,istep)/ns;
    idata.p   = p(:,istep)/ns;
    idata.V   = V(:,istep)/Vs;
    idata.Fn  = (Fn - Vs * log(ni/ns))/Vs;
    idata.Fp  = (Fp + Vs * log(ni/ns))/Vs;
    
    lambda2(istep) = idata.l2 = (Vs*esi)/(q*ns*xs^2);
    idata.nis   = ni/ns;
    idata.un   = un/us;
    idata.up   = up/us;
    
    %% Solution of DD system
    
    %% Algorithm parameters
    toll  = 1e-3;
    maxit = 20;
    ptoll  = 1e-10;
    pmaxit = 100;
    verbose = 0;
    sinodes = [1:length(x)];
    idata.tn = inf;
    idata.tp = inf;
    
    [odata,it,res] = DDGgummelmap (xin,idata,toll,maxit,ptoll,pmaxit,verbose);
    [odata,it,res] = DDNnewtonmap (xin,odata,toll, maxit,verbose);

    n(:,istep) = odata.n;
    p(:,istep) = odata.p;
    V(:,istep) = odata.V;
    
    DV(istep)  = odata.V(end) - odata.V(1);
    Emax(istep) = max(abs(diff(odata.V)./diff(xin)))

    Bp = Ubernoulli(diff (V(:, istep)),1);
    Bm = Ubernoulli(diff (V(:, istep)),0);
    Jn(:,istep) = -odata.un * (n(2:end, istep).*Bp-n(1:end-1, istep).*Bm)./diff (xin);
    Jp(:,istep) =  odata.up * (p(2:end, istep).*Bm-p(1:end-1, istep).*Bp)./diff (xin);

    va = va+vstep
    istep = istep+1;
    
  endwhile

  %% Descaling
  n     = n*ns;
  p     = p*ns;
  V     = V*Vs;
  J     = abs (Jp+Jn)*Js;

  close all
  
  figure();
  plot(x, n.')
  xlabel("x")
  ylabel("n")
 
  figure();
  plot(vvect, J)
  xlabel("V")
  ylabel("J")

  figure();
  plot(vvect, Emax)
  xlabel("V")
  ylabel("max(abs(\\phi^\'))")
  
endfunction