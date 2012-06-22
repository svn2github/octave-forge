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
## @deftypefn {Function File} {@var{sys} =} arx (@var{dat}, @var{na}, @var{nb})
## ARX
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: April 2012
## Version: 0.1

function [sys, varargout] = arx (dat, varargin)

  ## TODO: delays

  if (nargin < 2)
    print_usage ();
  endif
  
  if (! isa (dat, "iddata"))
    error ("arx: first argument must be an iddata dataset");
  endif

%  if (nargin > 2)                       # arx (dat, ...)
    if (is_real_scalar (varargin{1}))   # arx (dat, n, ...)
      varargin = horzcat (varargin(2:end), {"na"}, varargin(1), {"nb"}, varargin(1));
    endif
    if (isstruct (varargin{1}))         # arx (dat, opt, ...), arx (dat, n, opt, ...)
      varargin = horzcat (__opt2cell__ (varargin{1}), varargin(2:end));
    endif
%  endif

  nkv = numel (varargin);               # number of keys and values
  
  if (rem (nkv, 2))
    error ("arx: keys and values must come in pairs");
  endif


  ## p: outputs,  m: inputs,  ex: experiments
  [~, p, m, ex] = size (dat);           # dataset dimensions

  ## extract data  
  Y = dat.y;
  U = dat.u;
  tsam = dat.tsam;

  ## multi-experiment data requires equal sampling times  
  if (ex > 1 && ! isequal (tsam{:}))
    error ("arx: require equally sampled experiments");
  else
    tsam = tsam{1};
  endif
  
  
  ## default arguments
  na = [];
  nb = [];      % ???
  nk = [];

  ## handle keys and values
  for k = 1 : 2 : nkv
    key = lower (varargin{k});
    val = varargin{k+1};
    switch (key)
      ## TODO: proper argument checking
      case "na"
        na = val;
      case "nb"
        nb = val;
      case "nk"
        error ("nk");
      otherwise
        warning ("arx: invalid property name '%s' ignored", key);
    endswitch
  endfor


  if (is_real_scalar (na, nb))
    na = repmat (na, p, 1);                         # na(p-by-1)
    nb = repmat (nb, p, m);                         # nb(p-by-m)
  elseif (! (is_real_vector (na) && is_real_matrix (nb) \
          && rows (na) == p && rows (nb) == p && columns (nb) == m))
    error ("arx: require na(%dx1) instead of (%dx%d) and nb(%dx%d) instead of (%dx%d)", \
            p, rows (na), columns (na), p, m, rows (nb), columns (nb));
  endif

  max_nb = max (nb, [], 2);                         # one maximum for each row/output, max_nb(p-by-1)
  n = max (na, max_nb);                             # n(p-by-1)

  ## create empty cells for numerator and denominator polynomials
  % num = cell (p, m+p);
  % den = cell (p, m+p);
  num = cell (p, m);
  den = cell (p, m);

  ## MIMO (p-by-m) models are identified as pm SISO models
  ## For multi-experiment data, minimize the trace of the error
  for i = 1 : p                                     # for every output
    for j = 1 : m                                   # for every input
      Phi = cell (ex, 1);                           # one regression matrix per experiment
      for e = 1 : ex                                # for every experiment  
        ## avoid warning: toeplitz: column wins anti-diagonal conflict
        ## therefore set first row element equal to y(1)
        PhiY = toeplitz (Y{e}(1:end-1, i), [Y{e}(1, i); zeros(na(i,j)-1, 1)]);
        PhiU = toeplitz (U{e}(1:end-1, j), [U{e}(1, j); zeros(nb(i,j)-1, 1)]);
        Phi{e} = [-PhiY, PhiU](n(i):end, :);
      endfor

      ## compute parameter vector Theta
      Theta = __theta__ (Phi, Y, i, n);

      ## extract polynomials A and B from Theta
      A = [1; Theta(1:na(i,j))];                    # a0 = 1, a1 = Theta(1), an = Theta(n)
      B = [0; Theta(na(i,j)+1:end)];                 # b0 = 0 (leading zero required by filt)
      
      num(i,j) = A;
      den(i,j) = B;
      
      %{
      ## add error inputs
      Be = repmat ({0}, 1, p);                                # there are as many error inputs as system outputs (p)
      Be(i) = 1;                                              # inputs m+1:m+p are zero, except m+i which is one
      num(i, :) = [B, Be];                                    # numerator polynomials for output i, individual for each input
      den(i, :) = repmat ({A}, 1, m+p);                       # in a row (output i), all inputs have the same denominator polynomial
      %}
    endfor
  endfor

  %{
  ## A(q) y(t) = B(q) u(t) + e(t)
  ## there is only one A per row
  ## B(z) and A(z) are a Matrix Fraction Description (MFD)
  ## y = A^-1(q) B(q) u(t) + A^-1(q) e(t)
  ## since A(q) is a diagonal polynomial matrix, its inverse is trivial:
  ## the corresponding transfer function has common row denominators.
  %}

  sys = filt (num, den, tsam);                              # filt creates a transfer function in z^-1

  ## compute initial state vector x0 if requested
  ## this makes only sense for state-space models, therefore convert TF to SS
  if (nargout > 1)
    sys = prescale (ss (sys(:,1:m)));
    x0 = slib01cd (Y, U, sys.a, sys.b, sys.c, sys.d, 0.0);
    ## return x0 as vector for single-experiment data
    ## instead of a cell containing one vector
    if (numel (x0) == 1)
      x0 = x0{1};
    endif
    varargout{1} = x0;
  endif

endfunction


function theta = __theta__ (phi, y, i, n)
    
  if (numel (phi) == 1)                             # single-experiment dataset
    ## use "square-root algorithm"
    A = horzcat (phi{1}, y{1}(n(i)+1:end, i));      # [Phi, Y]
    R0 = triu (qr (A, 0));                          # 0 for economy-size R (without zero rows)
    R1 = R0(1:end-1, 1:end-1);                      # R1 is triangular - can we exploit this in R1\R2?
    R2 = R0(1:end-1, end);
    theta = __ls_svd__ (R1, R2);                    # R1 \ R2
    
    ## Theta = Phi \ Y(n+1:end, :);                 # naive formula
    ## theta = __ls_svd__ (phi{1}, y{1}(n(i)+1:end, i));
  else                                              # multi-experiment dataset
    ## TODO: find more sophisticated formula than
    ## Theta = (Phi1' Phi + Phi2' Phi2 + ...) \ (Phi1' Y1 + Phi2' Y2 + ...)
    
    ## covariance matrix C = (Phi1' Phi + Phi2' Phi2 + ...)
    tmp = cellfun (@(Phi) Phi.' * Phi, phi, "uniformoutput", false);
    % rc = cellfun (@rcond, tmp); # C auch noch testen? QR oder SVD?
    C = plus (tmp{:});

    ## PhiTY = (Phi1' Y1 + Phi2' Y2 + ...)
    tmp = cellfun (@(Phi, Y) Phi.' * Y(n(i)+1:end, i), phi, y, "uniformoutput", false);
    PhiTY = plus (tmp{:});
    
    ## pseudoinverse  Theta = C \ Phi'Y
    theta = __ls_svd__ (C, PhiTY);
  endif
  
endfunction


function x = __ls_svd__ (A, b)

  ## solve the problem Ax=b
  ## x = A\b  would also work,
  ## but this way we have better control and warnings

  ## solve linear least squares problem by pseudoinverse
  ## the pseudoinverse is computed by singular value decomposition
  ## M = U S V*  --->  M+ = V S+ U*
  ## Th = Ph \ Y = Ph+ Y
  ## Th = V S+ U* Y,   S+ = 1 ./ diag (S)

  [U, S, V] = svd (A, 0);                           # 0 for "economy size" decomposition
  S = diag (S);                                     # extract main diagonal
  r = sum (S > eps*S(1));
  if (r < length (S))
    warning ("arx: rank-deficient coefficient matrix");
    warning ("sampling time too small");
    warning ("persistence of excitation");
  endif
  V = V(:, 1:r);
  S = S(1:r);
  U = U(:, 1:r);
  x = V * (S .\ (U' * b));                          # U' is the conjugate transpose

endfunction