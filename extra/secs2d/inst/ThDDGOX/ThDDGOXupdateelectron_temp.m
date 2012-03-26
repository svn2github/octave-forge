## Copyright (C) 2004-2008  Carlo de Falco
##
## SECS2D - A 2-D Drift--Diffusion Semiconductor Device Simulator
##
## SECS2D is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## SECS2D is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with SECS2D; If not, see <http://www.gnu.org/licenses/>.
##
## AUTHOR: Carlo de Falco <cdf _AT_ users.sourceforge.net>

## -*- texinfo -*-
##
## @deftypefn {Function File} {@var{Tn}} = @
## ThDDGOXupdateelectron_temp(@var{imesh},@var{Dnodes},@var{Tn},@var{n},@var{p},@
##                            @var{Tl},@var{Jn},@var{E},@var{mobn0},@var{twn0},@
##                            @var{twn1},@var{tn},@var{tp},@var{n0},@var{p0})
##
## @end deftypefn

function Tn = ThDDGOXupdateelectron_temp(imesh,Dnodes,Tn,n,p,Tl,Jn,E,mobn0,twn0,twn1,tn,tp,n0,p0)

  Nnodes    = columns(imesh.p);
  Nelements = columns(imesh.t);
  Varnodes  = setdiff(1:Nnodes,Dnodes);

  alpha = mobn0;
  gamma = ones(Nnodes,1);
  eta   = 1.5 * n .* Tl;
  betax = Jn(1,:)./ mobn0';
  betay = Jn(2,:)./ mobn0';
  beta  = -2.5*[betax;betay];
  Sn    = Uscharfettergummel3(imesh,alpha,gamma,eta,beta);

  denom     = (tp*(n+sqrt(n0.*p0))+tn*(p+sqrt(n0.*p0)));
  R         = (p.*n)./denom;
  MASS_LHS1 = Ucompmass2(imesh,1.5*R,ones(Nelements,1));
  MASS_LHS2 = Ucompmass2(imesh,1.5*n./twn1,1./twn0);
  LHS       = Sn + MASS_LHS1 + MASS_LHS2;

  G                = (p0.*n0)./denom;
  PJoule           = Jn(1,:).*E(1,:) + Jn(2,:).*E(2,:);
  PJoule(PJoule<0) = 0;

  rhsJoule = Ucompconst (imesh,ones(Nnodes,1),PJoule');
  rhsR_G   = Ucompconst (imesh,1.5*G.*Tn,ones(Nelements,1));
  rhsTh_L  = Ucompconst (imesh,1.5*n.*Tl./twn1,1./twn0);
  RHS      = rhsJoule + rhsR_G + rhsTh_L;

  Tn(Varnodes) = LHS(Varnodes,Varnodes) \(RHS(Varnodes) - LHS(Varnodes,Dnodes)*Tn(Dnodes));

endfunction