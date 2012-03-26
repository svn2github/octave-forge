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
## @deftypefn {Function File} {@var{n}} = @
## DDGOXelectron_driftdiffusion(@var{mesh},@var{Dsides},@var{nin},@var{pin},@var{V},@var{un},@var{tn},@var{tp},@var{n0},@var{p0})
##
## Input:
## @itemize @minus
## @item v: electric potential
## @item mesh: integration domain
## @end itemize
##
## Output:
## @itemize @minus
## @item n: updated electron density
## @end itemize
##
## @end deftypefn

function n = DDGOXelectron_driftdiffusion(mesh,Dsides,nin,pin,V,un,tn,tp,n0,p0)

  if (Ucolumns(nin)>Urows(nin))
    nin = nin';
  endif

  if (Ucolumns(V)>Urows(V))
    V = V';
  endif

  if (Ucolumns(pin)>Urows(pin))
    pin = pin';
  endif

  Nnodes    = max(size(mesh.p));
  Nelements = max(size(mesh.t));

  denom = (tp*(nin+sqrt(n0.*p0))+tn*(pin+sqrt(n0.*p0)));
  u     = un;
  U     = p0.*n0./denom;
  M     = pin./denom;
  guess = nin;

  n = Udriftdiffusion(mesh,Dsides,guess,M,U,V,u);

endfunction