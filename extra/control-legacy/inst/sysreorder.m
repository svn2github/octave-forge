## Copyright (C) 1996, 2000, 2002, 2004, 2005, 2007
##               Auburn University. All rights reserved.
##
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{pv} =} sysreorder (@var{vlen}, @var{list})
##
## @strong{Inputs}
## @table @var
## @item vlen
## Vector length.
## @item list
## A subset of @code{[1:vlen]}.
## @end table
##
## @strong{Output}
## @table @var
## @item pv
## A permutation vector to order elements of @code{[1:vlen]} in
## @code{list} to the end of a vector.
## @end table
##
## Used internally by @code{sysconnect} to permute vector elements to their
## desired locations.
## @end deftypefn

## Author: A. S. Hodel <a.s.hodel@eng.auburn.edu>
## Created: August 1995

function pv = sysreorder (vlen, list)

  if (nargin != 2)
    print_usage ();
  endif

  ## disp('sysreorder: entry')

  pv = 1:vlen;
  ## make it a row vector
  list = reshape(list,1,length(list));
  A = pv' * ones (size (list));
  B = ones (size (pv')) * list;
  X = (A != B);
  if (! isvector (X))
    y = min (X');
  else
   y = X';
  endif
  z = find (y == 1);
  if (! isempty (z))
    pv = [z, list];
  else
    pv = list;
  endif

endfunction
