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
## @deftypefn{Function File} {@var{Population} =} __ga_set_initial_population__ (@var{problem})
## Create an initial population.
##
## @seealso{__ga_problem__}
## @end deftypefn

## Author: Luca Favatella <slackydeb@gmail.com>
## Version: 1.1.1

function Population = __ga_set_initial_population__ (problem)
                                #TODO
                                #
                                #consider InitialScores
                                #
                                #consider PopulationSize as a vector for
                                #multiple subpopolations

  [nr, nc] = size (problem.options.InitialPopulation);

  if (nc == 0)
    Population = problem.options.CreationFcn (problem.nvars,
                                              problem.fitnessfcn,
                                              problem.options);
  elseif (nc == problem.nvars)

    ## it is impossible to have a matrix with 0 rows and a positive
    ## number of columns
    ##
    ## so, here nr > 0
    if (nr < problem.options.PopulationSize)
      OptionsWithModifiedPopulationSize = \
          setfield (problem.options,
                    "PopulationSize",
                    problem.options.PopulationSize - nr);
      CreatedPartialPopulation = \
          problem.options.CreationFcn (problem.nvars,
                                       problem.fitnessfcn,
                                       OptionsWithModifiedPopulationSize);
      Population = \
          vertcat (problem.options.InitialPopulation,
                   CreatedPartialPopulation);
    elseif (nr == problem.options.PopulationSize)
      Population = problem.options.InitialPopulation;
    else ## nr > problem.options.PopulationSize
      error ("nonempty 'InitialPopulation' must have no more than \
          'PopulationSize' rows");
    endif
  else
    error ("nonempty 'InitialPopulation' must have 'number of \
        variables' columns");
  endif
endfunction