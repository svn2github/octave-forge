## Copyright (C) 2012 Akos Marton <makos999@gmail.com>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {} lfactorial (@var{n})
## Return the factorial of @var{n} where @var{n} is a positive integer.
##
## Return value approximated on natural logarithmic scale in order to
## calculate the factorial of large numbers. For
## vector or matrix arguments, return the lfactorial of each element in the
## array.  For non-integers see the generalized factorial function
## @code{lgamma}.
##
## @seealso{lgamma, big_factorial}
## @end deftypefn

function ans = lfactorial (n)
  if (nargin != 1)
    print_usage ();
  elseif (any (n(:) < 0 | n(:) != round (n(:))))
    error ("factorial: N must all be nonnegative integers");
  endif
  ans = lgamma (n+1);
endfunction
