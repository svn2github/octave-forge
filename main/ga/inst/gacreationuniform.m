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
## Version: 4.7.2

function Population = gacreationuniform (GenomeLength, FitnessFcn, options)

  ## obtain a 2-by-GenomeLength LocalPopInitRange
  switch (columns (options.PopInitRange))
      case 1
        LocalPopInitRange(1:2, 1:GenomeLength) = \
            options.PopInitRange(1:2, 1) * ones (1, GenomeLength);
      case GenomeLength
        LocalPopInitRange(1:2, 1:GenomeLength) = \
            options.PopInitRange(1:2, 1:GenomeLength);
  endswitch

  LB(1, 1:GenomeLength) = LocalPopInitRange(1, 1:GenomeLength);
  UB(1, 1:GenomeLength) = LocalPopInitRange(2, 1:GenomeLength);

  ## pseudocode
  ##
  ## Population = Delta * RandomPopulationBetween0And1 + Offset
  Population(1:options.PopulationSize, 1:GenomeLength) = \
      ((ones (options.PopulationSize, 1) * (UB - LB)) .* \
       rand (options.PopulationSize, GenomeLength)) + \
      (ones (options.PopulationSize, 1) * LB);
endfunction