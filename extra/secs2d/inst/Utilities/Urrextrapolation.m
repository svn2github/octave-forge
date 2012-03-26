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
## {@var{s}} = Urrextrapolation(@var{X})
##
## RRE vector extrapolation see 
## Smith, Ford & Sidi SIREV 29 II 06/1987
##
## @end deftypefn

function s = Urrextrapolation(X)

  if (Ucolumns(X)>Urows(X))
    X=X';
  endif
  
  ## Compute first and second variations
  U = X(:,2:end) - X(:,1:end-1);
  V = U(:,2:end) - U(:,1:end-1);
  
  ## Eliminate unused u_k column
  U(:,end) = [];
  
  s = X(:,1) - U * pinv(V) * U(:,1);
  
endfunction