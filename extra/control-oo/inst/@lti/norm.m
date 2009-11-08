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
## Return norm of LTI model.
## @end deftypefn

## Author: A. S. Hodel <a.s.hodel@eng.auburn.edu>
## Created: August 1995
## Reference: Doyle, Glover, Khargonekar, Francis
##            State-Space Solutions to Standard Control Problems
##            IEEE TAC August 1989

## Adapted-By: Lukas Reichlin <lukas.reichlin@gmail.com>
## Date: November 2009
## Version: 0.1

function gain = norm (sys, ntype = "2", tol = 0.001)

  if (nargin > 3)  # norm () is catched by built-in function
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
      gain = hinfnorm (sys, tol);

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


function g = hinfnorm (sys, tol = 0.001, gmin = 1e-9, gmax = 1e9, ptol = 1e-9)

  if (isstable (sys))

    [A, B, C, D, tsam] = ssdata (sys);
    n = rows (A);     # states
    m = columns (B);  # inputs
    p = rows (C);     # outputs
    dflg = (tsam > 0);

    Dnrm = norm (D);
    if (nargin < 3)
      gmin = max (gmin, Dnrm);  # min gain value
    elseif (gmin < Dnrm)
      warning ("hinfnorm: setting Gmin=||D||=%g", Dnrm);
    endif

    In = eye (n);
    Im = eye (m);
    Ip = eye (p);

    ## find the Hinf norm via binary search
    while (gmax/gmin - 1 > tol)
      g = (gmax+gmin)/2;

      if (dflg)
        ## multiply g's through in formulas to avoid extreme magnitudes...
        Rg = g^2*Im - D'*D;
        Ak = A + (B/Rg)*D'*C;
        Ck = g^2*C'*((g^2*Ip-D*D')\C);

        ## set up symplectic generalized eigenvalue problem per Iglesias & Glover
        s1 = [Ak , zeros(n); -Ck, In];
        s2 = [In, -(B/Rg)*B'; zeros(n), Ak'];

        ## guard against roundoff again: zero out extremely small values
        ## prior to balancing
        s1 = s1 .* (abs(s1) > ptol*norm(s1,"inf"));
        s2 = s2 .* (abs(s2) > ptol*norm(s2,"inf"));
        [cc, dd, s1, s2] = balance (s1, s2);
        [qza, qzb, zz, pls] = qz (s1, s2, "S"); # ordered qz decomposition
        eigerr = abs (abs(pls)-1);
        normH = norm ([s1, s2]);
        Hb = [s1, s2];

        ## check R - B' X B condition (Iglesias and Glover's paper)
        X = zz((n+1):(2*n),1:n)/zz(1:n,1:n);
        dcondfailed = min (real (eig (Rg - B'*X*B)) < ptol);
      else
        Rinv = inv(g*g*Im - (D' * D));
        H = [A + B*Rinv*D'*C,        B*Rinv*B';
             -C'*(Ip + D*Rinv*D')*C, -(A + B*Rinv*D'*C)'];

        ## guard against roundoff: zero out extremely small values prior
        ## to balancing
        H = H .* (abs (H) > ptol * norm (H, "inf"));
        [DD, Hb] = balance (H);
        pls = eig (Hb);
        eigerr = abs (real (pls));
        normH = norm (H);
        dcondfailed = 0;          # digital condition; doesn't apply here
      endif

      if ((min (eigerr) <= ptol * normH) | dcondfailed)
        gmin = g;
      else
        gmax = g;
      endif
    endwhile

  else
    warning ("norm: Hinf: unstable system (ptol=%g), returning Inf", ptol);
    g = Inf;
  endif

endfunction

