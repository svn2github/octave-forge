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
## @deftypefn{Function File} {[@var{sysr}, @var{nr}] =} __ab09id_modred__ (@var{method}, @dots{})
## Backend for btamodred and spamodred.
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: November 2011
## Version: 0.1

function [sysr, nr] = __ab09id_modred__ (method, varargin)

  if (nargin < 2)
    print_usage ();
  endif
  
  if (method != "bta" && method != "spa")
    error ("modred: invalid method");
  endif

  sys = varargin{1};
  varargin = varargin(2:end);
  npv = nargin - 2;             # number of properties and values
  
  if (! isa (sys, "lti"))
    error ("%smodred: first argument must be an LTI system", method);
  endif

  if (rem (npv, 2))
    error ("%smodred: properties and values must come in pairs", method);
  endif

  [a, b, c, d, tsam, scaled] = ssdata (sys);
  dt = isdt (sys);

  ## default arguments
  alphac = alphao = 0.0;
  tol1 = 0.0;
  tol2 = 0.0;
  dico = 0;
  jobc = jobo = 0;
  job = 1;
  weight = 1;
  equil = 0;
  ordsel = 1;
  nr = 0;
  
  if (dt)       # discrete-time
    alpha = 1;  # ALPHA <= 0
  else          # continuous-time
    alpha = 0;  # 0 <= ALPHA <= 1
  endif

  ## handle properties and values
  for k = 1 : 2 : npv
    prop = lower (varargin{k});
    val = varargin{k+1};
    switch (prop)
      case {"order", "n", "nr"}
        if (! issample (val, 0) || val != round (val))
          error ("%smodred: argument %s must be an integer >= 0", method, varargin{k});
        endif
        nr = val;
        ordsel = 0;

      case "tol1"
        if (! is_real_scalar (val))
          error ("%smodred: argument %s must be a real scalar", method, varargin{k});
        endif
        tol1 = val;

      case "tol2"
        if (! is_real_scalar (val))
          error ("%smodred: argument %s must be a real scalar", method, varargin{k});
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
  [ar, br, cr, dr] = slab09id (a, b, c, d, dico, equil, nr, ordsel, alpha, job, \
                               av, bv, cv, dv, \
                               aw, bw, cw, dw, \
                               weight, jobc, jobo, alphac, alphao, \
                               tol1, tol2)

  ## assemble reduced order model
  sysr = ss (ar, br, cr, dr, tsam);

endfunction




