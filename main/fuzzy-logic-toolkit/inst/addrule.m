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
## @deftypefn {Function File} {@var{fis} =} addrule (@var{fis}, @var{rule_matrix})
##
## Add a list of rules to an existing FIS (Fuzzy Inference System) and return
## the updated FIS.
##
## Each row of the @var{rule_matrix} represents one rule and has the form:
## @example
## [in1_mf ... inM_mf out1_mf ... outN_mf weight connect]
## @end example
##
## @noindent
## where:
##
## @itemize @w
## @item
## in<i>_mf == membership function index for input i
## @item
## out<j>_mf == membership function index for output j
## @item
## weight == relative weight of the rule (0 <= weight <= 1)
## @item
## connect == antecedent connective (1 == and; 2 == or)
## @end itemize
##
## To express the hedge "not", prepend a minus sign to the membership function
## index. ("Not" is the only hedge supported.) To omit an input or output, use
## 0 for the membership function index. The consequent connective is always
## "and".
##
## @noindent
## For example, to express:
## @example
## "If input_1 is mf_2 or input_3 is not mf_1,
##  then output_2 is mf_1."
## @end example
##
## @noindent
## with weight 1, the corresponding row of @var{rule_matrix} would be:
## @example
## [2  0  -1  0  1  1  2]
## @end example
##
## @noindent
## For a complete example that uses addrule, see commandline_demo.m.
##
## @seealso{commandline_demo, showrule}
## @end deftypefn

## Author:        L. Markowsky
## Keywords:      fuzzy-logic-toolkit fuzzy rule
## Directory:     fuzzy-logic-toolkit/inst/
## Filename:      addrule.m
## Last-Modified: 21 Jun 2011

function fis = addrule (fis, rule_matrix) 

  ## If the caller did not supply 2 argument values with the correct types,
  ## print an error message and halt.

  if (nargin != 2)
    puts ("Type 'help addrule' for more information.\n");
    error ("addrule requires 2 arguments\n");
  elseif (!is_fis (fis))
    puts ("Type 'help addrule' for more information.\n");
    error ("addrule's first argument must be an FIS structure\n");
  elseif (!is_real_matrix (rule_matrix))
    puts ("Type 'help addrule' for more information.\n");
    error ("addrule's second argument must be a matrix of real numbers\n");
  endif

  ## For each row in the rule_matrix, create a new rule struct and update
  ## the FIS structure.

  num_inputs = columns (fis.input);
  num_outputs = columns (fis.output);

  for i = 1 : rows (rule_matrix)
    antecedent = rule_matrix(i, 1 : num_inputs);
    consequent = rule_matrix(i, (num_inputs+1) : (num_inputs+num_outputs));
    weight = rule_matrix(i, num_inputs + num_outputs + 1);
    connection = rule_matrix(i, num_inputs + num_outputs + 2);
    new_rules(i) = struct ('antecedent', antecedent, ...
                           'consequent', consequent, ...
                           'weight', weight, ...
                           'connection', connection);
  endfor

  if (length (fis.rule) == 0)
    fis.rule = new_rules;
  else
    fis.rule = [fis.rule, new_rules];
  endif

endfunction
