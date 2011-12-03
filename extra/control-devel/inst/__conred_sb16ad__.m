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
## @deftypefn{Function File} {[@var{Kr}, @var{info}] =} __conred_sb16ad__ (@var{method}, @dots{})
## Backend for btaconred and spaconred.
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: December 2011
## Version: 0.1

function [Kr, info] = __conred_sb16ad__ (method, varargin)

  if (nargin < 3)
    print_usage ();
  endif
  
  if (method != "bta" && method != "spa")
    error ("modred: invalid method");
  endif

  G = varargin{1};
  K = varargin{2};
  varargin = varargin(3:end);
  
  if (! isa (G, "lti"))
    error ("%sconred: first argument must be an LTI system", method);
  endif

  if (! isa (K, "lti"))
    error ("%sconred: second argument must be an LTI system", method);
  endif

  if (nargin > 3)                                  # *conred (G, K, ...)
    if (is_real_scalar (varargin{1}))              # *conred (G, K, nr)
      varargin = horzcat (varargin(2:end), {"order"}, varargin(1));
    endif
    if (isstruct (varargin{1}))                    # *conred (G, K, opt, ...), *conred (G, K, nr, opt, ...)
      varargin = horzcat (__opt2cell__ (varargin{1}), varargin(2:end));
    endif
    ## order placed at the end such that nr from *conred (G, K, nr, ...)
    ## and *conred (G, K, nr, opt, ...) overrides possible nr's from
    ## key/value-pairs and inside opt struct (later keys override former keys,
    ## nr > key/value > opt)
  endif

  npv = numel (varargin);                          # number of properties and values

  if (rem (npv, 2))
    error ("%sconred: properties and values must come in pairs", method);
  endif

  [a, b, c, d, tsam, scaled] = ssdata (G);
  [ac, bc, cc, dc, tsamc, scaledc] = ssdata (K);
  [p, m] = size (G);
  [pc, mc] = size (K);
  dt = isdt (G);

  if (p != mc || m != pc)
    error ("%sconred: dimensions of controller (%dx%d) and plant (%dx%d) don't match", \
           method, pc, mc, p, c);
  endif


  ## default arguments
  alpha = __modred_default_alpha__ (dt);
  av = bv = cv = dv = [];
  jobv = 0;
  aw = bw = cw = dw = [];
  jobw = 0;
  alphac = alphao = 0.0;
  tol1 = 0.0;
  tol2 = 0.0;
  dico = 0;
  jobc = jobo = 0;
  bf = true;                                # balancing-free
  weight = 1;
  equil = 0;
  ordsel = 1;
  nr = 0;

  ## handle properties and values
  for k = 1 : 2 : npv
    prop = lower (varargin{k});
    val = varargin{k+1};
    switch (prop)
      case {"left", "v"}
        [av, bv, cv, dv, jobv] = __modred_check_weight__ (val, dt, p, []);

      case {"right", "w"}
        [aw, bw, cw, dw, jobw] = __modred_check_weight__ (val, dt, [], m);

      case {"order", "n", "nr"}
        [nr, ordsel] = __modred_check_order__ (val);

      case "tol1"
        tol1 = __modred_check_tol__ (val, "tol1");

      case "tol2"
        tol2 = __modred_check_tol__ (val, "tol2");

      case "alpha"
        alpha = __modred_check_alpha__ (val, dt);

      case "approach"
        switch (tolower (val))
          case "sr"
            bf = false;
          case "bfsr"
            bf = true;
          otherwise
            error ("modred: ""%s"" is an invalid approach", val);
        endswitch

      ## TODO: alphac, alphao, jobc, jobo

      otherwise
        warning ("modred: invalid property name ""%s"" ignored", prop);
    endswitch
  endfor

  ## handle type of frequency weighting
  if (jobv && jobw)
    weight = 3;                             # 'B':  both left and right weightings V and W are used
  elseif (jobv)
    weight = 1;                             # 'L':  only left weighting V is used (W = I)
  elseif (jobw)
    weight = 2;                             # 'R':  only right weighting W is used (V = I)
  else
    weight = 0;                             # 'N':  no weightings are used (V = I, W = I)
  endif
  
  ## handle model reduction approach
  if (method == "bta" && ! bf)              # 'B':  use the square-root Balance & Truncate method
    job = 0;
  elseif (method == "bta" && bf)            # 'F':  use the balancing-free square-root Balance & Truncate method
    job = 1;
  elseif (method == "spa" && ! bf)          # 'S':  use the square-root Singular Perturbation Approximation method
    job = 2;
  elseif (method == "spa" && bf)            # 'P':  use the balancing-free square-root Singular Perturbation Approximation method
    job = 3;
  else
    error ("modred: invalid job option");   # this should never happen
  endif
  
  
  ## perform model order reduction
  [acr, bcr, ccr, dcr, ncr, hsvc, ncs] = slsb16ad (a, b, c, d, dico, equil, ncr, ordsel, alpha, jobmr, \
                                                   ac, bc, cc, dc, \
                                                   weight, jobc, jobo, tol1, tol2);

  ## assemble reduced order controller
  Kr = ss (acr, bcr, ccr, dcr, tsamc);

  ## assemble info struct  
  info = struct ("ncr", ncr, "ncs", ncs, "hsvc", hsvc);

endfunction




