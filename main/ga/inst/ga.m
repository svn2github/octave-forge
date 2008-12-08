## Copyright (C) 2008 Luca Favatella <slackydeb@gmail.com>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn{Function File} {@var{x} =} ga (@var{fitnessfcn}, @var{nvars})
## @deftypefnx{Function File} {@var{x} =} ga (@var{fitnessfcn}, @var{nvars}, @var{A}, @var{b})
## @deftypefnx{Function File} {@var{x} =} ga (@var{fitnessfcn}, @var{nvars}, @var{A}, @var{b}, @var{Aeq}, @var{beq})
## @deftypefnx{Function File} {@var{x} =} ga (@var{fitnessfcn}, @var{nvars}, @var{A}, @var{b}, @var{Aeq}, @var{beq}, @var{LB}, @var{UB})
## @deftypefnx{Function File} {@var{x} =} ga (@var{fitnessfcn}, @var{nvars}, @var{A}, @var{b}, @var{Aeq}, @var{beq}, @var{LB}, @var{UB}, @var{nonlcon})
## @deftypefnx{Function File} {@var{x} =} ga (@var{fitnessfcn}, @var{nvars}, @var{A}, @var{b}, @var{Aeq}, @var{beq}, @var{LB}, @var{UB}, @var{nonlcon}, @var{options})
## @deftypefnx{Function File} {@var{x} =} ga (@var{problem})
## @deftypefnx{Function File} {[@var{x}, @var{fval}] =} ga (@dots{})
## @deftypefnx{Function File} {[@var{x}, @var{fval}, @var{exitflag}] =} ga (@dots{})
## @deftypefnx{Function File} {[@var{x}, @var{fval}, @var{exitflag}, @var{output}] =} ga (@dots{})
## @deftypefnx{Function File} {[@var{x}, @var{fval}, @var{exitflag}, @var{output}, @var{population}] =} ga (@dots{})
## @deftypefnx{Function File} {[@var{x}, @var{fval}, @var{exitflag}, @var{output}, @var{population}, @var{scores}] =} ga (@dots{})
## Find minimum of function using genetic algorithm.
##
## @strong{Inputs}
## @table @var
## @item fitnessfcn
## The objective function to minimize. It accepts a vector @var{x} of
## size 1-by-@var{nvars}, and returns a scalar evaluated at @var{x}.
## @item nvars
## The dimension (number of design variables) of @var{fitnessfcn}.
## @item options
## The structure of the optimization parameters; can be created using
## the @code{gaoptimset} function. If not specified, @code{ga} minimizes
## with the default optimization parameters.
## @item problem
## A structure containing the following fields:
## @itemize @bullet
## @item @code{fitnessfcn}
## @item @code{nvars}
## @item @code{Aineq}
## @item @code{Bineq}
## @item @code{Aeq}
## @item @code{Beq}
## @item @code{lb}
## @item @code{ub}
## @item @code{nonlcon}
## @item @code{randstate}
## @item @code{randnstate}
## @item @code{solver}
## @item @code{options}
## @end itemize
## @end table
##
## @strong{Outputs}
## @table @var
## @item x
## The local unconstrained found minimum to the objective function,
## @var{fitnessfcn}.
## @item fval
## The value of the fitness function at @var{x}.
## @end table
##
## @seealso{gaoptimset}
## @end deftypefn

## Author: Luca Favatella <slackydeb@gmail.com>
## Version: 5.19.3

function [x fval exitflag output population scores] = \
      ga (fitnessfcn_or_problem,
          nvars,
          A = [], b = [],
          Aeq = [], beq = [],
          LB = [], UB = [],
          nonlcon = [],
          options = gaoptimset ())
  if ((nargout > 6) ||
      (nargin < 1) ||
      (nargin == 3) ||
      (nargin == 5) ||
      (nargin == 7) ||
      (nargin > 10))
    print_usage ();
  else

    ## retrieve the problem structure
    if (nargin == 1)
      problem = fitnessfcn_or_problem;
    else
      problem.fitnessfcn = fitnessfcn_or_problem;
      problem.nvars = nvars;
      problem.Aineq = A;
      problem.Bineq = b;
      problem.Aeq = Aeq;
      problem.Beq = beq;
      problem.lb = LB;
      problem.ub = UB;
      problem.nonlcon = nonlcon;
      problem.randstate = rand ("state");
      problem.randnstate = randn ("state");
      problem.solver = "ga";
      problem.options = options;
    endif

    ## call the function that manages the problem structure
    [x fval exitflag output population scores] = __ga_problem__ (problem);
  endif
endfunction


%!# nvars == 2
%!# min != zeros (1, nvars)

%!# TODO: get this test working with tol = 1e-6
%!xtest
%! min = [-1, 2];
%! assert (ga (struct ("fitnessfcn", @(x) rastriginsfcn (x - min), "nvars", 2, "options", gaoptimset ("FitnessLimit", 1e-7, "Generations", 1000, "PopInitRange", [-5; 5], "PopulationSize", 200))), min, 1e-5)


%!# nvars == 1
%!# min == zeros (1, nvars)

%!test assert (ga (@(x) x ** 2, 1), 0, 1e-3)

%!test assert (ga (@(x) (x ** 2) - (cos (2 * pi * x)) + 1, 1), 0, 1e-3)


%!# nvars == 2
%!# min == zeros (1, nvars)

%!xtest assert (ga (@rastriginsfcn, 2), [0, 0], 1e-3)

%!# TODO: get this test working with tol = 1e-6
%!xtest assert (ga (struct ("fitnessfcn", @rastriginsfcn, "nvars", 2, "options", gaoptimset ("FitnessLimit", 1e-7, "Generations", 1000))), zeros (1, 2), 1e-4)

%!# TODO: get this test working with tol = 1e-6
%!xtest assert (ga (struct ("fitnessfcn", @rastriginsfcn, "nvars", 2, "options", gaoptimset ("FitnessLimit", 1e-7, "PopulationSize", 200))), zeros (1, 2), 1e-4)


%!# nvars == 4
%!# min == zeros (1, nvars)

%!# TODO: get this test working with tol = 1e-3
%!xtest assert (ga (struct ("fitnessfcn", @(x) rastriginsfcn (x(1:2)) + ((x(3) ** 2) - (cos (2 * pi * x(3))) + 1) + (x(4) ** 2), "nvars", 4, "options", gaoptimset ("EliteCount", 5, "FitnessLimit", 1e-7, "PopInitRange", [-2; 2], "PopulationSize", 200))), zeros (1, 4), 1e-2)