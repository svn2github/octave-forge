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
## @deftypefn {Function File} {@var{output} =} defuzzify_output_sugeno (@var{fis}, @var{aggregated_output})
##
## Return the crisp output values given the aggregated fuzzy output for each
## FIS output variable and the FIS defuzzification method.
##
## The aggregated output for each FIS output is a 2 x M matrix, where M is the
## number of distinct singleton locations in the rule_output (above) for that
## FIS output:
##
## @example
## @group
##           singleton_1  singleton_2 ... singleton_M
## location [                                        ]
##   height [                                        ]
## @end group
## @end example
##
## The argument aggregated_output is a vector of L structures, each of
## which has an index and one of these matrices.
##
## The defuzzification method is stored in @var{fis.defuzzMethod}.
##
## Finally, the crisp output values (the output of this function) are given by:
## @example
## output:  [output_1 output_2 ... output_N]
## @end example
##
## Function defuzzify_output_sugeno does no error checking of the argument
## values.
##
## @end deftypefn

## Author:        L. Markowsky
## Keywords:      fuzzy-logic-toolkit fuzzy fuzzy-inference-system fis
## Directory:     fuzzy-logic-toolkit/inst/private/
## Filename:      defuzzify_output_sugeno.m
## Last-Modified: 19 May 2011

function output = defuzzify_output_sugeno (fis, aggregated_output)

  num_outputs = columns (fis.output);
  output = zeros (num_outputs);

  for i = 1 : num_outputs
    next_agg_output = aggregated_output(i).aggregated_output;
    x = next_agg_output(1, :);
    y = next_agg_output(2, :);
    output(i) = defuzz (x, y, fis.defuzzMethod);
  endfor

endfunction
