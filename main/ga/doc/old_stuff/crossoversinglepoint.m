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
## @deftypefn{Function File} {@var{xoverKids} =} crossoversinglepoint (@var{parents}, @var{options}, @var{nvars}, @var{FitnessFcn}, @var{unused}, @var{thisPopulation})
## Combine two individuals, or parents, to form a crossover child.
##
## @seealso{ga, gaoptimset}
## @end deftypefn

## Author: Luca Favatella <slackydeb@gmail.com>
## Version: 5.1.2

function xoverKids = \
      crossoversinglepoint (parents,
                            options, nvars, FitnessFcn, unused,
                            thisPopulation)

  ## example (nvars == 4)
  ## p1 = [varA varB varC varD]
  ## p2 = [var1 var2 var3 var4]
  ## n = 1 ## integer between 1 and nvars
  ## child1 = [varA var2 var3 var4]
  p1 = parents(1, 1:nvars);
  p2 = parents(2, 1:nvars);
  n = randint (1, 1, [1, nvars]);
  child1 = horzcat (p1(1, 1:n),
                    p2(1, n+1:nvars));

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