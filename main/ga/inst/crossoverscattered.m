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

## Author: Luca Favatella <slackydeb@gmail.com>
## Version: 6.2.5

function xoverKids = crossoverscattered (parents, options, nvars, FitnessFcn,
                                         unused,
                                         thisPopulation)
  nc_parents = columns (parents);

  ## simplified example (nvars == 4)
  ## p1 = [varA varB varC varD]
  ## p2 = [var1 var2 var3 var4]
  ## b = [1 1 0 1]
  ## child1 = [varA varB var3 varD]
  n_children = nc_parents / 2;
  p1(1:n_children, 1:nvars) = \
      thisPopulation(parents(1, 1:n_children), 1:nvars);
  p2(1:n_children, 1:nvars) = \
      thisPopulation(parents(1, n_children + (1:n_children)), 1:nvars);
  b(1:n_children, 1:nvars) = randint (n_children, nvars);
  xoverKids(1:n_children, 1:nvars) = \
      b .* p1 + (ones (n_children, nvars) - b) .* p2;
endfunction