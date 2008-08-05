## Copyright (C) 2008 Luca Favatella <slackydeb@gmail.com>
##
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## This program  is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; see the file COPYING.  If not, write to the Free
## Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
## 02110-1301, USA.

## -*- texinfo -*-
## @deftypefn{Function File} {@var{options} =} gaoptimset
## @deftypefnx{Function File} {@var{options} =} gaoptimset ('@var{param1}', @var{value1}, '@var{param2}', @var{value2}, @dots{})
## Create genetic algorithm options structure.
##
## @strong{Inputs}
## @table @var
## @item param
## Parameter to set. Any unspecified parameters are set to their default values.
## @item value
## Value of @var{param}.
## @end table
##
## @strong{Outputs}
## @table @var
## @item options
## Structure that contains the options, or parameters, for the generic
## algorithm.
## @end table
##
## @strong{Options}
## @table @code
## @item CreationFcn
## @item CrossoverFcn
## @item CrossoverFraction
## @item EliteCount
## @item FitnessLimit
## @item Generations
## @item MutationFcn
## @item PopInitRange
## @item PopulationSize
## @item SelectionFcn
## @end table
##
## @seealso{ga, gaoptimget}
## @end deftypefn

## Author: Luca Favatella <slackydeb@gmail.com>
## Version: 4.3

function options = gaoptimset (varargin)
  if ((nargout != 1) ||
      (mod (length (varargin), 2) == 1))
    print_usage ();
  else

    ## initialize the return variable to a structure with all parameters
    ## set to their default value
    options = __gaoptimset_default_options__ ();

    ## set custom options
    for i = 1:2:length (varargin)
      param = varargin{i};
      value = varargin{i + 1};
      if (! isfield (options, param))
        error ("wrong parameter");
      else
        options = setfield (options, param, value);
      endif
      i = i + 2;
    endfor
  endif
endfunction