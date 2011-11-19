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
## @deftypefn{Function File} {[@var{sysr}, @var{info}] =} hnamodred (@var{sys})
## @deftypefnx{Function File} {[@var{sysr}, @var{info}] =} hnamodred (@var{sys}, @dots{})
## @deftypefnx{Function File} {[@var{sysr}, @var{info}] =} hnamodred (@var{sys}, @var{opt})
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
## @item nr
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

function [sysr, info] = hnamodred (sys, varargin)

  if (nargin == 0)
    print_usage ();
  endif
  
  if (! isa (sys, "lti"))
    error ("hnamodred: first argument must be an LTI system");
  endif

  if (nargin == 2)
    varargin = __opt2cell__ (varargin{1});
  elseif (rem (nargin-1, 2))
    error ("hnamodred: properties and values must come in pairs");
  endif

  [a, b, c, d, tsam, scaled] = ssdata (sys);
  [p, m] = size (sys);
  dt = isdt (sys);
  
  ## default arguments
  alpha = __modred_default_alpha__ (dt);
  av = bv = cv = dv = [];
  jobv = 0;
  aw = bw = cw = dw = [];
  jobw = 0;
  jobinv = 2;
  tol1 = 0; 
  tol2 = 0;
  ordsel = 1;
  nr = 0;

  ## handle properties and values
  for k = 1 : 2 : (nargin-1)
    prop = lower (varargin{k});
    val = varargin{k+1};
    switch (prop)
      case {"left", "v"}
        [av, bv, cv, dv, jobv] = __modred_check_weight__ (val, dt, p, p);
        ## TODO: correct error messages for non-square weights

      case {"right", "w"}
        [aw, bw, cw, dw, jobw] = __modred_check_weight__ (val, dt, m, m);

      case {"left-inv", "inv-v"}
        [av, bv, cv, dv] = __modred_check_weight__ (val, dt, p, p);
        jobv = 2;

      case {"right-inv", "inv-w"}
        [aw, bw, cw, dw] = __modred_check_weight__ (val, dt, m, m);
        jobv = 2

      case {"left-conj", "conj-v"}
        [av, bv, cv, dv] = __modred_check_weight__ (val, dt, p, p);
        jobv = 3;

      case {"right-conj", "conj-w"}
        [aw, bw, cw, dw] = __modred_check_weight__ (val, dt, m, m);
        jobv = 3

      case {"left-conj-inv", "conj-inv-v"}
        [av, bv, cv, dv] = __modred_check_weight__ (val, dt, p, p);
        jobv = 4;

      case {"right-conj-inv", "conj-inv-w"}
        [aw, bw, cw, dw] = __modred_check_weight__ (val, dt, m, m);
        jobv = 4

      case {"order", "n", "nr"}
        [nr, ordsel] = __modred_check_order__ (val);

      case "tol1"
        tol1 = __modred_check_tol__ (val, "tol1");

      case "tol2"
        tol2 = __modred_check_tol__ (val, "tol2");

      case "alpha"
        alpha = __modred_check_alpha__ (val, dt);

      case {"approach", "jobinv"}
        switch (tolower (val(1)))
          case {"d", "n"}      # "descriptor"
            jobinv = 0;
          case {"s", "i"}      # "standard"
            jobinv = 1;
          case "a"             # {"auto", "automatic"}
            jobinv = 2;
          otherwise
            error ("hnamodred: invalid computational approach");
        endswitch

      otherwise
        warning ("hnamodred: invalid property name ""%s"" ignored", prop);
    endswitch
  endfor

  
  ## perform model order reduction
  [ar, br, cr, dr, nr, hsv, ns] = slab09jd (a, b, c, d, dt, scaled, nr, ordsel, alpha, \
                                            jobv, av, bv, cv, dv, \
                                            jobw, aw, bw, cw, dw, \
                                            jobinv, tol1, tol2);

  ## assemble reduced order model
  sysr = ss (ar, br, cr, dr, tsam);

  ## assemble info struct  
  info = struct ("nr", nr, "ns", ns, "hsv", hsv);

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
%! sys = ss (A, B, C, D);  # "scaled", false
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

