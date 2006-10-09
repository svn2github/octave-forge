## Copyright (C) 2006   Sissou   <sylvain.pelissier@gmail.com>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
##
## -*- texinfo -*-
## @deftypefn {Function File} {} polyint (@var{c},@var{k})
## Return the coefficients of the integral of the polynomial whose
## coefficients are represented by the vector @var{c}.
##
## The constant of integration is set to @var{k}. If @var{k} isn't 
## define the integration constant is set to 0.
## @seealso{polyinteg, polyderiv, polyreduce, roots, conv, deconv, residue,
## filter, polyval, and polyvalm}
## @end deftypefn

function y = polyint(x,k)
	if(nargin != 1 && nargin != 2)
    usage ("polyint(vector,k)");
  	endif	
	if(nargin == 1)
   	k=0;
  	endif	
	y = polyinteg(x);
	y(prod(size(y))) = k;
endfunction;