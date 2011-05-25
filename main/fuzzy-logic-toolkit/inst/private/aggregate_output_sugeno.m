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
## @deftypefn {Function File} {@var{retval} =} aggregate_output_sugeno (@var{fis}, @var{rule_output})
##
## Function aggregate_output_sugeno:
##
## @example
## @group
## singleton output for each (rule, var) pair  =>  aggregated singleton output
## aggregation method                              for each FIS output var
## @end group
## @end example
##
## The rule_output (input to this function) is a 2 x (Q*L) matrix, where
## Q is the number of rules and L is the number of outputs of the FIS.
## Each column of this matrix gives the (location, height) pair of the
## corresponding singleton output (of a single rule for a single FIS output).
##
## @example
## @group
##           num_rules cols    num_rules cols          num_rules cols 
##           ---------------   ---------------         ---------------
##           out_1 ... out_1   out_2 ... out_2   ...   out_L ... out_L
## location [                                                         ]
##   height [                                                         ]
## @end group
## @end example
##
## The aggregation method is stored in @var{fis.aggMethod}.
##
## The aggregated output for the FIS is a 2 x M matrix, where M is the
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
## The return value of this function is a vector of L structures, each of
## which has an index and one of these matrices.
##
## Function aggregate_output_sugeno does no error checking of the argument
## values.
##
## @end deftypefn

## Author:        L. Markowsky
## Keywords:      fuzzy-logic-toolkit fuzzy fuzzy-inference-system fis
## Directory:     fuzzy-logic-toolkit/inst/private/
## Filename:      aggregate_output_sugeno.m
## Version:       0.2
## Last-Modified: 19 May 2011

##------------------------------------------------------------------------------

function retval = aggregate_output_sugeno (fis, rule_output)

  retval = [];
  num_outputs = columns (fis.output);
  num_rules = columns (fis.rule);

  ## For each FIS output, aggregate the slice of the rule_output matrix, 
  ## then store the result as a structure in retval.

  for i = 1 : num_outputs
    unagg_output = rule_output(:, (i-1)*num_rules+1 : i*num_rules);
    aggregated_output = aggregate_fis_output (fis.aggMethod, unagg_output);
    next_agg_output = struct ('index', i, ...
                              'aggregated_output', aggregated_output);
    retval = [retval, next_agg_output];
  endfor
endfunction

##------------------------------------------------------------------------------
## Function: aggregate_fis_output
## Purpose:  Aggregate the multiple singletons for one FIS output.
##------------------------------------------------------------------------------

function mult_singletons = aggregate_fis_output (fis_aggmethod, rule_output)

  ## Initialize output matrix (multiple_singletons).

  mult_singletons = sortrows (rule_output', 1);

  ## If adjacent rows represent singletons at the same location, then combine
  ## them using the FIS aggregation method.

  for i = 1 : rows (mult_singletons) - 1
    if (mult_singletons(i, 1) == mult_singletons(i+1, 1))
      switch (fis_aggmethod)
        case 'sum'
          mult_singletons(i + 1, 2) = mult_singletons(i, 2) + ...
                                      mult_singletons(i + 1, 2);
        otherwise
          mult_singletons(i + 1, 2) = str2func (fis_aggmethod) ...
                                      (mult_singletons(i, 2), ...
                                       mult_singletons(i + 1, 2));
      endswitch
      mult_singletons(i, 2) = 0;
    endif
  endfor

  ## Return the transpose of the matrix after removing 0-height singletons.

  mult_singletons = (remove_null_rows (mult_singletons))';
    
endfunction

##------------------------------------------------------------------------------
## Function: remove_null_rows
## Purpose:  Return the argument without the rows with a 0 in the second column.
##------------------------------------------------------------------------------

function y = remove_null_rows (x)
  y = [];
  for i = 1 : rows (x)
    if (x(i, 2) != 0)
      y = [y; x(i, :)];
    endif
  endfor
endfunction
