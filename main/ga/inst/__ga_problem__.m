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
## Version: 3.2

function x = __ga_problem__ (problem)

  individui_migliori = [];

  popolazione = (gaoptimget (problem.options, 'CreationFcn')) (problem.nvars, problem.fitnessfcn, problem.options);

  %% in this while, generation is fixed
  generazione = 1;
  individui_migliori(generazione, :) = (__ga_sort_ascend_population__ (problem.fitnessfcn, popolazione))(1, :);
  while (! __ga_stop__ (problem, popolazione, generazione))

    %% doing this initialization here to make the variable
    %% popolazione_futura visible at the end of the next while
    popolazione_futura = zeros (gaoptimget (problem.options,
                                            'PopulationSize'),
                                problem.nvars);

    %% elitist selection
    for i = 1:(gaoptimget (problem.options, 'EliteCount'))
      popolazione_futura(i, :) = (__ga_sort_ascend_population__ (problem.fitnessfcn, popolazione))(i, :);
    endfor

    %% in this while the individual of the new generation is fixed
    for i = (1 + (gaoptimget (problem.options,
                              'EliteCount'))):(gaoptimget (problem.options,
                                                           'PopulationSize'))

      %% stochastically choosing the genetic operator to apply
      aux_operatore = rand ();

      %% crossover
      if (aux_operatore < gaoptimget (problem.options,
                                      'CrossoverFraction'))
	index_parents = (gaoptimget (problem.options,
                                     'SelectionFcn')) (problem.fitnessfcn,
                                                       popolazione);
	parents = [popolazione(index_parents(1), :);
                   popolazione(index_parents(2), :)];
        aux_debug = (gaoptimget (problem.options, 'CrossoverFcn') (parents)) (1, :);
        size (aux_debug) %%debug
        size (popolazione_futura(i, :)) %%debug
	popolazione_futura(i, :) = aux_debug;

	%% mutation
      else
	index_parent = (gaoptimget (problem.options,
                                    'SelectionFcn')) (problem.fitnessfcn,
                                                      popolazione);
        aux_debug2 = (gaoptimget (problem.options, 'MutationFcn')) (popolazione(index_parent(1), :));
        size (aux_debug2) %%debug
        size (popolazione_futura(i, :)) %%debug
	popolazione_futura(i, :) = aux_debug2;
      endif
    endfor

    popolazione = popolazione_futura;
    generazione++;
    individui_migliori(generazione, :) = (__ga_sort_ascend_population__ (problem.fitnessfcn, popolazione))(1, :);
  endwhile

  x = individui_migliori(generazione, :);
endfunction