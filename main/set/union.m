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
## @deftypefn {Function File} {} union(@var{a}, @var{b})
##
## Return the elements in both @var{a} and @var{b}, sorted in ascending
## order. If @var{a} and @var{b} are both column vectors return a column
## vector, otherwise return a row vector.
##
## @end deftypefn
## @seealso{unique, intersect, setdiff, setxor, ismember}

function c = union(a,b)
  if nargin != 2
    usage("union(a,b)");
  endif

  if isempty(a)
    c = unique(b);
  elseif isempty(b)
    c = unique(a);
  else
    ## concatenate the two sets (even if they have a different shape)
    c = unique([a(:) ; b(:)]);
    if size(a,1) == 1 || size(b,1) == 1
      c = c.';
    endif

  endif
endfunction
  