## Copyright (C) 2001 Ian Searle
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

## [U, T] = rsf2csf(U,T)
##
## Converts a real, upper quasi-triangular Schur form to a complex, 
## upper triangular Schur form.
##
## Note that in a Schur decomposition, the following relations hold:
##
##     U*T*U' == A and U'*U == I.
##
## Note also that U and T are not unique.
##
## Alternatively, you can use the following to get the complex schur
## form for real A directly:
##
##    [U, T] = schur(1i*A);
##    T = -1i*T;
##

## 2001-03-07 Ross Lippert
##   * adapted from rlab, using a slightly different similarity transform
## 2001-03-08 Paul Kienzle
##   * cleanup; add Rolf Fabians comment about direct csf computation

function [U, T] = rsf2csf (U, T)

  if (nargin != 2)
    usage ("[U,T] = rsf2csf (U, T)");
  endif

  ## Find complex unitary similarities to zero the subdiagonal elements.
  n = columns (T);
  if (n > 1)
    idx = find (diag (T, -1))';
    for m = idx
      k = m:m+1;
      d = eig (T (k, k));
      cs = [ T(m+1,m+1)-d(1), -T(m+1,m) ];
      cs = cs / norm (cs);
      G = [ conj(cs); cs(2), -cs(1) ];
      T (k, m:n) = G' * T (k, m:n);
      T (1:m+1, k) = T (1:m+1, k) * G;
      U (:, k) = U (:, k) * G;
      T (m+1, m) = 0;
    endfor
  endif

endfunction
