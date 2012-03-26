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
## @deftypefn {Function File} {[@var{nodelist}]} =@
## Unodesonside (@var{mesh}, @var{sidelist})
##
## Returns a list of the nodes lying on the sides @var{sidelist} of
## the mesh @var{mesh}.
##
## Input:
## @itemize @minus
## @item @var{mesh}: standard PDEtool-like mesh, with field "p", "e", "t".
## @item @var{sidelist}: row vector containing the number of the sides (numbering referred to mesh.e(5,:)).
## @end itemize
##
## Output:
## @itemize @minus
## @item @var{nodelist}: list of the nodes that lies on the specified sides.
## @end itemize 
##
## @end deftypefn

function Dnodes = Unodesonside(mesh,Dsides);

  Dedges = [];

  for ii = 1:length(Dsides)
    Dedges = [Dedges,find(mesh.e(5,:)==Dsides(ii))];
  endfor

  ## Set list of nodes with Dirichelet BCs
  Dnodes = mesh.e(1:2,Dedges);
  Dnodes = [Dnodes(1,:) Dnodes(2,:)];
  Dnodes = unique(Dnodes);

endfunction