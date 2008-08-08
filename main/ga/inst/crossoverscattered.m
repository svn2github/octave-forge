## Copyright (C) 2008 Luca Favatella <slackydeb@gmail.com>
##
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## This program  is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; see the file COPYING.  If not, write to the Free
## Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
## 02110-1301, USA.

## -*- texinfo -*-
## @deftypefn{Function File} {@var{xoverKids} =} crossoverscattered (@var{parents}, @var{options}, @var{nvars}, @var{FitnessFcn}, @var{unused}, @var{thisPopulation})
## Combine two individuals, or parents, to form a crossover child.
##
## @seealso{ga, gaoptimset}
## @end deftypefn

## Author: Luca Favatella <slackydeb@gmail.com>
## Version: 5.1.3

function xoverKids = \
      crossoverscattered (parents,
                          options, nvars, FitnessFcn, unused,
                          thisPopulation)

  ## example (nvars == 4)
  ## p1 = [varA varB varC varD]
  ## p2 = [var1 var2 var3 var4]
  ## b = [1 1 0 1]
  ## child1 = [varA varB var3 varD]
  p1 = parents(1, 1:nvars);
  p2 = parents(2, 1:nvars);
  b = randint (1, nvars);
  child1 = b .* p1 + (ones (1, nvars) - b) .* p2;

  xoverKids = child1;
endfunction

%!shared nvars, xoverKids
%! parents = [3.2 -34 51 64.21; 3.2 -34 51 64.21];
%! options = gaoptimset ();
%! nvars = 4;
%! FitnessFcn = false; ## this parameter is unused in the current implementation
%! unused = false;
%! thisPopulation = false; ## this parameter is unused in the current implementation
%! xoverKids = crossoverscattered (parents, options, nvars, FitnessFcn, unused, thisPopulation);
%!assert (size (xoverKids), [1, nvars]);
%!assert (xoverKids(1, 1:nvars), [3.2 -34 51 64.21]);