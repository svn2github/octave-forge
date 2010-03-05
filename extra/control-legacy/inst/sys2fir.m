## Copyright (C) 1996, 2000, 2003, 2004, 2005, 2006, 2007
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
## @deftypefn {Function File} {[@var{c}, @var{tsam}, @var{input}, @var{output}] =} sys2fir (@var{sys})
##
## Extract @acronym{FIR} data from system data structure; see @command{fir2sys} for
## parameter descriptions.
## @seealso{fir2sys}
## @end deftypefn

## Author: A. S. Hodel <a.s.hodel@eng.auburn.edu>
## Created: July 1996

function [c, tsam, inname, outname] = sys2fir (sys)

  if (nargin != 1)
    print_usage ();
  endif

  ## let sys2tf do most of the work

  [num, den, tsam, inname, outname] = sys2tf (sys);

  alph = den(1);                        # scale to get monic denominator
  den /= alph;
  num /= alph;
  l = length (den);
  m = length (num);
  if (norm (den(2:l)))
    sysout (sys, "tf");
    error ("denominator has poles away from origin");
  elseif (! is_digital (sys))
    error ("system must be discrete-time to be FIR");
  elseif (m != l)
    warning ("sys2fir: deg(num) - deg(den) = %d; coefficients must be shifted",
	     m-l);
  endif
  c = num;

endfunction

