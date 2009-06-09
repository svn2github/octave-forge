## Copyright (C) 2004-2008  Carlo de Falco
##
## SECS2D - A 2-D Drift--Diffusion Semiconductor Device Simulator
##
## SECS2D is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
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
## @deftypefn {Function File} {@var{n}} = @
## DDGOXTelectron_driftdiffusion(@var{mesh},@var{Dsides},@var{nin},@var{pin},@var{V},@var{un},@var{tn},@var{tp},@var{n0},@var{p0},@var{weight})
##
## Input:
## @itemize @minus
## @item V: electric potential
## @item mesh: integration domain
## @item nin: electron density in the past + initial guess
## @item pin: hole density in the past
## @item n0,p0: equilibrium densities
## @item tn,tp: carrier lifetimes
## @item weight: BDF weights
## @item un: mobility
## @end itemize
##
## Output:
## @itemize @minus
## @item n: updated electron density
## @end itemize
##
## @end deftypefn

function n = DDGOXTelectron_driftdiffusion(mesh,Dsides,nin,pin,V,un,tn,tp,n0,p0,weight)

  BDForder = length(weight)-1;
  denom    = (tp*(nin(:,end)+sqrt(n0.*p0))+tn*(pin(:,end)+sqrt(n0.*p0)));
  M        = weight(1) + pin(:,end)./denom;
  u        = un;

  U        = p0.*n0./denom;
  for ii = 1:BDForder
    U  += -nin(:,end-ii)*weight(ii+1);
  endfor

  guess = nin(:,end);
  n     = Udriftdiffusion(mesh,Dsides,guess,M,U,V,u);

endfunction