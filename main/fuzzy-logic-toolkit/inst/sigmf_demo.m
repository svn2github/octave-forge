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
## @deftypefn {Script File} {} sigmf_demo
##
## Demonstrate the function @t{sigmf} by executing the code
## given in the comment at the top of sigmf.m.
##
## @seealso{sigmf}
## @end deftypefn

## Author:        L. Markowsky
## Keywords:      fuzzy-logic-toolkit fuzzy tests demos
## Directory:     fuzzy-logic-toolkit/inst
## Filename:      sigmf_demo.m
## Version:       0.2
## Last-Modified: 19 May 2011

x = 0:100;
params = [0.3 40];
y1 = sigmf (x, params);
params = [0.2 40];
y2 = sigmf (x, params);
params = [0.1 40];
y3 = sigmf (x, params);
figure ('NumberTitle', 'off', 'Name', 'sigmf demo');
plot (x, y1, 'r;params = [0.3 40];', 'LineWidth', 2)
hold on;
plot (x, y2, 'b;params = [0.2 40];', 'LineWidth', 2)
hold on;
plot (x, y3, 'g;params = [0.1 40];', 'LineWidth', 2)
ylim ([-0.1 1.2]);
xlabel ('Crisp Input Value', 'FontWeight', 'bold');
ylabel ('Degree of Membership', 'FontWeight', 'bold');
grid;
