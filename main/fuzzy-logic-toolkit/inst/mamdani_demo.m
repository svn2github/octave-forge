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
## @deftypefn {Script File} {} mamdani_demo
## Demonstrate the use of the fuzzy_logic_toolkit to:
## @itemize @minus
## @item
## evaluate a Mamdani-type FIS for a given input
## @item
## plot the output membership functions
## @item
## plot the output as a function of two inputs
## @item
## plot the output of individual rules
## @item
## plot the aggregated fuzzy output and the crisp output
## @end itemize
##
## @seealso{commandline_demo, heart_demo, tipping_demo}
## @end deftypefn

## Author:        L. Markowsky
## Keywords:      fuzzy-logic-toolkit fuzzy tests demos
## Note:          This example is based on an assignment written by
##                Dr. Bruce Segee (University of Maine Dept. of ECE).
## Directory:     fuzzy-logic-toolkit/inst
## Filename:      mamdani_demo.m
## Version:       0.2
## Last-Modified: 19 May 2011

## Read the FIS structure from a file.
fis=readfis ('mamdani-tip-calculator');

## Plot the input and output membership functions.
plotmf (fis, 'input', 1);
plotmf (fis, 'input', 2);
plotmf (fis, 'output', 1);

## Plot the Tip as a function of Food-Quality and Service.
gensurf (fis);

## Calculate the Tip using (Food-Quality, Service) = (4, 6).
[output, rule_input, rule_output, fuzzy_output] = evalfis ([4 6], fis, 1001);

## Plot the output of the individual fuzzy rules (on one set of axes).
x_axis = linspace (fis.output(1).range(1), fis.output(1).range(2), 1001);
colors = ['r' 'b' 'm' 'g'];
figure ('NumberTitle', 'off', 'Name', ...
        'Output of Fuzzy Rules 1-4 for Input = (4, 6)');

for i = 1 : 4
    y_label = [colors(i) ";Rule " num2str(i) ";"];
    plot (x_axis, rule_output(:,i), y_label, 'LineWidth', 2);
    hold on;
endfor

ylim ([-0.1, 1.1]);
xlabel ('Tip', 'FontWeight', 'bold');
grid;
hold;

## Plot the aggregated fuzzy output and the crisp output (on one set of axes).
figure('NumberTitle', 'off', 'Name', 'Aggregation and Defuzzification for Input = (4, 6)');
plot (x_axis, fuzzy_output, "b;Aggregated Fuzzy Output;", 'LineWidth', 2);
hold on;
crisp_output = evalmf(x_axis, output, 'constant');
y_label = ["r;Crisp Output = " num2str(output) "%;"];
plot (x_axis, crisp_output, y_label, 'LineWidth', 2);
ylim ([-0.1, 1.1]);
xlabel ('Tip', 'FontWeight', 'bold');
grid;
hold;

## Show the rules in symbolic format.
puts ("\nMamdani Tip Calculator Rules:\n\n");
showrule (fis, 1:columns(fis.rule), 'symbolic');
