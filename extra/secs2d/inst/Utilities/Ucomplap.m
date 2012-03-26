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
## {@var{L}} = Ucomplap(@var{mesh},@var{coeff})
##
## Compute P1 finite element approximation of the differential operator:
## 
##  - d ( coeff d (.)\dx)\dx
##
## @itemize @minus
## @item @var{mesh}: input mesh
## @item @var{coeff}: piecewise linear reaction coefficient
## @end itemize
##
## @end deftypefn

function L = Ucomplap (mesh,coeff)
  
  Nnodes    = length(mesh.p);
  Nelements = length(mesh.t);
  
  areak = reshape(sum( mesh.wjacdet,1),1,1,Nelements);
  shg   = mesh.shg(:,:,:);
  M     = reshape(coeff,1,1,Nelements);
  
  ## Build local matrix	
  Lloc = zeros(3,3,Nelements);	
  for inode = 1:3
    for jnode = 1:3
      Lloc(inode,jnode,:)   = M .* sum( shg(:,inode,:) .* shg(:,jnode,:),1) .* areak;
      ginode(inode,jnode,:) = mesh.t(inode,:);
      gjnode(inode,jnode,:) = mesh.t(jnode,:);
    endfor
  endfor
  
  L = sparse(ginode(:),gjnode(:),Lloc(:));

endfunction

  
