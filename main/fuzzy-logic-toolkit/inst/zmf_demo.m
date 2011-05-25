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
## @deftypefn {Script File} {} zmf_demo
## Demonstrate the function @t{zmf} by executing the code
## given in the comment at the top of zmf.m.
##
## @seealso{zmf}
## @end deftypefn

## Author:        L. Markowsky
## Keywords:      fuzzy-logic-toolkit fuzzy tests demos
## Directory:     fuzzy-logic-toolkit/inst
## Filename:      zmf_demo.m
## Version:       0.2
## Last-Modified: 19 Apr 2011

x = 0:100;
params = [40 60];
y1 = zmf (x, params);
params = [25 75];
y2 = zmf (x, params);
params = [10 90];
y3 = zmf (x, params);
figure ('NumberTitle', 'off', 'Name', 'zmf demo');
plot (x, y1, 'r;params = [40 60];', 'LineWidth', 2)
hold on;
plot (x, y2, 'b;params = [25 75];', 'LineWidth', 2)
hold on;
plot (x, y3, 'g;params = [10 90];', 'LineWidth', 2)
ylim ([-0.1 1.1]);
xlabel ('Crisp Input Value', 'FontWeight', 'bold');
ylabel ('Degree of Membership', 'FontWeight', 'bold');
grid;
