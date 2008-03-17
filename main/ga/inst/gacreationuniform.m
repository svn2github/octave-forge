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
## @deftypefn{Function File} {@var{Population} =} gacreationuniform (@var{GenomeLength}, @var{FitnessFcn}, @var{options})
## Create a random initial population with a uniform distribution.
##
## @strong{Inputs}
## @table @var
## @item GenomeLength
## The number of indipendent variables for the fitness function.
## @item FitnessFcn
## The fitness function.
## @item options
## The options structure.
## @end table
##
## @strong{Outputs}
## @table @var
## @item Population
## The initial population for the genetic algorithm.
## @end table
##
## @seealso{ga, gaoptimset}
## @end deftypefn

## Author: Luca Favatella <slackydeb@gmail.com>
## Version: 3.0

function Population = gacreationuniform (GenomeLength, FitnessFcn, options)

	%variabili d'appoggio
	tmp_aux = gaoptimget (options, 'PopInitRange');
	lb = min (tmp_aux(1, 1), tmp_aux(2, 1));
	ub = max (tmp_aux(1, 1), tmp_aux(2, 1));

	n_rows_aux = gaoptimget (options, 'PopulationSize');
	Population = ((ub - lb) * rand (n_rows_aux, GenomeLength)) + (lb * ones (n_rows_aux, GenomeLength));
endfunction