## Copyright (C) 1996, 1998, 2000, 2002, 2004, 2005, 2006, 2007
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
## @deftypefn {Function File} {@var{gain} =} norm (@var{sys}, @var{2})
## @deftypefnx {Function File} {@var{gain} =} norm (@var{sys}, @var{inf})
## @deftypefnx {Function File} {@var{gain} =} norm (@var{sys}, @var{inf}, @var{tol})
## Return norm of LTI model. L-infinity norm uses SLICOT AB13DD.
## @end deftypefn

## Author: A. S. Hodel <a.s.hodel@eng.auburn.edu>
## Created: August 1995
## Reference: Doyle, Glover, Khargonekar, Francis
##            State-Space Solutions to Standard Control Problems
##            IEEE TAC August 1989

## Adapted-By: Lukas Reichlin <lukas.reichlin@gmail.com>
## Date: November 2009
## Version: 0.1

function [gain, varargout] = norm (sys, ntype = "2", tol = 0.01)

  if (nargin > 3)  # norm () is caught by built-in function
    print_usage ();
  endif

  if (isnumeric (ntype) && isscalar (ntype))
    if (ntype == 2)
      ntype = "2";
    elseif (isinf (ntype))
      ntype = "inf";
    else
      error ("lti: norm: invalid norm type");
    endif
  elseif (ischar (ntype))
    ntype = lower (ntype);
  else
    error ("lti: norm: invalid norm type");
  endif

  switch (ntype)
    case "2"
      gain = h2norm (sys);

    case "inf"
      [gain, varargout{1}] = linfnorm (sys, tol);

    otherwise
      error ("lti: norm: invalid norm type");
  endswitch

endfunction


function gain = h2norm (sys)

  if (isstable (sys))
    [a, b, c, d] = ssdata (sys);

    if (isct (sys))
      M = lyap (a, b*b');
    else
      M = dlyap (a, b*b');
    endif

    if (min (real (eig (M))) < 0)
      error ("norm: H2: gramian < 0 (lightly damped modes?)")
    endif

    gain = sqrt (trace (d*d' + c*M*c'));
  else
    warning ("norm: H2: unstable input system; returning Inf");
    gain = Inf;
  endif

endfunction


function [gain, wpeak] = linfnorm (sys, tol = 0.01)

  [a, b, c, d, tsam] = ssdata (sys);
  tol = max (tol, 100*eps);
  
  [fpeak, gpeak] = slab13dd (a, b, c, d, tsam, tol);
  
  if (fpeak(2) > 0)
    if (tsam > 0)
      wpeak = fpeak(1) / tsam;
    else
      wpeak = fpeak(1);
    endif
  else
    wpeak = inf;
  endif
  
  if (gpeak(2) > 0)
    gain = gpeak(1);
  else
    gain = inf;
  endif

endfunction
