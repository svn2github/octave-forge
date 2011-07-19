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
## @deftypefn {Script File} {} addmf_demo
##
## Demonstrate the function @t{addmf} by executing the code
## given in the comment at the top of addmf.m.
##
## @seealso{addmf, heart_demo_1}
## @end deftypefn

## Author:        L. Markowsky
## Note:          This example is based on an assignment written by
##                Dr. Bruce Segee (University of Maine Dept. of ECE).
## Keywords:      fuzzy-logic-toolkit fuzzy tests demos
## Directory:     fuzzy-logic-toolkit/inst
## Filename:      addmf_demo.m
## Last-Modified: 16 Jul 2011

## Create new FIS.
a = newfis ('Heart-Disease-Risk', 'sugeno', ...
            'min', 'max', 'min', 'max', 'wtaver');

## Add two inputs and their membership functions.
a = addvar (a, 'input', 'LDL-Level', [0 300]);
a = addmf (a, 'input', 1, 'Low', 'trapmf', [-1 0 90 110]);
a = addmf (a, 'input', 1, 'Low-Borderline', 'trapmf', [90 110 120 140]);
a = addmf (a, 'input', 1, 'Borderline', 'trapmf', [120 140 150 170]);
a = addmf (a, 'input', 1, 'High-Borderline', 'trapmf', [150 170 180 200]);
a = addmf (a, 'input', 1, 'High', 'trapmf', [180 200 300 301]);

a = addvar (a, 'input', 'HDL-Level', [0 100]);
a = addmf (a, 'input', 2, 'Low-HDL', 'trapmf', [-1 0 35 45]);
a = addmf (a, 'input', 2, 'Moderate-HDL', 'trapmf', [35 45 55 65]);
a = addmf (a, 'input', 2, 'High-HDL', 'trapmf', [55 65 100 101]);

## Plot the input membership functions.
plotmf (a, 'input', 1);
plotmf (a, 'input', 2);
