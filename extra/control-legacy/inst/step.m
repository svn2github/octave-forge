## Copyright (C) 1996, 2000, 2002, 2004, 2005, 2006, 2007
##               Auburn University.  All rights reserved.
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
## @deftypefn {Function File} {[@var{y}, @var{t}] =} step (@var{sys}, @var{inp}, @var{tstop}, @var{n})
## Step response for a linear system.
## The system can be discrete or multivariable (or both).
## If no output arguments are specified, @code{step}
## produces a plot or the step response data for system @var{sys}.
##
## @strong{Inputs}
## @table @var
## @item sys
## System data structure.
## @item inp
## Index of input being excited
## @item tstop
## The argument @var{tstop} (scalar value) denotes the time when the
## simulation should end.
## @item n
## the number of data values.
##
## Both parameters @var{tstop} and @var{n} can be omitted and will be
## computed from the eigenvalues of the A Matrix.
## @end table
## @strong{Outputs}
## @table @var
## @item y
## Values of the step response.
## @item t
## Times of the step response.
## @end table
##
## When invoked with the output parameter @var{y} the plot is not displayed.
## @seealso{impulse}
## @end deftypefn

## Author: Kai P. Mueller <mueller@ifr.ing.tu-bs.de>
## Created: September 30, 1997
## based on lsim.m of Scottedward Hodel

function [y, t] = step (sys, inp, tstop, n)

  if (nargin < 1 || nargin > 4)
    print_usage ();
  endif

  if (! isstruct (sys))
    error ("step: sys must be a system data structure.");
  endif

  if (nargout == 0)
    switch (nargin)
      case (1)
        __stepimp__ (1, sys);
      case (2)
        __stepimp__ (1, sys, inp);
      case (3)
        __stepimp__ (1, sys, inp, tstop);
      case (4)
        __stepimp__ (1, sys, inp, tstop, n);
    endswitch
  else
    switch (nargin)
      case (1)
        [y, t] = __stepimp__ (1, sys);
      case (2)
        [y, t] = __stepimp__ (1, sys, inp);
      case (3)
        [y, t] = __stepimp__ (1, sys, inp, tstop);
      case (4)
        [y, t] = __stepimp__ (1, sys, inp, tstop, n);
    endswitch
  endif

endfunction
