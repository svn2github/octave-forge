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
## @item nr
## The order of the obtained system @var{sysr}.
## @end table
##
## @strong{Algorithm}@*
## Uses SLICOT AB09HD by courtesy of
## @uref{http://www.slicot.org, NICONET e.V.}
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: October 2011
## Version: 0.1

function [sysr, nr] = bstmodred (sys, varargin)

  if (nargin == 0)
    print_usage ();
  endif
  
  if (! isa (sys, "lti"))
    error ("bstmodred: first argument must be an LTI system");
  endif

  if (rem (nargin-1, 2))
    error ("bstmodred: properties and values must come in pairs");
  endif

  [a, b, c, d, tsam, scaled] = ssdata (sys);
  dt = isdt (sys);
  
  ## default arguments
  beta = 1; # ?
  tol1 = 0; 
  tol2 = 0;
  ordsel = 1;
  nr = 0;
  
  job = 1; ## ?
  
  if (dt)       # discrete-time
    alpha = 1;  # ALPHA <= 0
  else          # continuous-time
    alpha = 0;  # 0 <= ALPHA <= 1
  endif

  for k = 1 : 2 : (nargin-1)
    prop = lower (varargin{k});
    val = varargin{k+1};
    switch (prop)
      case {"order", "n", "nr"}
        if (! issample (val, 0) || val != round (val))
          error ("bstmodred: argument %s must be an integer >= 0", varargin{k});
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
          error ("bstmodred: argument %s must be a real scalar", varargin{k});
        endif
        if (dt)  # discrete-time
          if (val < 0 || val > 1)
            error ("bstmodred: argument %s must be 0 <= ALPHA <= 1", varargin{k});
          endif
        else     # continuous-time
          if (val > 0)
            error ("bstmodred: argument %s must be ALPHA <= 0", varargin{k});
          endif
        endif
        alpha = val;

      case "beta"
        if (! issample (val, 0))
          error ("bstmodred: argument %s must be BETA >= 0", varargin{k});
        endif
        beta = val;

      otherwise
        error ("hnamodred: invalid property name");
    endswitch
  endfor
  
  ## TODO: handle job
  
  ## perform model order reduction
  [ar, br, cr, dr, nr] = slab09hd (a, b, c, d, dt, scaled, job, nr, ordsel, alpha, beta, \
                                   tol1, tol2);

  ## assemble reduced order model
  sysr = ss (ar, br, cr, dr, tsam);

endfunction


%!shared Mo, Me
%! A =  [ -0.04165  0.0000  4.9200  -4.9200  0.0000  0.0000  0.0000
%!        -5.2100  -12.500  0.0000   0.0000  0.0000  0.0000  0.0000
%!         0.0000   3.3300 -3.3300   0.0000  0.0000  0.0000  0.0000
%!         0.5450   0.0000  0.0000   0.0000 -0.5450  0.0000  0.0000
%!         0.0000   0.0000  0.0000   4.9200 -0.04165 0.0000  4.9200
%!         0.0000   0.0000  0.0000   0.0000 -5.2100 -12.500  0.0000
%!         0.0000   0.0000  0.0000   0.0000  0.0000  3.3300 -3.3300 ];
%!
%! B =  [  0.0000   0.0000
%!         12.500   0.0000
%!         0.0000   0.0000
%!         0.0000   0.0000
%!         0.0000   0.0000
%!         0.0000   12.500
%!         0.0000   0.0000 ];
%!
%! C =  [  1.0000   0.0000  0.0000   0.0000  0.0000  0.0000  0.0000
%!         0.0000   0.0000  0.0000   1.0000  0.0000  0.0000  0.0000
%!         0.0000   0.0000  0.0000   0.0000  1.0000  0.0000  0.0000 ];
%!
%! D =  [  0.0000   0.0000
%!         0.0000   0.0000
%!         0.0000   0.0000 ];
%!
%! sys = ss (A, B, C, D, "scaled", true);
%!
%! sysr = bstmodred (sys, "beta", 1.0, "tol1", 0.1, "tol2", 0.0);
%! [Ao, Bo, Co, Do] = ssdata (sysr);
%!
%! Ae = [  1.2729   0.0000   6.5947   0.0000  -3.4229
%!         0.0000   0.8169   0.0000   2.4821   0.0000
%!        -2.9889   0.0000  -2.9028   0.0000  -0.3692
%!         0.0000  -3.3921   0.0000  -3.1126   0.0000
%!        -1.4767   0.0000  -2.0339   0.0000  -0.6107 ];
%!
%! Be = [  0.1331  -0.1331
%!        -0.0862  -0.0862
%!        -2.6777   2.6777
%!        -3.5767  -3.5767
%!        -2.3033   2.3033 ];
%!
%! Ce = [ -0.6907  -0.6882   0.0779   0.0958  -0.0038
%!         0.0676   0.0000   0.6532   0.0000  -0.7522
%!         0.6907  -0.6882  -0.0779   0.0958   0.0038 ];
%!
%! De = [  0.0000   0.0000
%!         0.0000   0.0000
%!         0.0000   0.0000 ];
%!
%! Mo = [Ao, Bo; Co, Do];
%! Me = [Ae, Be; Ce, De];
%!
%!assert (Mo, Me, 1e-4);

