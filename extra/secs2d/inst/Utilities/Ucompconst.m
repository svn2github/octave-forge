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
## @deftypefn {Function File}@
## {@var{C}} = Ucompconst(@var{imesh},@var{coeffn},@var{coeffe})
##
## Compute P1 finite element rhs:
##
## @itemize @minus
## @item @var{imesh}: input mesh structure
## @item @var{coeffn}: piecewise linear reaction coefficient
## @item @var{coeffe}: piecewise constant reaction coefficient
## @end itemize
##
## @end deftypefn

function C = Ucompconst (imesh,coeffn,coeffe)

  Nnodes    = size(imesh.p,2);
  Nelements = size(imesh.t,2);
  coeff     = coeffn(imesh.t(1:3,:));
  wjacdet   = imesh.wjacdet;
  ## Build local matrix	
  Blocmat = zeros(3,Nelements);	
  for inode = 1:3
    Blocmat(inode,:) = coeffe'.*coeff(inode,:).*wjacdet(inode,:);
  endfor
  gnode=(imesh.t(1:3,:));

  ## Assemble global matrix
  C = sparse(gnode(:),1,Blocmat(:));

endfunction