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
## Version: 3.1

function x = __ga_problem__ (problem)

	%statistica degli individui migliori
	individui_migliori = [];

	popolazione = (gaoptimget (problem.options, 'CreationFcn')) (problem.nvars, problem.fitnessfcn, problem.options);

	%dentro questo while la generazione e' fissata
	generazione = 1;
	individui_migliori(generazione, :) = (__ga_sort_ascend_population__ (problem.fitnessfcn, popolazione))(1, :);
	while (! __ga_stop__ (problem, popolazione, generazione))

		%faccio questa inizializzazione qui per rendere la variabile popolazione_futura visibile alla fine del prossimo while
		popolazione_futura = zeros (gaoptimget (problem.options, 'PopulationSize'), problem.nvars);

		%elitismo
		for i = 1:(gaoptimget (problem.options, 'EliteCount'))
			popolazione_futura(i, :) = (__ga_sort_ascend_population__ (problem.fitnessfcn, popolazione))(i, :);
		endfor

		%dentro questo while l'individuo della nuova generazione e' fissato
		for i = (1 + (gaoptimget (problem.options, 'EliteCount'))):(gaoptimget (problem.options, 'PopulationSize'))

			%scelgo l'operatore genetico da applicare in modo probabilistico
			aux_operatore = rand ();

			%cross_over
			if (aux_operatore < gaoptimget (problem.options, 'CrossoverFraction'))
				index_parents = (gaoptimget (problem.options, 'SelectionFcn')) (problem.fitnessfcn, popolazione);
				parents = [popolazione(index_parents(1), :); popolazione(index_parents(2), :)];
				popolazione_futura(i, :) = gaoptimget (problem.options, 'CrossoverFcn') (parents);

			%mutazione
			else
				index_parent = (gaoptimget (problem.options, 'SelectionFcn')) (problem.fitnessfcn, popolazione);
				popolazione_futura(i, :) = (gaoptimget (problem.options, 'MutationFcn')) (popolazione(index_parent(1), :));
			endif
		endfor

		popolazione = popolazione_futura;
		generazione++;
		individui_migliori(generazione, :) = (__ga_sort_ascend_population__ (problem.fitnessfcn, popolazione))(1, :);
	endwhile

	x = individui_migliori(generazione, :);
endfunction