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
## @deftypefn{Function File} {@var{x} =} ga (@var{fitnessfcn}, @var{nvars})
## @deftypefnx{Function File} {@var{x} =} ga (@var{fitnessfcn}, @var{nvars}, @var{options})
## @deftypefnx{Function File} {@var{x} =} ga (@var{problem})
## Find minimum of function using genetic algorithm.
##
## @strong{Inputs}
## @table @var
## @item fitnessfcn
## The objective function to minimize. It accepts a vector @var{x} of size 1-by-@var{nvars}, and returns a scalar evaluated at @var{x}.
## @item nvars
## The number of variables of @var{fitnessfcn}.
## @item options
## The structure of the optimization parameters; can be created with using the @code{gaoptimset} function. If not specified, @code{ga} minimizes with the default optimization parameters.
## @item problem
## A structure containing the following fields: @var{fitnessfcn}, @var{nvars} and @var{options}.
## @end table
##
## @strong{Outputs}
## @table @var
## @item x
## The local unconstrained found minimum to the objective function.
## @end table
##
## @seealso{gaoptimset}
## @end deftypefn

## Author: Luca Favatella <slackydeb@gmail.com>
## Version: 5.0

function [x fval exitflag output population scores] = ga (varargin)
  if ((nargout > 6) ||
      (length (varargin) < 1) ||
      (length (varargin) == 3) ||
      (length (varargin) == 5) ||
      (length (varargin) == 7) ||
      (length (varargin) > 10))
    print_usage ();
  else

    ## retrieve problem structure
    if (length (varargin) == 1)
      problem = varargin{1};
    else ## length (varargin) >= 2

      ## set default options field
      problem.options = gaoptimset;

      ## set fields specified
      problem.fitnessfcn = varargin{1};
      problem.nvars = varargin{2};
      if (length (varargin) >= 4)
        problem.Aineq = varargin{3};
        problem.Bineq = varargin{4};
        if (length (varargin) >= 6)
          problem.Aeq = varargin{5};
          problem.Beq = varargin{6};
          if (length (varargin) >= 8)
            problem.lb = varargin{7};
            problem.ub = varargin{8};
            if (length (varargin) >= 9)
              problem.nonlcon = varargin{9};

              ## if a custom options field is specified, overwrite the
              ## default one
              if (length (varargin) == 10)
                problem.options = varargin{10};
              endif
            endif
          endif
        endif
      endif
    endif

    [x fval exitflag output population scores] = __ga_problem__ (problem);
  endif
endfunction

%!assert (ga (@rastriginsfcn, 2), [0, 0], 1e-6)

%!function retval = test_4_variabili (x)
%! retval = 0;
%! retval += 20 + (x(1) ** 2) + (x(2) ** 2) - 10 * (cos (2 * pi * x(1)) + cos (2 * pi * x(2)));
%! retval += (x(3) ** 2) - (cos (2 * pi * x(3))) + 1;
%! retval += x(4) ** 2;

%!assert (ga (@test_4_variabili, 4, [], [], [], [], [], [], [], gaoptimset ('FitnessLimit', 0.001, 'PopInitRange', [-1; 1])), [0, 0, 0, 0], sqrt(0.001))

%!function retval = test_rastriginsfcn_traslato (t)
%! min = [1, 0];
%! x = t - min;
%! retval = 20 + (x(1) ** 2) + (x(2) ** 2) - 10 * (cos (2 * pi * x(1)) + cos (2 * pi * x(2)));

%!assert (ga (@test_rastriginsfcn_traslato, 2, [], [], [], [], [], [], [], gaoptimset ('FitnessLimit', 0.001, 'PopInitRange', [-2; 2], 'PopulationSize', 100)), [1, 0], sqrt(0.001))

%!function retval = test_f_con_inf_minimi_locali (x)
%! retval = (x ** 2) - (cos (2 * pi * x)) + 1;

%!assert (ga (@test_f_con_inf_minimi_locali, 1, [], [], [], [], [], [], [], gaoptimset ('CrossoverFcn', @crossoversinglepoint, 'EliteCount', 1, 'FitnessLimit', 0.001, 'Generations', 25, 'PopInitRange', [-5; 5])), 0, sqrt(0.001)) 

%!function retval = test_parabola (x)
%! retval = x ** 2;

%!assert (ga (@test_parabola, 1, [], [], [], [], [], [], [], gaoptimset ('CrossoverFcn', @crossoversinglepoint, 'EliteCount', 1, 'FitnessLimit', 0.001, 'Generations', 10, 'PopInitRange', [-1; 1])), 0, sqrt(0.001))