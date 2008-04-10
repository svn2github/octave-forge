## Copyright (C) 2006 Sylvain Pelissier
## Copyright (C) 2006 Paul Kienzle
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
## along with this program; If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{y}} issorted (@var{x},@var{str})
## issorted return 1 if @var{x} is sorted and 0 also. If @var{str} is equal to 'rows' issorted return 1 if @var{x} is 
##equal to sortrows(@var{x}) and 0 also. 
## @seealso{sort, sortrows}
## @end deftypefn

## Author: Sylvain Pelissier <sylvain.pelissier@gmail.com> 
## Author: Paul Kienzle <pkienzle@users.sf.net>

function y = issorted(x,str)
	if(nargin == 0)
		usage(" \n issorted(x) \n issorted(A,'rows')");
	else
		if(nargin == 1)
			y = all((diff(x)>=0)(:));
		else
			if(nargin == 2 && str == 'rows')
				t = sign(diff(x)); # t contains -1, 0, or 1
   			t(t==1) = columns(x); # t contains -1, 0, or n
   			y = all (cumsum(t,2) >= 0)(:);
			else
				error("The second argument must be equal to 'rows'\n");
			endif;
		endif;
	endif;
endfunction;
