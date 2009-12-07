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
## @deftypefn{Function File} {@var{P} =} hinfsyn (@var{G}, @var{W1}, @var{W2}, @var{W3})
## Extend plant for stacked S/T/KS problem.
## @example
## @group
##
##     | W1 | -W1*G |     z1 = W1 r  -  W1 G u
##     | 0  |  W2   |     z2 =          W2   u
## P = | 0  |  W3*G |     z3 =          W3 G u
##     |----+-------|
##     | I  |    -G |     e  =    r  -     G u
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

function P = augw (G, W1 = [], W2 = [], W3 = [])

  if (nargin == 0 || nargin > 4)
    print_usage ();
  endif

  G = ss (G);
  W1 = ss (W1);
  W2 = ss (W2);
  W3 = ss (W3);

  [p, m] = size (G);
  [p1, m1] = size (W1)
  [p2, m2] = size (W2);
  [p3, m3] = size (W3);

  if (m1 != 0 && m1 != p)
    error ("augw: W1 must have %d inputs", p);
  endif

  if (m2 != 0 && m2 != m)
    error ("augw: W2 must have %d inputs", m);
  endif

  if (m3 != 0 && m3 != p)
    error ("augw: W3 must have %d inputs", p);
  endif

  ## Pr = [1; 0; 0; 1];
  ## Pu = [-1; 0; 1; -1]*G + [0; 1; 0; 0];

  Pr = ss ([eye(m1,p)  ;
            zeros(m2,p);
            zeros(m3,p);
            eye(p,p)   ]);

  Pu1 = ss ([-eye(m1,p)  ;
              zeros(m2,p);
              eye(m3,p)  ;
             -eye(p,p)   ]);

  Pu2 = ss ([zeros(m1,m);
             eye(m2,m)  ;
             zeros(m3,m);
             zeros(p,m) ]);

  Pu = Pu1 * G  +  Pu2;

  P = append (W1, W2, W3, eye (p, p)) * [Pr, Pu];

endfunction