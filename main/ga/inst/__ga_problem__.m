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

## Author: Luca Favatella <slackydeb@gmail.com>
## Version: 4.5.1

function [x fval exitflag output population scores] = __ga_problem__ (problem)
  individui_migliori = [];
  state.Population = __ga_set_initial_population__ (problem.nvars,
                                                    problem.fitnessfcn,
                                                    problem.options);
                                #TODO
                                #consider InitialScores for state structure

  %% in this while, generation is fixed
  state.Generation = 1; ## TODO initial generation should be 0 (for state structure)
  individui_migliori(state.Generation, :) = (__ga_sort_ascend_population__ (problem.fitnessfcn, state.Population))(1, :);
  while (! __ga_stop__ (problem, state.Population, state.Generation))

    %% doing this initialization here to make the variable
    %% popolazione_futura visible at the end of the next while
    popolazione_futura = zeros (problem.options.PopulationSize,
                                problem.nvars);

    %% elitist selection
    for i = 1:problem.options.EliteCount
      popolazione_futura(i, :) = (__ga_sort_ascend_population__ (problem.fitnessfcn, state.Population))(i, :);
    endfor

    %% in this while the individual of the new generation is fixed
    for i = (1 + problem.options.EliteCount):problem.options.PopulationSize

      %% stochastically choosing the genetic operator to apply
      aux_operatore = rand ();

      %% crossover
      if (aux_operatore < problem.options.CrossoverFraction)
        index_parents = problem.options.SelectionFcn (problem.fitnessfcn,
                                                      state.Population);
        parents = [state.Population(index_parents(1), :);
                   state.Population(index_parents(2), :)];
        popolazione_futura(i, :) = \
            problem.options.CrossoverFcn (parents,
                                          problem.options,
                                          problem.nvars,
                                          problem.fitnessfcn,
                                          false, ## unused
                                          state.Population);

      %% mutation
      else
        index_parent = problem.options.SelectionFcn (problem.fitnessfcn,
                                                     state.Population);
        parent = state.Population(index_parent(1), :);
        ## start preparing state structure
                                #DONE state.Population
                                #state.Score
                                #DONE state.Generation
                                #state.StartTime
                                #state.StopFlag
                                #state.Selection
                                #state.Expectation
                                #state.Best
                                #state.LastImprovement
                                #state.LastImprovementTime
                                #state.NonlinIneq
                                #state.NonlinEq
        ## end preparing state structure
        popolazione_futura(i, :) = \ #TODO parent -> parents
            problem.options.MutationFcn{1, 1} (parent,
                                               problem.options,
                                               problem.nvars,
                                               problem.fitnessfcn,
                                               state,
                                               false, #TODO false -> thisScore
                                               state.Population);
      endif
    endfor

    state.Population = popolazione_futura;
    state.Generation++;
    individui_migliori(state.Generation, :) = (__ga_sort_ascend_population__ (problem.fitnessfcn, state.Population))(1, :);
  endwhile

  x = individui_migliori(state.Generation, :);
endfunction