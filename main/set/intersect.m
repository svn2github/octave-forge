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

## -*- texinfo -*-
## @deftypefn {Function File} {} intersect(@var{a}, @var{b})
##
## Return the elements in both @var{a} and @var{b}, sorted in ascending
## order. If @var{a} and @var{b} are both column vectors return a column
## vector, otherwise return a row vector.
##
## @deftypefnx {Function File} {[@var{c}, @var{ia}, @var{ib}] = } intersect (@var{a}, @var{b})
##
## Return index vectors @var{ia} and @var{ib} such that @code{a(ia)==c} and
## @code{b(ib)==c}.
##
## @end deftypefn
## @seealso{unique, union, setxor, setdiff, ismember}

function [c,ia,ib] = intersect(a,b)
  if ( nargin != 2 )
    usage ("intersect (a, b)");
  endif

  if ( isempty (a) || isempty (b) )
    c = []; ia = []; ib = [];
    return;
  endif

  ## form a and b into sets
  [a,ja] = unique (a);
  [b,jb] = unique (b);

  c = [ a(:); b(:) ];
  [c, ic] = sort( c );              ## [a(:);b(:)](ic) == c
  
  ii = find( c(1:end-1) == c(2:end) );  

  c  = c(ii);                       ## The answer
  ia = ja(ic(ii));                  ## a(ia) == c
  ib = jb(ic(ii+1) - length(a));    ## b(ib) == c

    
  if ( size (b, 1) == 1 || size (a, 1) == 1 )
    c = c.';
  endif


endfunction


%!# Test the routine for index vectors ia and ib
%!test
%! a = [3 2 4 5 7 6 5 1 0 13 13];
%! b = [3 5 12 1 1 7];
%! [c,ia,ib] = intersect(a,b);
%! assert( c,[1 3 5 7]);
%! assert(ia,[8 1 7 5]);
%! assert(ib,[5 1 2 6]);
%! assert(a(ia),c);
%! assert(b(ib),c);
