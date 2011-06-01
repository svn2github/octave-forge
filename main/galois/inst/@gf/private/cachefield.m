## Copyright (C) 2011 David Bateman
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
## along with this program; If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn  {Function File} {[@var{alpha_to}, @var{index_of}] =} cachefield (@var{m}, @var{p})
## Undocumented internal function
## @end deftypefn

function [alpha_to, index_of] = cachefield (m, p)
  persistent cache_field;

  if (nargin < 1 || nargin > 2)
    print_usage ();
  endif

  if (nargin == 1)
    p = primpoly (m);
  endif

  if (! exist ("cache_field", "var"))
    cache_field = struct ("m", {}, "p", {}, "alpha_to", {}, "index_of", {});
  endif

  nel = numel (cache_field);

  ## Find if we've already cached the values of alpha_to, index_of
  for i = 1 : nel
    if (cache_field(i)._m == m && cache_field(i).p == p)
      alpha_to = cache_field(i).alpha_to;
      index_of = cache_field(i).index_of;
      return;
    endif
  endfor

  n = 2.^m - 1;
  alpha_to = zeros (2.^m, 1);

  ## Put an illegal value in index_of and if it is still there after fill
  ## we have a reducible polynomial
  index_of = (n + 1) .* ones (2.^m, 1);

  index_of (1) = n;
  alpha_to (n + 1) = 0;
  mask = 1;
  for i = 1 : n
    index_of (mask + 1) = i - 1;
    alpha_to (i) = mask;
    mask = 2 * mask;
    if (mask > n)
      mask = bitxor (mask, p);
    endif
    mask = bitand (mask, n);
  endfor

  if (mask != 1)
    error ("primitive polynomial (%d) of Galois Field must be irreducible", p);
  endif

  for i = 1 : n + 1
    if (index_of (i) > n)
      error ("primitive polynomial (%d) of Galois Field must be irreducible", p);
    endif
  endfor      

  cache_feild(nel+1).m = m;
  cache_feild(nel+1).p = p;
  cache_feild(nel+1).alpha_to = alpha_to;
  cache_feild(nel+1).index_of = index_of;
endfunction
