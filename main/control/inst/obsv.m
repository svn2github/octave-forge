## Copyright (C) 1997, 2000, 2002, 2004, 2005, 2006, 2007 Kai P. Mueller
##
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {} obsv (@var{sys}, @var{c})
## @deftypefnx {Function File} {} obsv (@var{a}, @var{c})
## Build observability matrix:
## @iftex
## @tex
## $$ Q_b = \left[ \matrix{  C       \cr
##                           CA    \cr
##                           CA^2  \cr
##                           \vdots  \cr
##                           CA^{n-1} } \right ] $$
## @end tex
## @end iftex
## @ifinfo
## @example
## @group
##      | C        |
##      | CA       |
## Qb = | CA^2     |
##      | ...      |
##      | CA^(n-1) |
## @end group
## @end example
## @end ifinfo
## of a system data structure or the pair (@var{a}, @var{c}).
##
## The numerical properties of @command{is_observable}
## are much better for observability tests.
## @end deftypefn

## Author: Kai P. Mueller <mueller@ifr.ing.tu-bs.de>
## Created: November 4, 1997

function Qb = obsv (sys, c)

  if (nargin == 2)
    a = sys;
  elseif (nargin == 1 && isstruct(sys))
    sysupdate (sys, "ss");
    [a, b, c] = sys2ss (sys);
  else
    print_usage ();
  endif

  if (! is_abcd (a, c'))
    Qb = [];
  else
    ## no need to check dimensions, we trust is_abcd().
    [na, ma] = size (a);
    [nc, mc] = size (c);
    Qb = zeros (na*nc, ma);
    for i = 1:na
      Qb((i-1)*nc+1:i*nc, :) = c;
      c = c * a;
    endfor
  endif
endfunction
