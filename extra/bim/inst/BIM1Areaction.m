## Copyright (C) 2007,2008,2009  Carlo de Falco, Massimiliano Culpo
##
##                   BIM - Box Integration Method Package for Octave
## 
##  BIM is free software; you can redistribute it and/or modify
##  it under the terms of the GNU General Public License as published by
##  the Free Software Foundation; either version 2 of the License, or
##  (at your option) any later version.
##
##  BIM is distributed in the hope that it will be useful,
##  but WITHOUT ANY WARRANTY; without even the implied warranty of
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##  GNU General Public License for more details.
##
##  You should have received a copy of the GNU General Public License
##  along with BIM; If not, see <http://www.gnu.org/licenses/>.
##
##
##  AUTHORS:
##
##  Carlo de Falco <cdf _AT_ users.sourceforge.net>
##
##  Culpo Massimiliano
##  Bergische Universitaet Wuppertal
##  Fachbereich C - Mathematik und Naturwissenschaften
##  Arbeitsgruppe fuer Angewandte MathematD-42119 Wuppertal  Gaussstr. 20 
##  D-42119 Wuppertal, Germany

## -*- texinfo -*-
## @deftypefn {Function File} {[@var{C}]} = BIM2Areaction(@var{mesh}, @var{delta}, @var{zeta})
##
## Builds the matrix for the discretization of the LHS
## of the equation
## @iftex 
## @tex
## $ \delta \zeta u = f $
## @end tex 
## @end iftex 
## @ifnottex
## @var{delta} * @var{zeta} * u = f
## @end ifnottex
## 
## Input:
## @itemize @minus
## @item @var{mesh}: list of mesh nodes coordinates
## @item @var{delta}: elemental values of a piece-wise constant function.
## @item @var{zeta}: nodal values of a piece-wise linear conforming function.
## @end itemize 
##
## @seealso{BIM1Arhs, BIM1Aadvdiff}
## @end deftypefn

function [C] = BIM1Areaction(mesh,delta,zeta)
  
  Nnodes= length(mesh);
  h 	= (mesh(2:end)-mesh(1:end-1)).*delta;
  d0	= zeta.*[h(1)/2; (h(1:end-1)+h(2:end))/2; h(end)/2];
  C     = spdiags(d0, 0, Nnodes,Nnodes);

endfunction