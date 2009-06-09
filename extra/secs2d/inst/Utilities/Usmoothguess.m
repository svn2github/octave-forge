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
## @deftypefn {Function File}@
## {@var{guess}} = Usmoothguess(@var{imesh},@var{new},@var{old},@var{Dsides})
##
## Compute a guess to init Gummel map iteration
##
## @end deftypefn

function guess = Usmoothguess(mesh,new,old,Dsides);

  if ~isfield("mesh","wjacdet")
    mesh = Umeshproperties(mesh);
  endif

  Nelements = columns(mesh.t);
  Nnodes    = columns(mesh.p);

  Dnodes   = Unodesonside(mesh,Dsides);
  varnodes = setdiff([1:Nnodes]',Dnodes);
  guess    = new;

  A   = Ucomplap(mesh,ones(Nelements,1));
  Aie = A(varnodes,Dnodes);
  Aii = A(varnodes,varnodes);

  guess(varnodes) = Aii\(-Aie*(new(Dnodes)-old(Dnodes))+Aii*old(varnodes));

endfunction