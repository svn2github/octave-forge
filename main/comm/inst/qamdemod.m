## Copyright (C) 2007   Sylvain Pelissier   <sylvain.pelissier@gmail.com>
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
## @deftypefn {Function File} qamdemod (@var{x},@var{m})
## Create the QAM demodulation of x with a size of alphabet m.
## @seealso{qammod,pskmod,pskdemod}
## @end deftypefn

function z = qamdemod(y,m)
    if(nargin < 2)
	usage('y = qamdemod(x,m)');
	exit;
   end
    
    c = sqrt(m);
    if(c ~= fix(c)  || log2(c) ~= fix(log2(c)))
        error('m must be a square of a power of 2');
        exit;
    end
    
    x = my_qammod(0:(m-1),m);
    x = reshape(x,1,m);
    for k = 1:length(y)
        [n z(k)] = min(abs(y(k) - x));
        z(k) = z(k) - 1;
    end