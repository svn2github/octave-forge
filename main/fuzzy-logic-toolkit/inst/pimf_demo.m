## Copyright (C) 2011 L. Markowsky <lmarkov@users.sourceforge.net>
##
## This file is part of the fuzzy-logic-toolkit.
##
## The fuzzy-logic-toolkit is free software; you can redistribute it
## and/or modify it under the terms of the GNU General Public License
## as published by the Free Software Foundation; either version 3 of
## the License, or (at your option) any later version.
##
## The fuzzy-logic-toolkit is distributed in the hope that it will be
## useful, but WITHOUT ANY WARRANTY; without even the implied warranty
## of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with the fuzzy-logic-toolkit; see the file COPYING.  If not,
## see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Script File} {} pimf_demo
##
## Demonstrate the function @t{pimf} by executing the code
## given in the comment at the top of pimf.m.
##
## @seealso{pimf}
## @end deftypefn

## Author:        L. Markowsky
## Keywords:      fuzzy-logic-toolkit fuzzy tests demos
## Directory:     fuzzy-logic-toolkit/inst
## Filename:      pimf_demo.m
## Version:       0.2
## Last-Modified: 19 May 2011

x = 0:255;
params = [70 80 100 140];
y1 = pimf(x, params);
params = [50 75 105 175];
y2 = pimf(x, params);
params = [30 70 110 200];
y3 = pimf (x, params);
figure ('NumberTitle', 'off', 'Name', 'pimf demo');
plot (x, y1, 'r;params = [70 80 100 140];', 'LineWidth', 2)
hold on;
plot (x, y2, 'b;params = [50 75 105 175];', 'LineWidth', 2)
hold on;
plot (x, y3, 'g;params = [30 70 110 200];', 'LineWidth', 2)
ylim ([-0.1 1.1]);
xlabel ('Crisp Input Value', 'FontWeight', 'bold');
ylabel ('Degree of Membership', 'FontWeight', 'bold');
grid;
