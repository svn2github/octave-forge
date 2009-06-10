## Copyright (C) 2004-2008  Carlo de Falco
  ##
  ## SECS1D - A 1-D Drift--Diffusion Semiconductor Device Simulator
  ##
  ##  SECS1D is free software; you can redistribute it and/or modify
  ##  it under the terms of the GNU General Public License as published by
  ##  the Free Software Foundation; either version 2 of the License, or
  ##  (at your option) any later version.
  ##
  ##  SECS1D is distributed in the hope that it will be useful,
  ##  but WITHOUT ANY WARRANTY; without even the implied warranty of
  ##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  ##  GNU General Public License for more details.
  ##
  ##  You should have received a copy of the GNU General Public License
  ##  along with SECS1D; If not, see <http://www.gnu.org/licenses/>.
##
## author: Carlo de Falco <cdf _AT_ users.sourceforge.net>
  
## -*- texinfo -*-
##
## @deftypefn {Function File}@
## {@var{R}} = Ucomplap(@var{nodes},@var{Nnodes},@var{elements},@var{Nelements},@var{coeff})
##
## Compute P1 finite element approximation of the differential operator:
## 
##  - d ( coeff d (.)\dx)\dx
##
## @itemize @minus
## @item @var{nodes}: list of mesh nodes
## @item @var{Nnodes}: number of mesh nodes
## @item @var{elements}: list of mesh elements 
## @item @var{Nelements}: number of mesh elements
## @item @var{coeff}: piecewise linear reaction coefficient
## @end itemize
##
## @end deftypefn
  
function L = Ucomplap (nodes,Nnodes,elements,Nelements,coeff)
  
  h 	= nodes(2:end)-nodes(1:end-1);
  d0 	= [ coeff(1)./h(1); 
            (coeff(1:end-1)./h(1:end-1))+(coeff(2:end)./h(2:end));
            coeff(end)./h(end)];
  d1	= [1000; -coeff./h];
  dm1	= [ -coeff./h;1000];
  L	= spdiags([dm1, d0, d1],-1:1,Nnodes,Nnodes);
  
endfunction