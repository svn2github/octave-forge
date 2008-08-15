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
## @deftypefn{Function File} {@var{Population} =} __ga_initial_population__ (@var{GenomeLength}, @var{FitnessFcn}, @var{options})
## Create an initial population.
##
## @seealso{__ga_problem__}
## @end deftypefn

## Author: Luca Favatella <slackydeb@gmail.com>
## Version: 3.2

                                #TODO consider PopulationSize as a
                                #vector for multiple subpopolations

function Population = \
      __ga_initial_population__ (GenomeLength, FitnessFcn, options)
  [nr nc] = size (options.InitialPopulation);
  if ((nr == 0) || (nc == 0))
    Population(1:options.PopulationSize, 1:GenomeLength) = \
        options.CreationFcn (GenomeLength, FitnessFcn, options);
  elseif (nc == GenomeLength)

    ## nr > 0
    if (nr < options.PopulationSize)

      ## create a complete new population, and then select only needed
      ## individuals (creating only a partial population is difficult)
      CreatedPopulation(1:options.PopulationSize, 1:GenomeLength) = \
          options.CreationFcn (GenomeLength, FitnessFcn, options);
      Population(1:options.PopulationSize, 1:GenomeLength) = \
          vertcat (options.InitialPopulation(1:nr, 1:GenomeLength),
                   CreatedPopulation(1:(options.PopulationSize - nr),
                                     1:GenomeLength));
    elseif (nr == options.PopulationSize)
      Population(1:options.PopulationSize, 1:GenomeLength) = \
          options.InitialPopulation;
    else ## nr > options.PopulationSize
      error ("nonempty 'InitialPopulation' must have no more than \
          'PopulationSize' rows");
    endif
  else ## (nc != 0) && (nc != GenomeLength)
    error ("nonempty 'InitialPopulation' must have 'GenomeLength' \
        columns");
  endif
endfunction

%!test
%! GenomeLength = 2;
%! options = gaoptimset ();
%! Population = __ga_initial_population__ (GenomeLength, @rastriginsfcn, options);
%! assert (size (Population), [options.PopulationSize, GenomeLength]);

%!test
%! GenomeLength = 2;
%! options = gaoptimset ("InitialPopulation", [1, 2; 3, 4; 5, 6]);
%! Population = __ga_initial_population__ (GenomeLength, @rastriginsfcn, options);
%! assert (size (Population), [options.PopulationSize, GenomeLength]);