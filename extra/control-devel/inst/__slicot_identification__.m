## Copyright (C) 2012   Lukas F. Reichlin
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
## @deftypefn{Function File} {[@var{sys}, @var{x0}], @var{info} =} __slicot_identification__ (@var{method}, @var{dat}, @dots{})
## Backend for moesp, moen4 and n4sid.
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: May 2012
## Version: 0.1

function [sys, x0, info] = __slicot_identification__ (method, dat, varargin)

  ## determine identification method
  switch (method)
    case "moesp"
      meth = 0;
    case "n4sid"
      meth = 1;
    case "moen4"
      meth = 2;
    otherwise
      error ("ident: invalid method");  # should never happen
  endswitch

  if (! isa (dat, "iddata"))
    error ("%s: first argument must be an 'iddata' dataset", method);
  endif
  
  if (nargin > 2)                       # ident (dat, ...)
    if (is_real_scalar (varargin{1}))   # ident (dat, n, ...)
      varargin = horzcat (varargin(2:end), {"order"}, varargin(1));
    endif
    if (isstruct (varargin{1}))         # ident (dat, opt, ...), ident (dat, n, opt, ...)
      varargin = horzcat (__opt2cell__ (varargin{1}), varargin(2:end));
    endif
  endif
  
  nkv = numel (varargin);               # number of keys and values
  
  if (rem (nkv, 2))
    error ("%s: keys and values must come in pairs", method);
  endif

  [ns, p, m, e] = size (dat);           # dataset dimensions
  tsam = dat.tsam;
  
  ## multi-experiment data requires equal sampling times  
  if (e > 1 && ! isequal (tsam{:}))
    error ("%s: require equally sampled experiments", method);
  else
    tsam = tsam{1};
  endif
  
  ## default arguments
  alg = 0;
  conct = 1;                            # no connection between experiments
  ctrl = 1;                             # don't confirm order n
  rcond = 0.0;
  tol = -1.0; % 0;
  s = [];
  n = [];
  conf = [];
  noise = "n";
  
  ## handle keys and values
  for k = 1 : 2 : nkv
    key = lower (varargin{k});
    val = varargin{k+1};
    switch (key)
      ## TODO: proper argument checking
      case {"n", "order"}
        n = val;
      case "s"
        s = val;
      case {"alg", "algorithm"}
        error ("alg");
      case "tol"
        tol = val;
      case "rcond"
        rcond = val;
      case "confirm"
        conf = logical (val);
      case "noise"
        ## FIXME: find a more speaking name than 'noise' for this option
        noise = val;
      otherwise
        warning ("%s: invalid property name '%s' ignored", method, key);
    endswitch
  endfor
  

  ## handle s/nobr and n
  nsmp = sum (ns);                      # total number of samples
  nobr = fix ((nsmp+1)/(2*(m+p+1)));
  if (e > 1)
    nobr = min (nobr, fix (min (ns) / 2));
  endif
  
  if (isempty (s) && isempty (n))
    ctrl = 0;                           # confirm system order estimate
    n = 0;
  elseif (isempty (s))
    s = min (2*n, n+10);                # upper bound for n
    nobr = min (nobr, s);
  elseif (isempty (n))
    nobr = __check_s__ (s, nobr, method);
    ctrl = 0;                           # confirm system order estimate
    n = 0;
  else                                  # s & n non-empty
    nobr = __check_s__ (s, nobr, method);
    if (n >= nobr)
      error ("%s: n=%d, but require n < %d (s)", method, n, nobr);
    endif
  endif

  if (! isempty (conf))
    ctrl = ! conf;
  endif
  
  ## perform system identification
  [a, b, c, d, q, ry, s, k, x0] = slident (dat.y, dat.u, nobr, n, meth, alg, conct, ctrl, rcond, tol);

  ## compute noise variance matrix factor L
  ## L L' = Ry,  e = L v
  ## v becomes white noise with identity covariance matrix
  l = chol (ry, "lower");

  ## assemble model
  [inname, outname] = get (dat, "inname", "outname");
  if (strncmpi (noise, "e", 1))         # add error inputs e, not normalized
    sys = ss (a, [b, k], c, [d, eye(p)], tsam);
    in_u = __labels__ (inname, "u");
    in_e = __labels__ (outname, "y");
    in_e = cellfun (@(x) ["e@", x], in_e, "uniformoutput", false);
    inname = [in_u; in_e];
  elseif (strncmpi (noise, "v", 1))     # add error inputs v, normalized
    sys = ss (a, [b, k*l], c, [d, l], tsam);
    in_u = __labels__ (inname, "u");
    in_v = __labels__ (outname, "y");
    in_v = cellfun (@(x) ["v@", x], in_v, "uniformoutput", false);
    inname = [in_u; in_v];
  elseif (strncmpi (noise, "k", 1))     # Kalman predictor
    sys = ss ([a-k*c], [b-k*d, k], c, [d, zeros(p)], tsam);
    in_u = __labels__ (inname, "u");
    in_y = __labels__ (outname, "y");
    inname = [in_u; in_y];
  else                                  # no error inputs, default
    sys = ss (a, b, c, d, tsam);
  endif

  sys = set (sys, "inname", inname, "outname", outname);

  ## return x0 as vector for single-experiment data
  ## instead of a cell containing one vector
  if (numel (x0) == 1)
    x0 = x0{1};
  endif
  
  ## assemble info struct
  ## Kalman gain matrix K
  ## state covariance matrix Q
  ## output covariance matrix Ry
  ## state-output cross-covariance matrix S
  ## noise variance matrix factor L
  info = struct ("K", k, "Q", q, "Ry", ry, "S", s, "L", l);

endfunction


function nobr = __check_s__ (s, nobr, method)

  if (s <= nobr)
    nobr = s;
  else
    error ("%s: require upper bound s <= %d, but the requested s is %d", method, nobr, s);
  endif

endfunction
