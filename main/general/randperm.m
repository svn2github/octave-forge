## Copyright (C) 2000  Stephen Eglen
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

## Return a random permutation of the integers 1 to N.
##
## Example:
## randperm(5)'
## ans = 1 4 5 3 2

## Author: Stephen Eglen <stephen@cogsci.ed.ac.uk>
## Source: http://www.che.wisc.edu/octave/mailing-lists/octave-sources/2000/39

function y = randperm(n)
  if nargin != 1
    usage("randperm (n)");
  endif
  [ordered_nums, y] = sort(rand(n,1));
endfunction
