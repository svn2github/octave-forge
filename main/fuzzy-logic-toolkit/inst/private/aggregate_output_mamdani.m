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
## @deftypefn {Function File} {@var{fuzzy_output} =} aggregate_output_mamdani (@var{fis}, @var{rule_output})
##
## @example
## @group
## fuzzy output for each (rule, output var) pair  =>  aggregated fuzzy output
## aggregation method                                 for each output var
## @end group
## @end example
##
## The fuzzy output for each rule and FIS output is a num_pts x (Q*L) matrix,
## where num_pts is the number of points at which the fuzzy output is evaluated,
## Q is the number of rules, and L is the number of outputs of the FIS.
## Each column of this matrix gives the y-values of the corresponding fuzzy
## output (of a single rule for a single FIS output).
##
## @example
## @group
##              num_rules cols    num_rules cols          num_rules cols 
##             ---------------   ---------------         ---------------
##             out_1 ... out_1   out_2 ... out_2   ...   out_L ... out_L
##          1 [                                                         ]
##          2 [                                                         ]
##        ... [                                                         ]
## num_points [                                                         ]
## @end group
## @end example
##
## The aggregation method is stored in @var{fis.aggMethod}.
##
## The aggregated fuzzy output for the FIS is an num_pts x L matrix.
## Each column of this matrix gives the y-values of the corresponding fuzzy
## output (for a single FIS output, aggregated over all rules).
##
## @example
## @group
##             out_1  out_2  ...  out_L
##          1 [                        ]
##          2 [                        ]
##        ... [                        ]
## num_points [                        ]
## @end group
## @end example
##
## Function aggregate_output_mamdani does no error checking of the argument
## values.
## @end deftypefn

## Author:        L. Markowsky
## Keywords:      fuzzy-logic-toolkit fuzzy fuzzy-inference-system fis
## Directory:     fuzzy-logic-toolkit/inst/private/
## Filename:      aggregate_output_mamdani.m
## Last-Modified: 20 May 2011

function fuzzy_output = aggregate_output_mamdani (fis, rule_output)

  num_rules = columns (fis.rule);                 ## num_rules   == Q (above)
  num_outputs = columns (fis.output);             ## num_outputs == L
  num_points = rows (rule_output);

  ## Initialize output matrix to prevent inefficient resizing.
  fuzzy_output = zeros (num_points, num_outputs);

  for i = 1 : num_outputs
    indiv_fuzzy_out = rule_output(:, (i - 1) * num_rules + 1 : i * num_rules);
    agg_fuzzy_out = (str2func (fis.aggMethod) (indiv_fuzzy_out'))';
    fuzzy_output(:, i) = agg_fuzzy_out;
  endfor

endfunction
