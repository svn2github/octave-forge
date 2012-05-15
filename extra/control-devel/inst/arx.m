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

function sys = arx (dat, na, nb)

  ## TODO: delays

  if (nargin != 3)
    print_usage ();
  endif
  
  if (! isa (dat, "iddata"))
    error ("arx: first argument must be an iddata dataset");
  endif

  ## p: outputs,  m: inputs,  ex: experiments
  [~, p, m, ex] = size (dat);

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

  
  if (is_real_scalar (na, nb))
    na = repmat (na, p, 1);     # na(p-by-1)
    nb = repmat (nb, p, m);     # nb(p-by-m)
  elseif (! (is_real_vector (na) && is_real_matrix (nb) \
          && rows (na) == p && rows (nb) == p && columns (nb) == m))
    error ("arx: require na(%dx1) instead of (%dx%d) and nb(%dx%d) instead of (%dx%d)", \
            p, rows (na), columns (na), p, m, rows (nb), columns (nb));
  endif

  max_nb = max (nb, [], 2);     # one maximum for each row/output, max_nb(p-by-1)
  n = max (na, max_nb);         # n(p-by-1)


  num = cell (p, m+1);
  den = cell (p, m+1);
  
  for i = 1 : p     # for every output
    Phi = cell (1, ex);
    for e = 1 : ex      # for every experiment  
      ## avoid warning: toeplitz: column wins anti-diagonal conflict
      ## therefore set first row element equal to y(1)
      PhiY = toeplitz (Y{e}(1:end-1, i), [Y{e}(1, i); zeros(na(i)-1, 1)]);
      ## create MISO Phi for every experiment
      PhiU = arrayfun (@(x) toeplitz (U{e}(1:end-1, x), [U{e}(1, x); zeros(nb(i,x)-1, 1)]), 1:m, "uniformoutput", false);
      Phi{e} = (horzcat (-PhiY, PhiU{:}))(n(i):end, :);
    endfor
  
    Theta = __theta__ (Phi, Y, i, n);
      
    A = [1; Theta(1:na(i))];                     # a0 = 1, a1 = Theta(1), an = Theta(n)
    ThetaB = Theta(na(i)+1:end);                 # b0 = 0 (leading zero required by filt)
    B = mat2cell (ThetaB, nb(i,:));
    B = reshape (B, 1, []);
    B = cellfun (@(x) [0; x], B, "uniformoutput", false);

    num(i, :) = [B, {1}];
    den(i, :) = repmat ({A}, 1, m+1);
  endfor

  sys = filt (num, den, tsam);

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
    rc = cellfun (@rcond, tmp); # C auch noch testen? QR oder SVD?
    C = plus (tmp{:});
    
    ## PhiTY = (Phi1' Y1 + Phi2' Y2 + ...)
    tmp = cellfun (@(Phi, Y) Phi.' * Y(n(i)+1:end, i), phi, y, "uniformoutput", false);
    PhiTY = plus (tmp{:});
    
    ## pseudoinverse  Theta = C \ Phi'Y
    theta = __ls_svd__ (C, PhiTY);
  endif
  
endfunction


function x = __ls_svd__ (A, b)

  ## solve linear least squares problem by pseudoinverse
  ## the pseudoinverse is computed by singular value decomposition
  ## M = U S V*  --->  M+ = V S+ U*
  ## Th = Ph \ Y = Ph+ Y
  ## Th = V S+ U* Y,   S+ = 1 ./ diag (S)

  [U, S, V] = svd (A, 0);                         # 0 for "economy size" decomposition
  S = diag (S);                                   # extract main diagonal
  r = sum (S > eps*S(1));
  if (r < length (S))
    warning ("arx: rank-deficient coefficient matrix");
    warning ("sampling time too small");
    warning ("persistence of excitation");
  endif
  V = V(:, 1:r);
  S = S(1:r);
  U = U(:, 1:r);
  x = V * (S .\ (U' * b));                    # U' is the conjugate transpose

endfunction
