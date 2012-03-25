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
## {@var{R}} = Ucompmass(@var{nodes},@var{Nnodes},@var{elements},@var{Nelements},@var{Bvect},@var{Cvect})
##
## Compute P1 finite element mass-matrix:
##
## @itemize @minus
## @item @var{nodes}: list of mesh nodes
## @item @var{Nnodes}: number of mesh nodes
## @item @var{elements}: list of mesh elements 
## @item @var{Nelements}: number of mesh elements
## @item @var{Bvect}: piecewise linear reaction coefficient
## @item @var{Cvect}: piecewise constant reaction coefficient
## @end itemize
##
## @end deftypefn

function Bmat	= Ucompmass (nodes,Nnodes,elements,Nelements,Bvect,Cvect);
  
  h 	= (nodes(2:end)-nodes(1:end-1)).*Cvect;
  d0	= Bvect.*[h(1)/2; (h(1:end-1)+h(2:end))/2; h(end)/2];
  Bmat  = spdiags(d0, 0, Nnodes,Nnodes);
  
endfunction
  
