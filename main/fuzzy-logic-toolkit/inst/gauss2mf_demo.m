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
## @deftypefn {Script File} {} gauss2mf_demo
##
## Demonstrate the function @t{gauss2mf} by executing the code
## given in the comment at the top of gauss2mf.m.
##
## @seealso{gauss2mf}
## @end deftypefn

## Author:        L. Markowsky
## Keywords:      fuzzy-logic-toolkit fuzzy tests demos
## Directory:     fuzzy-logic-toolkit/inst
## Filename:      gauss2mf_demo.m
## Version:       0.2
## Last-Modified: 19 May 2011

x = -10:0.2:10;
params = [3 0 1.5 2];
y1 = gauss2mf (x, params);
params = [1.5 0 3 2];
y2 = gauss2mf (x, params);
params = [1.5 2 3 0];
y3 = gauss2mf (x, params);
figure ('NumberTitle', 'off', 'Name', 'gauss2mf demo');
plot (x, y1, 'r;params = [3 0 1.5 2];', 'LineWidth', 2);
hold on ;
plot (x, y2, 'b;params = [1.5 0 3 2];', 'LineWidth', 2);
hold on ;
plot (x, y3, 'g;params = [1.5 2 3 0];', 'LineWidth', 2);
ylim ([-0.1 1.1]);
xlabel ('Crisp Input Value', 'FontWeight', 'bold');
ylabel ('Degree of Membership', 'FontWeight', 'bold');
grid;
hold;
