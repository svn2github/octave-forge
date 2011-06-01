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
## @deftypefn {Function File} {} minpol (@var{v})
##
## Finds the minimum polynomial for elements of a Galois Field. For  a 
## vector @var{v} with @math{N} components, representing @math{N} values 
## in a Galois Field GF(2^@var{m}), return the minimum polynomial in GF(2)
## representing those values.
## @end deftypefn

function r = minpol (v)

  if (nargin != 1)
    print_usage();
  endif

  if (!isgalois(v))
    error("minpol: argument must be a galois variable");
  endif

  if (min (size (v)) > 1 || nargin != 1)
    usage ("minpol (v), where v is a galois vector");
  endif

  n = length (v);
  m = v._m;
  prim_poly = v._prim_poly;
  r = zeros(n,m+1);

  ## Find cosets of GF(2^m) and convert from cell array to matrix
  cyclocoset = cosets(m, prim_poly);
  lencoset = max(cellfun(@length,cyclocoset));
  cyclomat = gf(zeros(lencoset, m), m, prim_poly);
  for j=1:lencoset
    cyclomat._x(j, 1:length(cyclocoset{j})) = cyclocoset{j}._x;
  endfor

  for j =1:n
    if (v(j) == 0)
      ## Special case
      r(j,m-1) = 1;
    else
      ## Find the coset within which the current element falls
      [rc, ignored] = find(cyclomat == v(j));

      rv = cyclomat._x(rc,:);

      ## Create the minimum polynomial from its roots 
      ptmp = gf([1,rv(1)], m, prim_poly);
      for i=2:length(rv)
        ptmp = conv(ptmp, gf([1,rv(i)], m, prim_poly));
      endfor

      ## Need to left-shift polynomial to divide by x while can
      i = 0;
      while (!ptmp._x(m+1-i))
        i = i + 1;
      endwhile
      ptmp._x = [zeros(1,i), ptmp._x(1:m+1-i)];
      r(j,:) = ptmp._x;
    endif
  endfor

  ## Ok, now put the return value into GF(2)
  r = gf(r,1);
  
endfunction

%!assert(minpol(gf(2,3)),gf([1,0,1,1]))
