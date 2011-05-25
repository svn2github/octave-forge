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
## @deftypefn {Function File} {@var{output} =} evalfis (@var{user_input}, @var{fis})
## @deftypefnx {Function File} {@var{output} =} evalfis (@var{user_input}, @var{fis}, @var{num_points})
## @deftypefnx {Function File} {[@var{output}, @var{rule_input}, @var{rule_output}, @var{fuzzy_output}] =} evalfis (@var{user_input}, @var{fis})
## @deftypefnx {Function File} {[@var{output}, @var{rule_input}, @var{rule_output}, @var{fuzzy_output}] =} evalfis (@var{user_input}, @var{fis}, @var{num_points})
##
## Evaluate the FIS for each line in the user_input matrix, and for each row of
## crisp input values, return the crisp output of the FIS. Also, for the last
## row of user_input, return:
##
## @table @var
## @item rule_input
## a matrix (num_rules x num_inputs) of the degree to which
## each input matched the membership function for each rule
## @item rule_output
## a matrix of the output of each rule
## @item fuzzy_output
## a matrix of the aggregated output for each FIS output
## @end table
##
## The optional argument @var{num_points} specifies the number of points over
## which to evaluate the fuzzy values. The default value of @var{num_points} is
## 101.
##
## @noindent
## Format of user_input:
## 
## The @var{user_input} is a matrix of crisp input values. Each row of the
## matrix represents one set of input values to the FIS and has the form:
##
## @example
## @group
## [input_1a input_2a ... input_Ma]  <-- 1st row is 1st set of inputs
## [input_1b input_2b ... input_Mb]  <-- 2nd row is 2nd set of inputs
## [             ...              ]                 ...
## [input_1z input_2z ... input_Mz]  <-- zth row is zth set of inputs
## @end group
## @end example
##
## @noindent
## Format of output:
##
## The @var{output} of the FIS is also a matrix of crisp values. Each row
## of the matrix represents the set of outputs for the corresponding row of
## @var{user_input}:
##
## @example
## @group
## [output_1a output_2a ... output_Na]  <-- 1st row is 1st set of outputs
## [output_1b output_2b ... output_Nb]  <-- 2nd row is 2nd set of outputs
## [               ...               ]                 ...
## [output_1z output_2z ... output_Nz]  <-- zth row is zth set of outputs
## @end group
## @end example
##
## @noindent
## Format of rule_input:
## 
## The matching degree for each (rule, input value) pair is specified by an
## Q x N matrix:
## @example
## @group
##          in_1  in_2 ...  in_N
## rule_1 [mu_11 mu_12 ... mu_1N]
## rule_2 [mu_21 mu_22 ... mu_2N]
##        [            ...      ]
## rule_Q [mu_Q1 mu_Q2 ... mu_QN]
## @end group
## @end example
##
## @noindent
## where Q is the number of rules and N is the number of inputs to the FIS.
##
## @noindent
## Format of rule_output:
##
## The format of rule_output depends on the FIS type ('mamdani' or 'sugeno').
##
## For either a Mamdani-type FIS (that is, an FIS that does not have constant or
## linear output membership functions) or a Sugeno-type FIS (that is, an FIS
## that has only constant and linear output membership functions),
## @var{rule_output} specifies the fuzzy output for each rule and for each
## output variable.
##
## For a Mamdani-type FIS, @var{rule_output} is a num_points x (Q*L) matrix,
## where num_points is the number of points at which the fuzzy output is
## evaluated, Q is the number of rules, and L is the number of outputs of the
## FIS. Each column of this matrix gives the y-values of the corresponding fuzzy
## output (of a single rule for a single FIS output).
##
## @example
## @group
##              num_rules cols    num_rules cols      num_rules cols 
##             ---------------   ---------------     ---------------
##             out_1 ... out_1   out_2 ... out_2 ... out_L ... out_L
##          1 [                                                     ]
##          2 [                                                     ]
##        ... [                                                     ]
## num_points [                                                     ]
## @end group
## @end example
##
## For a Sugeno-type FIS, @var{rule_output} is a 2 x (Q*L) matrix, where
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
## @noindent
## Format of fuzzy_output:
##
## The format of @var{fuzzy_output} depends on the FIS type ('mamdani' or
## 'sugeno').
##
## For either a Mamdani-type FIS or a Sugeno-type FIS, @var{fuzzy_output}
## specifies the aggregated fuzzy output for each FIS output.
##
## For a Mamdani-type FIS, the aggregated @var{fuzzy_output} is an num_pts x L
## matrix. Each column of this matrix gives the y-values of the corresponding
## fuzzy output (for a single FIS output, aggregated over all rules).
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
## For a Sugeno-type FIS, the aggregated output for each FIS output is a 2 x M
## matrix, where M is the number of distinct singleton locations in the
## @var{rule_output} (above) for that FIS output:
##
## @example
## @group
##           singleton_1  singleton_2 ... singleton_M
## location [                                        ]
##   height [                                        ]
## @end group
## @end example
##
## Then @var{fuzzy_output} is a vector of L structures, each of which has an index and
## one of these matrices.
##
## @noindent
## Examples:
##
## Three examples of using evalfis are shown in:
## @itemize @bullet
## @item
## heart_demo.m
## @item
## mamdani_demo.m
## @item
## tipping_demo.m
## @end itemize
##
## @seealso{heart_demo, mamdani_demo, tipping_demo}
## @end deftypefn

## Author:        L. Markowsky
## Keywords:      fuzzy-logic-toolkit fuzzy fuzzy-inference-system fis
## Directory:     fuzzy-logic-toolkit/inst/
## Filename:      evalfis.m
## Version:       0.2
## Last-Modified: 19 May 2011

function [output, rule_input, rule_output, fuzzy_output] = ...
           evalfis (user_input, fis, num_points=101)

  ## If evalfis was called with an incorrect number of arguments, or the
  ## arguments do not have the correct type, print an error message and halt.

  if ((nargin != 2) && (nargin != 3))
    puts ("Type 'help evalfis' for more information.\n");
    error ("evalfis requires 2 or 3 arguments\n");
  elseif (!is_fis (fis))
    puts ("Type 'help evalfis' for more information.\n");
    error ("evalfis's second argument must be an FIS structure\n");
  elseif (!is_input_matrix (user_input, fis))
    puts ("Type 'help evalfis' for more information.\n");
    error ("evalfis's first argument must be a matrix of input values\n");
  elseif (!is_pos_int (num_points))
    puts ("Type 'help evalfis' for more information.\n");
    error ("evalfis's third argument must be a positive integer\n");
  endif

  ## Call a private function to compute the output.
  ## (The private function is also called by gensurf.)

  [output, rule_input, rule_output, fuzzy_output] = ...
    evalfis_private (user_input, fis, num_points);

endfunction
