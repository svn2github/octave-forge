## Copyright (C) 2000 Paul Kienzle
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
## @deftypefn {Function File} {} repmat (@var{A}, @var{m}, @var{n})
## @deftypefnx {Function File} {} repmat (@var{A}, [@var{m} @var{n}])
## Form a block matrix of size @var{m} by @var{n}, with a copy of matrix
## @var{A} as each element.  If @var{n} is not specified, form an 
## @var{m} by @var{m} block matrix.
## @end deftypefn

## Author: Paul Kienzle <pkienzle@kienzle.powernet.co.uk>
## Created: July 2000

## 2001-06-27 Paul Kienzle <pkienzle@users.sf.net>
## * cleaner, slightly faster code 

function x = repmat (b, m, n)
  if (nargin < 2 || nargin > 3)
    usage ("repmat (a, m, n)");
  endif

  if nargin == 2
    if is_scalar (m)
      n = m;
    elseif (is_vector (m) && length (m) == 2)
      n = m (2);
      m = m (1);
    else
      error ("repmat: only builds 2D matrices")
    endif
  endif

  [rb, cb] = size (b);
  if (isempty (b))
    x = zeros (m*rb, n*cb);
  else
    x = b ([1:rb]' * ones(1,m), [1:cb]' * ones(1,n));
  endif

endfunction
