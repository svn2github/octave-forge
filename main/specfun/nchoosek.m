## Copyright (c) 1998 Mike Brookes
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

## c = nchoosek(n, k)
##    return c = n!/(k! (n-k)!)
## A = nchoosek(v, k)
##    generate all combinations of the elements of vector v taken k at a
##    time, one row per combination. The resulting A has size
##    nchoosek(n,k) x k, where n is the length of v.

## Author: Mike Brookes <mike.brookes@ic.ac.uk>
## From VOICEBOX <http://www.ee.ic.ac.uk/hp/staff/dmb/voicebox/voicebox.html>
## 2001-02-28 Paul Kienzle
##    * converted for use in Octave
##    * renamed from choosenk to nchoosek for compatibility
##    * choose from vector rather than generating choice indices

function A = nchoosek(v,k)

  if (nargin != 2)
    usage("A = nchoosek(v,k)");
  endif

  n = length(v);
  if n == 1
    A = prod(k+1:v)/prod(1:v-k);
  elseif k == 0
    A = [];
  elseif k == 1
    A = v(:);
  elseif k == n-1
    A = v(:).';
    A = reshape (A(ones(n-1,1),:), n, n-1);
  elseif k == n
    A = v(:)';
  else
    v = v(:);
    kk = min(k,n-k);
    n1 = n+1;
    m = prod(n1-kk:n) / prod(1:kk);
    x = zeros (m,k);
    f = n1-k;
    A(1:f,k) = v(k:n);
    for a = k-1:-1:1
      d = h = f;
      A(1:f,a) = v(a);
      for b = a+1 : a+n-k
        d = d*(n1+a-b-k)/(n1-b);
        e = f+1;
        f = e+d-1;
        A(e:f,a) = v(b);
        A(e:f,a+1:k) = A(h-d+1:h,a+1:k);
      end
    end
  endif
endfunction