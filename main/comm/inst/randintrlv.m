## Copyright (C) 2008  Sylvain Pelissier   <sylvain.pelissier@gmail.com>
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

## -*- texinfo -*-
## @deftypefn {Function File} {@var{intrlvd} =} randintrlv(@var{data},@var{state})
##	Interleaves elements of @var{data} with a random permutation.
## @seealso{intrlv,deintrlv}
## @end deftypefn

function intrlvd = randintrlv(data,state)
	if(nargin < 2 || nargin >2)
		error('usage : interlvd = randinterlv(data,elements)');
	end
	
	if(isvector(data))
		l = length(data);
	else
		l = size(data,1);
	end
	rand('state',state);
	intrlvd = intrlv(data,randperm(l));