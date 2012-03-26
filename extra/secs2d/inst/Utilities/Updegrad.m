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
## @deftypefn {Function File} {[@var{gx},@var{gy}]} = Updegrad(@var{mesh},@var{u})
##
## Builds the P1 approximation of the gradient of the computed solution.
##
## Input:
## @itemize @minus
## @item @var{mesh}: PDEtool-like mesh with required field "p", "e", "t".
## @item @var{u}: piecewise linear conforming scalar function.
## @end itemize 
##
## @end deftypefn

function [Fx,Fy] = Updegrad(mesh,F);

  shgx = reshape(mesh.shg(1,:,:),3,[]);
  Fx   = sum(shgx.*F(mesh.t(1:3,:)),1);
  shgy = reshape(mesh.shg(2,:,:),3,[]);
  Fy   = sum(shgy.*F(mesh.t(1:3,:)),1);

endfunction