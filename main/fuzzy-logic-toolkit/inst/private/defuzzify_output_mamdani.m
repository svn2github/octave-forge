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
## @deftypefn {Function File} {@var{output} =} defuzzify_output_mamdani (@var{fis}, @var{fuzzy_output})
##
## Return the crisp output values given the aggregated fuzzy output for each
## FIS output variable and the FIS defuzzification method.
##
## The aggregated fuzzy output (the second argument to this function) for
## the FIS is an num_pts x L matrix. Each column of this matrix gives the
## y-values of the corresponding fuzzy output (for a single FIS output,
## aggregated over all rules).
##
## @example
## @group
##          out_1  out_2  ...  out_L
##       1 [                        ]
##       2 [                        ]
##     ... [                        ]
## num_pts [                        ]
## @end group
## @end example
##
## The defuzzification method is stored in the FIS structure:
##     fis.defuzzMethod
##
## Finally, the crisp output values (the output of this function) are given by:
## @example
## output:  [output_1 output_2 ... output_N]
## @end example
##
## Function defuzzify_output_mamdani does no error checking of the argument
## values.
##
## @end deftypefn

## Author:        L. Markowsky
## Keywords:      fuzzy-logic-toolkit fuzzy fuzzy-inference-system fis
## Directory:     fuzzy-logic-toolkit/inst/private/
## Filename:      defuzzify_output_mamdani.m
## Last-Modified: 19 May 2011

function output = defuzzify_output_mamdani (fis, fuzzy_output)

  num_outputs = columns (fis.output);             ## num_outputs == L (above)
  num_points = rows (fuzzy_output);
  output = zeros (num_outputs);

  for i = 1 : num_outputs
    range = fis.output(i).range;
    x = linspace (range(1), range(2), num_points);
    y = (fuzzy_output(:, i))';
    output(i) = defuzz (x, y, fis.defuzzMethod);
  endfor

endfunction
