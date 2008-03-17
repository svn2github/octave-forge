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
## @deftypefn{Function File} {@var{val} =} gaoptimget (@var{options}, '@var{name}'}
## Return the value of the parameter @var{name} from the genetic algorithm options structure.
##
## @seealso{gaoptimset}
## @end deftypefn

## Author: Luca Favatella <slackydeb@gmail.com>
## Version: 3.0

function val = gaoptimget (options, name)
	if (nargin != 2)
		print_usage ();
	else
		switch (name)
			case 'CreationFcn'
				val = options.CreationFcn;
			case 'CrossoverFcn'
				val = options.CrossoverFcn;
			case 'CrossoverFraction'
				val = options.CrossoverFraction;
			case 'EliteCount'
				val = options.EliteCount;
			case 'FitnessLimit'
				val = options.FitnessLimit;
			case 'Generations'
				val = options.Generations;
			case 'MutationFcn'
				val = options.MutationFcn;
			case 'PopInitRange'
				val = options.PopInitRange;
			case 'PopulationSize'
				val = options.PopulationSize;
			case 'SelectionFcn'
				val = options.SelectionFcn;
		endswitch
	endif
endfunction