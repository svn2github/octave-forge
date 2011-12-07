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
## @deftypefn{Function File} {[@var{Kr}, @var{info}] =} conred (@var{Go}, @var{F}, @var{G}, @dots{})
## @deftypefnx{Function File} {[@var{Kr}, @var{info}] =} conred (@var{Go}, @var{F}, @var{G}, @var{nr}, @dots{})
## @deftypefnx{Function File} {[@var{Kr}, @var{info}] =} conred (@var{Go}, @var{F}, @var{G}, @var{opt}, @dots{})
## @deftypefnx{Function File} {[@var{Kr}, @var{info}] =} conred (@var{Go}, @var{F}, @var{G}, @var{nr}, @var{opt}, @dots{})
##
## Coprime factor reduction for state-feedback-observer based controllers.
##
## @strong{Inputs}
## @table @var
## @item Go
## LTI model of the open-loop plant (A,B,C,D).
## It has m inputs, p outputs and n states.
## @item F
## Stabilizing state feedback matrix (m-by-n).
## @item G
## Stabilizing observer gain matrix (n-by-p).
## @item @dots{}
## Optional pairs of keys and values.
## @item opt
## Optional struct with keys as field names.
## @end table
##
## @strong{Outputs}
## @table @var
## @item Kr
## State-space model of reduced order controller.
## @item info
## Struct containing additional information.
## @table @var
## @item info.hsv
## The Hankel singular values of the extended system?!?.
## The @var{n} Hankel singular values are ordered decreasingly.
## @item info.ncr
## The order of the obtained reduced order controller @var{Kr}.
## @end table
## @end table
##
##
## @strong{Algorithm}@*
## Uses SLICOT SB16BD by courtesy of
## @uref{http://www.slicot.org, NICONET e.V.}

## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: December 2011
## Version: 0.1

function [Kr, info] = cfconred (Go, F, G, varargin)

  if (nargin < 3)
    print_usage ();
  endif

  if (! isa (Go, "lti"))
    error ("cfconred: first argument must be an LTI system");
  endif

  if (! is_real_matrix (F))
    error ("cfconred: second argument must be a real matrix");
  endif
  
  if (! is_real_matrix (G))
    error ("cfconred: third argument must be a real matrix");
  endif

  if (nargin > 3)                                  # cfconred (Go, F, G, ...)
    if (is_real_scalar (varargin{1}))              # cfconred (Go, F, G, nr)
      varargin = horzcat (varargin(2:end), {"order"}, varargin(1));
    endif
    if (isstruct (varargin{1}))                    # cfconred (Go, F, G, opt, ...), cfconred (Go, F, G, nr, opt, ...)
      varargin = horzcat (__opt2cell__ (varargin{1}), varargin(2:end));
    endif
    ## order placed at the end such that nr from cfconred (Go, F, G, nr, ...)
    ## and cfconred (Go, F, G, nr, opt, ...) overrides possible nr's from
    ## key/value-pairs and inside opt struct (later keys override former keys,
    ## nr > key/value > opt)
  endif

  nkv = numel (varargin);                          # number of keys and values

  if (rem (nkv, 2))
    error ("cfconred: keys and values must come in pairs");
  endif

  [a, b, c, d, tsam, scaled] = ssdata (Go);
  [p, m] = size (Go);
  n = rows (a);
  [mf, nf] = size (F);
  [ng, pg] = size (G);
  dt = isdt (Go);
  jobd = any (d(:));

  if (mf != m || nf != n)
    error ("cfconred: dimensions of state-feedback matrix (%dx%d) and plant (%dx%d, %d states) don't match", \
           mf, nf, p, m, n);
  endif

  if (ng != n || pg != p)
    error ("cfconred: dimensions of observer matrix (%dx%d) and plant (%dx%d, %d states) don't match", \
           ng, pg, p, m, n);
  endif

  ## default arguments
  tol1 = 0.0;
  tol2 = 0.0;
  jobcf = 0;
  jobmr = 2;                                       # balancing-free BTA
  equil = scaled && scaledc;
  ordsel = 1;
  ncr = 0;


  ## handle keys and values
  for k = 1 : 2 : nkv
    key = lower (varargin{k});
    val = varargin{k+1};
    switch (key)
      case {"order", "ncr", "nr"}
        [ncr, ordsel] = __modred_check_order__ (val);

      case "tol1"
        tol1 = __modred_check_tol__ (val, "tol1");

      case "tol2"
        tol2 = __modred_check_tol__ (val, "tol2");

      case "cf"
        switch (lower (val(1)))
          case "l"
            jobcf = 0;
          case "r"
            jobcf = 1;
          otherwise
            error ("cfconred: '%s' is an invalid coprime factorization", val);
        endswitch

      case {"method", "approach", "approx"}        # approximation method
        switch (tolower (val))
          case {"sr-bta", "b"}                     # 'B':  use the square-root Balance & Truncate method
            jobmr = 0;
          case {"bfsr-bta", "f"}                   # 'F':  use the balancing-free square-root Balance & Truncate method
            jobmr = 1;
          case {"sr-spa", "s"}                     # 'S':  use the square-root Singular Perturbation Approximation method
            jobmr = 2;
          case {"bfsr-spa", "p"}                   # 'P':  use the balancing-free square-root Singular Perturbation Approximation method
            jobmr = 3; 
          otherwise
            error ("cfconred: '%s' is an invalid approach", val);
        endswitch
      
      case {"equil", "equilibrate", "equilibration", "scale", "scaling"}
        equil = __modred_check_equil__ (val);

      otherwise
        warning ("cfconred: invalid property name '%s' ignored", key);
    endswitch
  endfor


  ## perform model order reduction
  [acr, bcr, ccr, dcr, ncr, hsv] = slsb16bd (a, b, c, d, dt, equil, ncr, ordsel, jobd, jobmr, \
                                             F, G, jobcf, tol1, tol2);

  ## assemble reduced order controller
  Kr = ss (acr, bcr, ccr, dcr, tsam);

  ## assemble info struct  
  info = struct ("ncr", ncr, "hsv", hsv);

endfunction


%!shared Mo, Me, Info, HSVe
%! A =  [       0    1.0000         0         0         0         0         0        0
%!              0         0         0         0         0         0         0        0
%!              0         0   -0.0150    0.7650         0         0         0        0
%!              0         0   -0.7650   -0.0150         0         0         0        0
%!              0         0         0         0   -0.0280    1.4100         0        0
%!              0         0         0         0   -1.4100   -0.0280         0        0
%!              0         0         0         0         0         0   -0.0400    1.850
%!              0         0         0         0         0         0   -1.8500   -0.040 ];
%!
%! B =  [  0.0260
%!        -0.2510
%!         0.0330
%!        -0.8860
%!        -4.0170
%!         0.1450
%!         3.6040
%!         0.2800 ];
%!
%! C =  [  -.996 -.105 0.261 .009 -.001 -.043 0.002 -0.026 ];
%!
%! D =  [  0.0 ];
%!
%! Go = ss (A, B, C, D);  % "scaled", false
%!
%! F = [  4.4721e-002  6.6105e-001  4.6986e-003  3.6014e-001  1.0325e-001 -3.7541e-002 -4.2685e-002  3.2873e-002 ];
%!
%! G = [  4.1089e-001
%!        8.6846e-002
%!        3.8523e-004
%!       -3.6194e-003
%!       -8.8037e-003
%!        8.4205e-003
%!        1.2349e-003
%!        4.2632e-003 ];
%!
%! [Kr, Info] = cfconred (Go, F, G, 4, "method", "bfsr-bta", "cf", "left", "tol1", 0.1, "tol2", 0.0);
%! [Ao, Bo, Co, Do] = ssdata (Kr);
%!
%! Ae = [  0.5946  -0.7336   0.1914  -0.3368
%!         0.5960  -0.0184  -0.1088   0.0207
%!         1.2253   0.2043   0.1009  -1.4948
%!        -0.0330  -0.0243   1.3440   0.0035 ];
%!
%! Be = [  0.0015
%!        -0.0202
%!         0.0159
%!        -0.0544 ];
%!
%! Ce = [  0.3534   0.0274   0.0337  -0.0320 ];
%!
%! De = [  0.0000 ];
%!
%! HSVe = [  4.9078   4.8745   3.8455   3.7811   1.2289   1.1785   0.5176   0.1148 ].';
%!
%! Mo = [Ao, Bo; Co, Do];
%! Me = [Ae, Be; Ce, De];
%!
%!assert (Mo, Me, 1e-4);
%!assert (Info.hsv, HSVe, 1e-4);