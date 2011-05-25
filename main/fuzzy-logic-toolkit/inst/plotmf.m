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
## @deftypefn {Function File} {} plotmf (@var{fis}, @var{in_or_out}, @var{var_index})
##
## Plot the membership functions for the specified FIS variable on a single set
## of axes. The types of the arguments are expected to be:
## @itemize @bullet
## @item
## @var{fis} - an FIS structure
## @item
## @var{in_or_out} - either 'input' or 'output' (case-insensitive)
## @item
## @var{var_index} - an FIS input or output variable index
## @end itemize
##
## Four examples that use plotmf are:
## @itemize @bullet
## @item
## commandline_demo.m
## @item
## heart_demo.m
## @item
## mamdani_demo.m
## @item
## tipping_demo.m
## @end itemize
##
## @seealso{gensurf}
## @end deftypefn

## Author:        L. Markowsky
## Keywords:      fuzzy-logic-toolkit fuzzy membership-function plot
## Directory:     fuzzy-logic-toolkit/inst/
## Filename:      plotmf.m
## Version:       0.2
## Last-Modified: 19 May 2011

function plotmf (fis, in_or_out, var_index)

  ## If the caller did not supply 3 argument values with the correct types,
  ## print an error message and halt.

  if (nargin != 3)
    puts ("Type 'help plotmf' for more information.\n");
    error ("plotmf requires 3 arguments\n");
  elseif (!is_fis (fis))
    puts ("Type 'help plotmf' for more information.\n");
    error ("plotmf's first argument must be an FIS structure\n");
  elseif (!(is_string (in_or_out) && ...
           ismember (tolower (in_or_out), {'input', 'output'})))
    puts ("Type 'help plotmf' for more information.\n");
    error ("plotmf's second argument must be 'input' or 'output'\n");
  elseif (!is_var_index (fis, in_or_out, var_index))
    puts ("Type 'help plotmf' for more information.\n");
    error ("plotmf's third argument must be a variable index\n");
  endif

  ## Select specified variable and construct the window title.

  if (strcmpi (in_or_out, 'input'))
    var = fis.input(var_index);
    window_title = [' Input ' num2str(var_index) ' Term Set'];
  else
    var = fis.output(var_index);
    window_title = [' Output ' num2str(var_index) ' Term Set'];
  endif

  ## Plot the membership functions for the specified variable.
  ## Cycle through the five colors: red, blue, green, magenta, cyan.
  ## Display the membership function names in a legend.

  x = linspace (var.range(1), var.range(2), 1001); 
  num_mfs = columns (var.mf);
  colors = ["r" "b" "g" "m" "c"];
  figure ('NumberTitle', 'off', 'Name', window_title);

  for i = 1 : num_mfs
    if (strcmp ('linear', var.mf(i).type))
      error ("plotmf does not handle linear membership functions\n");
    endif
    y = evalmf_private (x, var.mf(i).params, var.mf(i).type);
    y_label = [colors(mod(i-1,5)+1) ";" var.mf(i).name ";"];
    plot (x, y, y_label, 'LineWidth', 2);
    hold on;
  endfor

  ## Adjust the y-axis, label both axes, and display a dotted grid.

  ylim ([-0.1, 1.1]);
  xlabel (var.name, 'FontWeight', 'bold');
  ylabel ('Degree of Membership', 'FontWeight', 'bold');
  grid;
  hold;

endfunction
