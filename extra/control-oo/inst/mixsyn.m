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
## Solve stacked S/T/KS H-inf problem, i.e. bound the largest singular values
## of S (for performance), T (for robustness and to avoid sensitivity to noise)
## and K S (to penalize large inputs).
## @example
## @group
##
##                             | W1 S   |
## min||N(K)||             N = | W2 K S | = lft (P, K)
##  K         inf              | W3 T   |
##                                                       +------+  z1
##             +---------------------------------------->|  W1  |----->
##             |                                         +------+
##             |                                         +------+  z2
##             |                 +---------------------->|  W2  |----->
##             |                 |                       +------+
##  r   +    e |   +--------+  u |   +--------+  y       +------+  z3
## ----->(+)---+-->|  K(s)  |----+-->|  G(s)  |----+---->|  W3  |----->
##        ^ -      +--------+        +--------+    |     +------+
##        |                                        |
##        +----------------------------------------+
##
##                +--------+
##                |        |-----> z1 (p1x1)
##  r (px1) ----->|  P(s)  |-----> z2 (p2x1)
##                |        |-----> z3 (p3x1)
##  u (mx1) ----->|        |-----> e (px1)
##                +--------+
##
##                +--------+  
##        r ----->|        |-----> z
##                |  P(s)  |
##        u +---->|        |-----+ e
##          |     +--------+     |
##          |                    |
##          |     +--------+     |
##          +-----|  K(s)  |<----+
##                +--------+
##
##                +--------+      
##        r ------|  N(s)  |-----> z
##                +--------+
## Reference:
## Skogestad, S. and Postlethwaite I.
## Multivariable Feedback Control: Analysis and Design
## Second Edition
## Wiley 2005
## Chapter 3.8: General Control Problem Formulation
## @end group
## @end example
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: December 2009
## Version: 0.1

function [K, N, gamma] = mixsyn (G, W1 = [], W2 = [], W3 = [], varargin)

  if (nargin == 0)
    print_usage ();
  endif

  [p, m] = size (G);

  P = augw (G, W1, W2, W3);
  
  [K, N, gamma] = hinfsyn (P, p, m, varargin{:});

endfunction