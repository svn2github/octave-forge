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
## @deftypefn {Function File} {@var{rule_output} =} eval_rules_sugeno (@var{fis}, @var{firing_strength}, @var{user_input})
##
## Return the fuzzy output for each rule and for each output variable of a
## Sugeno-type FIS (that is, an FIS that has only constant and linear output
## membership functions).
##
## The firing strength of each rule is given by a row vector of length Q, where
## Q is the number of rules in the FIS:
## @example
## @group
##  rule_1             rule_2             ... rule_Q
## [firing_strength(1) firing_strength(2) ... firing_strength(Q)]
## @end group
## @end example
##
## The consequent for each rule is given by:
## @example
## fis.rule(i).consequent     for i = 1..Q
## @end example
##
## Finally, the output of the function is a 2 x (Q*L) matrix, where
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
## Function eval_rules_sugeno does no error checking of the argument values.
##
## @end deftypefn

## Author:        L. Markowsky
## Keywords:      fuzzy-logic-toolkit fuzzy fuzzy-inference-system fis
## Directory:     fuzzy-logic-toolkit/inst/private/
## Filename:      eval_rules_sugeno.m
## Last-Modified: 20 May 2011

function rule_output = eval_rules_sugeno (fis, firing_strength, user_input)

  num_rules = columns (fis.rule);                 ## num_rules   == Q (above)
  num_outputs = columns (fis.output);             ## num_outputs == L

  ## Initialize output matrix to prevent inefficient resizing.
  rule_output = zeros (2, num_rules * num_outputs);

  ## Compute the (location, height) of the singleton output by each
  ## (rule, output) pair:
  ##   1. The height is given by the firing strength of the rule.
  ##   2. If the consequent membership function is constant, then the
  ##      membership function's parameter gives the location of the singleton.
  ##      If the consequent membership function is linear, then the
  ##      location is the inner product of the the membership function's
  ##      parameters and the vector formed by appending a 1 to the user input
  ##      vector.

  for i = 1 : num_rules
    rule = fis.rule(i);
    height = firing_strength(i);
    
    if (height != 0)
      for j = 1 : num_outputs

        ## Compute the singleton location for this (rule, output) pair.

        mf_index = rule.consequent(j);
        if (mf_index != 0)
          mf = fis.output(j).mf(mf_index);
          switch (mf.type)
            case 'constant'
              location = mf.params;
            case 'linear'
              location = mf.params .* [user_input 1];
            otherwise
              location = str2func (mf.type) (mf.params, user_input);
          endswitch

          ## Store result in column of rule_output corresponding
          ## to the (rule, output) pair.

          rule_output(1, (i - 1) * num_outputs + j) = location;
          rule_output(2, (i - 1) * num_outputs + j) = height;
        endif
      endfor
    endif
  endfor
endfunction
