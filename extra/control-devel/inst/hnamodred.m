## Copyright (C) 2011   Lukas F. Reichlin
##
## This file is part of LTI Syncope.
##
## LTI Syncope is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## LTI Syncope is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with LTI Syncope.  If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn{Function File} {[@var{sysr}, @var{nr}] =} hnamodred (@var{sys}, @dots{})
## Model order reduction by frequency weighted optimal Hankel-norm approximation method.
##
## @strong{Inputs}
## @table @var
## @item sys
## LTI model to be reduced.
## @item @dots{}
## Pairs of properties and values.
## TODO: describe options.
## @end table
##
## @strong{Outputs}
## @table @var
## @item sysr
## Reduced order state-space model.
## @item n
## The order of the obtained system @var{sysr}.
## @end table
##
## @strong{Algorithm}@*
## Uses SLICOT AB09JD by courtesy of
## @uref{http://www.slicot.org, NICONET e.V.}
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: October 2011
## Version: 0.1

function [sysr, nr] = hnamodred (sys, varargin)

  if (nargin == 0)
    print_usage ();
  endif
  
  if (! isa (sys, "lti"))
    error ("hnamodred: first argument must be an LTI system");
  endif

  if (rem (nargin-1, 2))
    error ("hnamodred: properties and values must come in pairs");
  endif

  [a, b, c, d, tsam, scaled] = ssdata (sys);
  dt = isdt (sys);
  
  ## default arguments
  av = bv = cv = dv = [];
  jobv = 0;
  aw = bw = cw = dw = [];
  jobw = 0;
  jobinv = 2;
  tol1 = 0; 
  tol2 = 0;
  ordsel = 1;
  nr = 0
  
  if (dt)       # discrete-time
    alpha = 1;  # ALPHA <= 0
  else          # continuous-time
    alpha = 0;  # 0 <= ALPHA <= 1
  endif

  for k = 1 : 2 : (nargin-1)
    prop = lower (varargin{k});
    val = varargin{k+1};
    switch (prop)
      case {"left", "v"}
        val = ss (val);  # val could be non-lti, therefore ssdata would fail
        [av, bv, cv, dv, tsamv] = ssdata (val);
        jobv = 1;

      case {"right", "w"}
        val = ss (val);
        [aw, bw, cw, dw, tsamw] = ssdata (val);
        jobw = 1;
        ## TODO: check ct/dt

      case {"order", "n", "nr"}
        if (! issample (val, 0) || val != round (val))
          error ("hnamodred: argument %s must be an integer >= 0", varargin{k});
        endif
        nr = val;
        ordsel = 0;

      case "tol1"
        if (! is_real_scalar (val))
          error ("hnamodred: argument %s must be a real scalar", varargin{k});
        endif
        tol1 = val;

      case "tol2"
        if (! is_real_scalar (val))
          error ("hnamodred: argument %s must be a real scalar", varargin{k});
        endif
        tol2 = val;

      case "alpha"
        if (! is_real_scalar (val))
          error ("hnamodred: argument %s must be a real scalar", varargin{k});
        endif
        if (dt)  # discrete-time
          if (val < 0 || val > 1)
            error ("hnamodred: argument %s must be 0 <= ALPHA <= 1", varargin{k});
          endif
        else     # continuous-time
          if (val > 0)
            error ("hnamodred: argument %s must be ALPHA <= 0", varargin{k});
          endif
        endif
        alpha = val;

      otherwise
        error ("hnamodred: invalid property name");
    endswitch
  endfor
  


  [ar, br, cr, dr, nr] = slab09jd (a, b, c, d, dt, scaled, nr, ordsel, alpha, \
                                   jobv, av, bv, cv, dv, \
                                   jobw, aw, bw, cw, dw, \
                                   jobinv, tol1, tol2);

  sysr = ss (ar, br, cr, dr, tsam);

endfunction


%!shared Mo, Me
%! A =  [ -3.8637   -7.4641   -9.1416   -7.4641   -3.8637   -1.0000
%!         1.0000,         0         0         0         0         0
%!              0    1.0000         0         0         0         0
%!              0         0    1.0000         0         0         0
%!              0         0         0    1.0000         0         0
%!              0         0         0         0    1.0000         0 ];
%!
%! B =  [       1
%!              0
%!              0
%!              0
%!              0
%!              0 ];
%!
%! C =  [       0         0         0         0         0         1 ];
%!
%! D =  [       0 ];
%!
%! sys = ss (A, B, C, D);
%!
%! AV = [  0.2000   -1.0000
%!         1.0000         0 ];
%!
%! BV = [       1
%!              0 ];
%!
%! CV = [ -1.8000         0 ];
%!
%! DV = [       1 ];
%!
%! sysv = ss (AV, BV, CV, DV);
%!
%! sysr = hnamodred (sys, "left", sysv, "tol1", 1e-1, "tol2", 1e-14);
%! [Ao, Bo, Co, Do] = ssdata (sysr);
%!
%! Ae = [ -0.2391   0.3072   1.1630   1.1967
%!        -2.9709  -0.2391   2.6270   3.1027
%!         0.0000   0.0000  -0.5137  -1.2842
%!         0.0000   0.0000   0.1519  -0.5137 ];
%!
%! Be = [ -1.0497
%!        -3.7052
%!         0.8223
%!         0.7435 ];
%!
%! Ce = [ -0.4466   0.0143  -0.4780  -0.2013 ];
%!
%! De = [  0.0219 ];
%!
%! Mo = [Ao, Bo; Co, Do];
%! Me = [Ae, Be; Ce, De];
%!
%!assert (Mo, Me, 1e-4);

