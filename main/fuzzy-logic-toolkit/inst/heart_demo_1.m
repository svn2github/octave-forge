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
## @deftypefn {Script File} {} heart_demo_1
##
## Demonstrate the use of newfis, addvar, addmf, addrule, and evalfis
## to build and evaluate an FIS.
##
## The demo:
## @itemize @minus
## @item
## builds an FIS
## @item
## plots the input and output membership functions
## @item
## plots an output as a function of two inputs
## @item
## displays information about the FIS in the Octave window
## @end itemize
##
## @seealso{cubic_approx_demo, heart_demo_2, linear_tip_demo, mamdani_tip_demo, sugeno_tip_demo}
## @end deftypefn

## Author:        L. Markowsky
## Note:          This example is based on an assignment written by
##                Dr. Bruce Segee (University of Maine Dept. of ECE).
## Keywords:      fuzzy-logic-toolkit fuzzy tests demos
## Directory:     fuzzy-logic-toolkit/inst
## Filename:      heart_demo_1.m
## Last-Modified: 30 Aug 2011

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

## Add one output and its membership functions.
a = addvar (a, 'output', 'Heart-Disease-Risk', [0 10]);
a = addmf (a, 'output', 1, 'No-Risk', 'constant', 0);
a = addmf (a, 'output', 1, 'Low-Risk', 'constant', 2.5);
a = addmf (a, 'output', 1, 'Medium-Risk', 'constant', 5);
a = addmf (a, 'output', 1, 'High-Risk', 'constant', 7.5);
a = addmf (a, 'output', 1, 'Extreme-Risk', 'constant', 10);

## Plot the output membership functions.
plotmf (a, 'output', 1);

## Add 15 rules and display them in verbose format.
a = addrule (a, [1 1 3 1 1; ...
                 1 2 2 1 1; ...
                 1 3 1 1 1; ...
                 2 1 3 1 1; ...
                 2 2 2 1 1; ...
                 2 3 2 1 1; ...
                 3 1 4 1 1; ...
                 3 2 3 1 1; ...
                 3 3 2 1 1; ...
                 4 1 4 1 1; ...
                 4 2 4 1 1; ...
                 4 3 3 1 1; ...
                 5 1 5 1 1; ...
                 5 2 4 1 1; ...
                 5 3 3 1 1]);
puts ("\nOutput of showrule(a):\n\n");
showrule (a);

## Plot the output as a function of the two inputs.
gensurf (a);

## Show the FIS in the Octave window.
puts ("\nOutput of showfis(a):\n\n");
showfis (a);

