## Copyright (C) 2000 Paul Kienzle
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

## usage: isprime(n)
## Return true if n is a prime number, false otherwise.
##
## Something like the following is much faster if you need to test a lot
## of small numbers:
##    t = ismember (n, primes (max (n (:))));
## If max(n) is very large, then you should be using special purpose 
## factorization code.
##
## See also: primes, factor, gcd, lcm

function t = isprime(n)
  if !is_scalar(n)
    [nr, nc] = size(n);
    t = n;
    for i=1:nr
      for j=1:nc
	t(i,j) = isprime(t(i,j));
      endfor
    endfor
  elseif (n != fix(n) || n < 2)
    t = 0;
  elseif n < 9
    t = all(n!=[4,6,8]);
  else
    q = n./[2,3:2:sqrt(n)];
    t = all (q != fix(q));
  endif
endfunction
