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
## @deftypefn {Function File} {} gensurf (@var{fis})
## @deftypefnx {Function File} {} gensurf (@var{fis}, @var{input_axes})
## @deftypefnx {Function File} {} gensurf (@var{fis}, @var{input_axes}, @var{output_axes})
## @deftypefnx {Function File} {} gensurf (@var{fis}, @var{input_axes}, @var{output_axes}, @var{grids})
## @deftypefnx {Function File} {} gensurf (@var{fis}, @var{input_axes}, @var{output_axes}, @var{grids}, @var{ref_input})
## @deftypefnx {Function File} {} gensurf (@var{fis}, @var{input_axes}, @var{output_axes}, @var{grids}, @var{ref_input}, @var{num_points})
## @deftypefnx {Function File} {@var{[x, y, z]} =} gensurf (...)
##
## CURRENT LIMITATIONS:
## @itemize @bullet
## @item
## input_axes must have length 2, so that gensurf plots a surface.
## @item
## Output for only 1 input axis (a 2-D plot) is not yet implemented.
## @item
## The FIS for which the surface is generated must have only one output.
## @item
## grids must have length 2.
## @item
## The final form of gensurf (that suppresses plotting) is not yet
## implemented.
## @end itemize
##
## Generate and plot a surface showing the output_axis as a function of the 
## two input_axes. The reference input is used for all FIS inputs that are not
## in the input_axes vector.
##
## Grids, which specifies the number of grids to show on the input axes, may be
## a scalar or a vector of length 2. If a scalar, then both axes will use the
## same number of grids. If a vector of length 2, then the grids on the two axes
## are controlled separately.
##
## Num_points specifies the number of points to use when evaluating the FIS.
##
## The final form "[x, y, z] = gensurf(...)" suppresses plotting.
##
## Default values for arguments not supplied are:
## @itemize @bullet
## @item
## input_axes == [1 2]
## @item
## output_axis == 1
## @item
## grids == [15 15]
## @item
## ref_input == []
## @item
## num_points == 101
## @end itemize
##
## Four examples of using gensurf are shown in:
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
## @seealso{commandline_demo, heart_demo, mamdani_demo, tipping_demo, plotmf}
## @end deftypefn

## Author:        L. Markowsky
## Keywords:      fuzzy-logic-toolkit fuzzy fuzzy-inference-system fis plot
## Directory:     fuzzy-logic-toolkit/inst/
## Filename:      gensurf.m
## Version:       0.2
## Last-Modified: 19 May 2011

function [x, y, z] = gensurf (fis, input_axes=[1 2], output_axis=1, ...
                              grids=[15 15], ref_input=[], num_points=101)

  ## TO DO: RESET INPUT_AXES=1 IF NARGIN==1 AND THE FIS HAS ONLY 1 INPUT
  ## TO DO: GENERATE 2-D PLOT IF LENGTH(INPUTS_AXES)==1
  ## TO DO: HANDLE FIS STRUCTURES THAT HAVE MORE THAN 1 OUTPUT
  ## TO DO: HANDLE SCALAR GRIDS ARGUMENT
  ## TO DO: RENAME X, Y, AND Z. MAKE SURE THEY ARE ASSIGNED VALUES.

  ## If gensurf was called with an incorrect number of arguments, or the
  ## arguments do not have the correct type, print an error message and halt.

  if ((nargin < 1) || (nargin > 6))
    puts ("Type 'help gensurf' for more information.\n");
    error ("gensurf requires between 1 and 6 arguments\n");
  elseif (!is_fis (fis))
    puts ("Type 'help gensurf' for more information.\n");
    error ("gensurf's first argument must be an FIS structure\n");
  elseif ((nargin >= 2) && !are_input_indices (input_axes, fis))
    puts ("Type 'help gensurf' for more information.\n");
    error ("gensurf's second argument must be valid input indices\n");
  elseif ((nargin >= 3) && !is_output_index (output_axis, fis))
    puts ("Type 'help gensurf' for more information.\n");
    error ("gensurf's third argument must be a valid output index\n");
  elseif ((nargin >= 4) && !is_grid_spec (grids))
    puts ("Type 'help gensurf' for more information.\n");
    error ("gensurf's fourth argument must be a valid grid specification\n");
  elseif ((nargin >= 5) && !is_ref_input (ref_input, fis, input_axes))
    puts ("Type 'help gensurf' for more information.\n");
    error ("gensurf's fifth argument must specify reference input values\n");
  elseif ((nargin == 6) && !(is_pos_int (num_points) && (num_points >= 2)))
    puts ("Type 'help gensurf' for more information.\n");
    error ("gensurf's sixth argument to gensurf must be an integer >= 2\n");
  endif

  ## Create input to FIS using grid points and reference values.

  num_inputs = columns (fis.input);
  num_grid_pts = prod (grids);
  fis_input = zeros (num_grid_pts, num_inputs);

  for i = 1 : num_inputs
    if (i == input_axes(1))
      x_axis = (linspace (fis.input(i).range(1), ...
                          fis.input(i).range(2), ...
                          grids(1)))';
    elseif (i == input_axes(2))
      y_axis = (linspace (fis.input(i).range(1), ...
                          fis.input(i).range(2), ...
                          grids(2)))';
    else
      fis_input(:, i) = (ref_input(i) * ones (num_grid_pts))';
    endif
  endfor

  [xx, yy] = meshgrid (x_axis, y_axis);

  fis_input(:, input_axes(1)) = xx(:);
  fis_input(:, input_axes(2)) = yy(:);

  ## Compute the output and reshape it to fit the grid.

  output = evalfis_private (fis_input, fis, num_points);
  z_matrix = reshape (output(:, output_axis), length (x_axis), length (y_axis));

  ## Plot the surface.

  figure ('NumberTitle', 'off', 'Name', fis.name);
  surf (x_axis, y_axis, z_matrix);
  xlabel (fis.input(input_axes(1)).name);
  ylabel (fis.input(input_axes(2)).name);
  zlabel (fis.output(output_axis).name);

endfunction
