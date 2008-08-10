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
## Version: 4.13

function [x fval exitflag output population scores] = __ga_problem__ (problem)
  output.randstate = rand ("state");
  output.randnstate = randn ("state");
  state.StartTime = time ();

  state.Population = __ga_set_initial_population__ (problem.nvars,
                                                    problem.fitnessfcn,
                                                    problem.options);

  state.Score = __ga_scores__ (problem.fitnessfcn, state.Population);
                                #TODO consider InitialScores
                                #TODO write __ga_set_initial_scores__
                                #TODO delete __ga_calcola_img_fitnessfcn__

  state.Generation = 0;
  state.Best(state.Generation + 1, 1) = min (state.Score);

  ## in this while, generation is fixed
  while (! __ga_stop__ (problem, state))

    ## elitist selection
    [trash IndexSortedScores] = sort (state.Score);
    popolazione_futura(1:problem.options.EliteCount,
                       1:problem.nvars) = \
        state.Population(1:problem.options.EliteCount,
                         1:problem.nvars);

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
                                #DONE state.Score
                                #DONE state.Generation
                                #DONE state.StartTime
                                #state.StopFlag
                                #state.Selection
                                #state.Expectation
                                #DONE state.Best
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
    state.Score = __ga_scores__ (problem.fitnessfcn, state.Population);
    state.Generation++;
    state.Best(state.Generation + 1, 1) = min (state.Score);
  endwhile

  ## return variables
  ##
  [trash IndexMinScore] = min (state.Score);
  x = state.Population(IndexMinScore, 1:problem.nvars);

  fval = problem.fitnessfcn (x);

                                #TODO exitflag

  ## output.randstate and output.randnstate must be assigned at the
  ## start of the algorithm
  output.generations = state.Generation;
                                #TODO output (funccount, message,
                                #maxconstraint)

  population = state.Population;

  scores = state.Score;
endfunction