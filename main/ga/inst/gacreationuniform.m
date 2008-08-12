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
## Version: 4.4

function Population = gacreationuniform (GenomeLength, FitnessFcn, options)
  [nr, nc] = size (options.PopInitRange);

  #if ((nr != 2)
  #    ((nc != 1) && (nc != GenomeLength)))
  #  error ("'PopInitRange' must be 2-by-1 or 2-by-GenomeLength");
  #endif

  ## obtain a 2-by-GenomeLength LocalPopInitRange
  LocalPopInitRange = options.PopInitRange;
  if (nc == 1)
    LocalPopInitRange = LocalPopInitRange * ones (1, GenomeLength);
  endif

  LB = LocalPopInitRange(1, 1:GenomeLength);
  UB = LocalPopInitRange(2, 1:GenomeLength);

  ## pseudocode
  ##
  ## Population = Delta * RandomPopulationBetween0And1 + Offset
  Population = \
      ((ones (options.PopulationSize, 1) * (UB - LB)) .* \
       rand (options.PopulationSize, GenomeLength)) + \
      (ones (options.PopulationSize, 1) * LB);
endfunction

%!test
%! GenomeLength = 2;
%! FitnessFcn = @rastriginsfcn;
%! options = gaoptimset ();
%! Population = gacreationuniform (GenomeLength, FitnessFcn, options);
%! assert (size (Population), [options.PopulationSize, GenomeLength]);