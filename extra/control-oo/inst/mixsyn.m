## Copyright (C) 2009   Lukas F. Reichlin
##
## This file is part of LTI Syncope.
##
## LTI Syncope is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## LTI Syncope is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program. If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn{Function File} {[@var{K}, @var{N}, @var{gamma}] =} mixsyn (@var{G}, @var{W1}, @var{W2}, @var{W3})
## Solve stacked S/T/KS problem.
## TODO: doc
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: December 2009
## Version: 0.1

function [K, N, gamma] = mixsyn (G, W1 = [], W2 = [], W3 = [], gmax = 1e6)

  if (nargin == 0 || nargin > 5)
    print_usage ();
  endif

  [p, m] = size (G);

  P = augw (G, W1, W2, W3);
  
  [K, N, gamma] = hinfsyn (P, p, m, gmax);

endfunction