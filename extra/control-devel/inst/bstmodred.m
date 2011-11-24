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
## @deftypefn{Function File} {[@var{Gr}, @var{info}] =} bstmodred (@var{G})
## @deftypefnx{Function File} {[@var{Gr}, @var{info}] =} bstmodred (@var{G}, @dots{})
## @deftypefnx{Function File} {[@var{Gr}, @var{info}] =} bstmodred (@var{G}, @var{opt})
## Model order reduction by Balanced Stochastic Truncation method.
## Uses the stochastic balancing approach in conjunction with the square-root or
## the balancing-free square-root Balance & Truncate (B&T)
## or Singular Perturbation Approximation (SPA) model reduction
## methods for the ALPHA-stable part of the system.
##
## @strong{Inputs}
## @table @var
## @item G
## LTI model to be reduced.
## @item @dots{}
## Pairs of keys and values.
## @item opt
## Struct with keys as field names.
## @end table
##
## @strong{Outputs}
## @table @var
## @item Gr
## Reduced order state-space model.
## @item info
## Struct containing additional information.
## @table @var
## @item n
## The order of the original system @var{G}.
## @item ns
## The order of the @var{alpha}-stable subsystem of the original system @var{G}.
## @item hsv
## The Hankel singular values of the phase system corresponding
## to the @var{alpha}-stable part of the original system @var{G}.
## The @var{ns} Hankel singular values are ordered decreasingly.
## @item nu
## The order of the @var{alpha}-unstable subsystem of both the original
## system @var{G} and the reduced-order system @var{Gr}.
## @item nr
## The order of the obtained reduced order system @var{Gr}.
## @end table
## @end table
##
## @strong{Options}
## @table @var
## @item "order", "n", "nr"
## The desired order of the resulting reduced order system @var{Gr}.
## If not specified, @var{nr} is the sum of NU and the number of
## Hankel singular values greater than @code{MAX(TOL1,NS*EPS)};
## @var{nr} can be further reduced to ensure that
## @code{HSV(NR-NU) > HSV(NR+1-NU)}.
## @item "equil", "scale"
## Boolean indicating whether equilibration (scaling) should be
## performed on system @var{G} prior to order reduction.
## Default value is true if @code{G.scaled == false} and
## false if @code{G.scaled == true}.
## @item "tol1"
## If @var{"order"} is not specified, @var{tol1} contains the tolerance for
## determining the order of reduced system.
## For model reduction, the recommended value of @var{tol1} lies
## in the interval [0.00001, 0.001].  @var{tol1} < 1.
## If @var{tol1} <= 0 on entry, the used default value is
## @var{tol1} = NS*EPS, where NS is the number of
## ALPHA-stable eigenvalues of A and EPS is the machine
## precision.
## If @var{"order"} is specified, the value of @var{tol1} is ignored.
## @item "tol2"
## The tolerance for determining the order of a minimal
## realization of the phase system (see METHOD) corresponding
## to the ALPHA-stable part of the given system.
## The recommended value is TOL2 = NS*EPS.  TOL2 <= TOL1 < 1.
## This value is used by default if @var{"tol2"} is not specified
## or if TOL2 <= 0 on entry.
## @item "approx", "approach"
## The order of the obtained system @var{Gr}.
##
##
## @item "alpha"
## Specifies the ALPHA-stability boundary for the eigenvalues
## of the state dynamics matrix @var{G.A}.  For a continuous-time
## system, ALPHA <= 0 is the boundary value for
## the real parts of eigenvalues, while for a discrete-time
## system, 0 <= ALPHA <= 1 represents the
## boundary value for the moduli of eigenvalues.
## The ALPHA-stability domain does not include the boundary.
## Default value is 0 for continuous-time systems and
## 1 for discrete-time systems.
## @item "beta"
## BETA > 0 specifies the absolute/relative error weighting
## parameter.  A large positive value of BETA favours the
## minimization of the absolute approximation error, while a
## small value of BETA is appropriate for the minimization
## of the relative error.
## BETA = 0 means a pure relative error method and can be
## used only if rank(G.D) = rows(G.D) which means that
## the feedthrough matrice must not be rank-deficient.
## @end table
##
## @strong{Algorithm}@*
## Uses SLICOT AB09HD by courtesy of
## @uref{http://www.slicot.org, NICONET e.V.}
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: October 2011
## Version: 0.1

function [sysr, info] = bstmodred (sys, varargin)

  if (nargin == 0)
    print_usage ();
  endif
  
  if (! isa (sys, "lti"))
    error ("bstmodred: first argument must be an LTI system");
  endif

  if (nargin == 2)
    varargin = __opt2cell__ (varargin{1});
  elseif (rem (nargin-1, 2))
    error ("bstmodred: properties and values must come in pairs");
  endif

  [a, b, c, d, tsam, scaled] = ssdata (sys);
  dt = isdt (sys);
  
  ## default arguments
  alpha = __modred_default_alpha__ (dt);
  beta = 1; # ?
  tol1 = 0; 
  tol2 = 0;
  ordsel = 1;
  nr = 0;
  job = 1;

  ## handle properties and values
  for k = 1 : 2 : (nargin-1)
    prop = lower (varargin{k});
    val = varargin{k+1};
    switch (prop)
      case {"order", "n", "nr"}
        [nr, ordsel] = __modred_check_order__ (val);

      case "tol1"
        tol1 = __modred_check_tol__ (val, "tol1");

      case "tol2"
        tol2 = __modred_check_tol__ (val, "tol2");

      case "alpha"
        alpha = __modred_check_alpha__ (val, dt);
        
      case "beta"
        if (! issample (val, 0))
          error ("bstmodred: argument %s must be BETA >= 0", varargin{k});
        endif
        beta = val;

      case {"approx", "approach"}    # approximation method
        switch (tolower (val))
          case {"sr-bta", "b"}       # 'B':  use the square-root Balance & Truncate method
            job = 0;
          case {"bfsr-bta", "f"}     # 'F':  use the balancing-free square-root Balance & Truncate method
            job = 1;
          case {"sr-spa", "s"}       # 'S':  use the square-root Singular Perturbation Approximation method
            job = 2;
          case {"bfsr-spa", "p"}     # 'P':  use the balancing-free square-root Singular Perturbation Approximation method
            job = 3; 
          otherwise
            error ("bstmodred: ""%s"" is an invalid approximation method", val);
        endswitch

      case {"equil", "equilibrate", "equilibration", "scale", "scaling"}
        scaled = __modred_check_equil__ (val);

      otherwise
        warning ("bstmodred: invalid property name ""%s"" ignored", prop);
    endswitch
  endfor
  
  ## perform model order reduction
  [ar, br, cr, dr, nr, hsv, ns] = slab09hd (a, b, c, d, dt, scaled, job, nr, ordsel, alpha, beta, \
                                            tol1, tol2);

  ## assemble reduced order model
  sysr = ss (ar, br, cr, dr, tsam);

  ## assemble info struct
  n = rows (a);
  nu = n - ns;
  info = struct ("n", n, "ns", ns, "hsv", hsv, "nu", nu, "nr", nr);

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

