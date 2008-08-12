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
## Version: 5.2

                                #state structure fields
                                #DONE state.Population
                                #DONE state.Score
                                #DONE state.Generation
                                #DONE state.StartTime
                                #state.StopFlag
                                #DONE state.Selection
                                #DONE state.Expectation
                                #DONE state.Best
                                #state.LastImprovement
                                #state.LastImprovementTime
                                #state.NonlinIneq
                                #state.NonlinEq

function [x fval exitflag output population scores] = __ga_problem__ (problem)

  ## first instruction
  state.StartTime = time ();

  ## second instruction
  output = struct ("randstate", rand ("state"),
                   "randnstate", randn ("state"));

  ## start "instructions not to be executed at each generation"
  state.Population(1:problem.options.PopulationSize, 1:problem.nvars) = \
      __ga_initial_population__ (problem.nvars,
                                 problem.fitnessfcn,
                                 problem.options);
  state.Score(1:problem.options.PopulationSize, 1) = \
      __ga_scores__ (problem.fitnessfcn,
                     state.Population,
                     problem.options.InitialScores);
  state.Generation = 0;

  ReproductionCount.elite = problem.options.EliteCount;
  ReproductionCount.crossover = \
      fix (problem.options.CrossoverFraction *
           (problem.options.PopulationSize - problem.options.EliteCount));
  ReproductionCount.mutation = \
      problem.options.PopulationSize - (ReproductionCount.elite +
                                        ReproductionCount.crossover);
  #assert (ReproductionCount.elite +
  #        ReproductionCount.crossover +
  #        ReproductionCount.mutation, problem.options.PopulationSize); ## DEBUG

  state.Selection.elite = 1:ReproductionCount.elite;
  state.Selection.crossover = \
      ReproductionCount.elite + (1:ReproductionCount.crossover);
  state.Selection.mutation = \
      ReproductionCount.elite + ReproductionCount.crossover + \
      (1:ReproductionCount.mutation);
  #assert (length (state.Selection.elite) +
  #        length (state.Selection.crossover) +
  #        length (state.Selection.mutation),
  #        problem.options.PopulationSize); ##DEBUG

  parentsCount.crossover = 2 * ReproductionCount.crossover;
  parentsCount.mutation = 1 * ReproductionCount.mutation;
  nParents = parentsCount.crossover + parentsCount.mutation;

  parentsSelection.crossover = 1:parentsCount.crossover;
  parentsSelection.mutation = \
      parentsCount.crossover + (1:parentsCount.mutation);
  #assert (length (parentsSelection.crossover) +
  #        length (parentsSelection.mutation), nParents); ## DEBUG
  ## end "instructions not to be executed at each generation"

  ## start "instructions to be executed at each generation"
  state.Expectation(1, 1:problem.options.PopulationSize) = \
      problem.options.FitnessScalingFcn (state.Score, nParents);
  state.Best(state.Generation + 1, 1) = min (state.Score);
  ## end "instructions to be executed at each generation"

  while (! __ga_stop__ (problem, state)) ## fix a generation

    ## elite
    if (ReproductionCount.elite > 0)
      [trash IndexSortedScores] = sort (state.Score);
      NextPopulation(state.Selection.elite, 1:problem.nvars) = \
          state.Population(IndexSortedScores(1:ReproductionCount.elite, 1),
                           1:problem.nvars);
      #assert (size (NextPopulation),
      #        [ReproductionCount.elite, problem.nvars]); ## DEBUG
    endif

    ## selection for crossover and mutation
    parents = problem.options.SelectionFcn (state.Expectation,
                                            nParents,
                                            problem.options);
    #assert (size (parents), [1, nParents]); ## DEBUG

    ## crossover
    if (ReproductionCount.crossover > 0)
      NextPopulation(state.Selection.crossover, 1:problem.nvars) = \
          problem.options.CrossoverFcn (parents(1, parentsSelection.crossover),
                                        problem.options,
                                        problem.nvars,
                                        problem.fitnessfcn,
                                        false, ## unused
                                        state.Population);
      tmp = ReproductionCount.elite + ReproductionCount.crossover;
      #assert (size (NextPopulation), [tmp, problem.nvars]); ## DEBUG
    endif

    ## mutation
    if (ReproductionCount.mutation > 0)
      NextPopulation(state.Selection.mutation, 1:problem.nvars) = \
          problem.options.MutationFcn{1, 1} (parents(1,
                                                     parentsSelection.mutation),
                                             problem.options,
                                             problem.nvars,
                                             problem.fitnessfcn,
                                             state,
                                             state.Score,
                                             state.Population);
      #assert (size (NextPopulation),
      #        [problem.options.PopulationSize, problem.nvars]); ## DEBUG
    endif

    ## update state structure
    state.Population(1:problem.options.PopulationSize,
                     1:problem.nvars) = NextPopulation;
    clear -v NextPopulation;
    state.Score(1:problem.options.PopulationSize, 1) = \
        __ga_scores__ (problem.fitnessfcn, state.Population);
    state.Generation++;
    state.Expectation(1, 1:problem.options.PopulationSize) = \
        problem.options.FitnessScalingFcn (state.Score, nParents);
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
                                #TODO output.funccount
                                #TODO output.message
                                #TODO output.maxconstraint

  population = state.Population;

  scores = state.Score;
endfunction