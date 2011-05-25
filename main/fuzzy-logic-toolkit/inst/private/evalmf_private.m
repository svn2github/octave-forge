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
## @deftypefn {Function File} {@var{y} =} evalmf_private (@var{x}, @var{param}, @var{mf_type})
## @deftypefnx {Function File} {@var{y} =} evalmf_private (@var{[x1 x2 ... xn]}, @var{[param1 ... ]}, '<@var{mf_type}>')
##
## This function localizes the membership function evaluation without the
## parameter tests. It is called by evalmf and plotmf. For more information,
## see the comment at the top of evalmf.m.
##
## @end deftypefn

## Author:        L. Markowsky
## Keywords:      fuzzy-logic-toolkit fuzzy membership-function evaluate
## Directory:     fuzzy-logic-toolkit/inst/private/
## Filename:      evalmf_private.m
## Version:       0.2
## Last-Modified: 20 May 2011

function y = evalmf_private (x, params, mf_type)

  ## Calculate and return the y values of the membership function on the
  ## domain x.

  switch (mf_type)
    case 'constant'  y = eval_constant (x, params);
    case 'linear'    y = eval_linear (x);
    otherwise        y = str2func (mf_type) (x, params);
  endswitch

endfunction

##------------------------------------------------------------------------------
## Function: eval_constant
## Purpose:  Return the y-values corresponding to the x-values in the domain
##           for the constant function specified by the parameter c.
##------------------------------------------------------------------------------

function y = eval_constant (x, c)
  y = zeros (length (x));
  delta = x(2) - x(1);
  y_val = @(x_val) (abs (c - x_val) < delta);
  y = arrayfun (y_val, x);
endfunction

##------------------------------------------------------------------------------
## Function: eval_linear
## Purpose:  Return a vector of zeros (since the input is not specified, and the
##           location of the singleton is unknown). This creates a function to
##           display on a graph of membership functions.
##------------------------------------------------------------------------------

function y = eval_linear (x)
  y = zeros (length (x));
endfunction
