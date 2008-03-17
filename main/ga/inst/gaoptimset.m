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
## @deftypefn{Function File} gaoptimset
## @deftypefnx{Function File} {@var{options} =} gaoptimset
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
## The options structure.
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
## Version: 3.0

function options = gaoptimset (varargin)
	if (nargout == 0)
		warning ("Dovrei mostrare una lista completa dei parametri con i loro argomenti.");
		print_usage ();
	elseif (nargout > 1)
		print_usage ();
	else
		if (mod (length (varargin), 2) == 1)
			print_usage ();
		else
			%definisco una struttura default_options con tutti i campi di default
			default_options.CreationFcn = @gacreationuniform;
			default_options.CrossoverFcn = @crossoverscattered;
			default_options.CrossoverFraction = 0.8;
			default_options.EliteCount = 2;
			default_options.FitnessLimit = -Inf;
			default_options.Generations = 100;
			default_options.MutationFcn = @mutationsinglepoint;
			default_options.PopInitRange = [0; 1];
			default_options.PopulationSize = 20;
			default_options.SelectionFcn = @selectionroulette;
	
			%setto nella variabile di ritorno options i parametri specificati in ingresso alla funzione
			i = 1;
			while (length (varargin) >= (i + 1))
				switch (varargin{i})
					case 'CreationFcn'
						options.CreationFcn = varargin{i + 1};
					case 'CrossoverFcn'
						options.CrossoverFcn = varargin{i + 1};
					case 'CrossoverFraction'
						options.CrossoverFraction = varargin{i + 1};
					case 'EliteCount'
						options.EliteCount = varargin{i + 1};
					case 'FitnessLimit'
						options.FitnessLimit = varargin{i + 1};
					case 'Generations'
						options.Generations = varargin{i + 1};
					case 'MutationFcn'
						options.MutationFcn = varargin{i + 1};
					case 'PopInitRange'
						options.PopInitRange = varargin{i + 1};
					case 'PopulationSize'
						options.PopulationSize = varargin{i + 1};
					case 'SelectionFcn'
						options.SelectionFcn = varargin{i + 1};
				endswitch
				i = i + 2;
			endwhile
	
			%setto con i valori di default i parametri non settati
			if ((! exist ('options', 'var')) || (! isfield (options, 'CreationFcn')))
				options.CreationFcn = default_options.CreationFcn;
			endif
			if ((! exist ('options', 'var')) || (! isfield (options, 'CrossoverFcn')))
				options.CrossoverFcn = default_options.CrossoverFcn;
			endif
			if ((! exist ('options', 'var')) || (! isfield (options, 'CrossoverFraction')))
				options.CrossoverFraction = default_options.CrossoverFraction;
			endif
			if ((! exist ('options', 'var')) || (! isfield (options, 'EliteCount')))
				options.EliteCount = default_options.EliteCount;
			endif
			if ((! exist ('options', 'var')) || (! isfield (options, 'FitnessLimit')))
				options.FitnessLimit = default_options.FitnessLimit;
			endif
			if ((! exist ('options', 'var')) || (! isfield (options, 'Generations')))
				options.Generations = default_options.Generations;
			endif
			if ((! exist ('options', 'var')) || (! isfield (options, 'MutationFcn')))
				options.MutationFcn = default_options.MutationFcn;
			endif
			if ((! exist ('options', 'var')) || (! isfield (options, 'PopInitRange')))
				options.PopInitRange = default_options.PopInitRange;
			endif
			if ((! exist ('options', 'var')) || (! isfield (options, 'PopulationSize')))
				options.PopulationSize = default_options.PopulationSize;
			endif
			if ((! exist ('options', 'var')) || (! isfield (options, 'SelectionFcn')))
				options.SelectionFcn = default_options.SelectionFcn;
			endif
		endif
	endif
endfunction