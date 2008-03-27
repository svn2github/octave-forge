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
## @deftypefn {Function File} {@var{intrlvd} =} matdeintrlv (@var{data}, @var{nrows}, @var{ncols})
## Restore elements of @var{data} with a tempory matrix of size
## @var{nrows}-by-@var{ncols}.
## @seealso{matintrlv}
## @end deftypefn

function intrlvd = matdeintrlv(data,Nrows,Ncols)
	if(nargin < 3 || nargin >3)
		error('usage : interlvd = matdeintrlv(data,Nrows,Ncols)');
	end
	intrlvd = matintrlv(data,Ncols,Nrows);
