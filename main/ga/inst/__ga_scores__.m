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

## Author: Luca Favatella <slackydeb@gmail.com>
## Version: 5.3

function Scores = __ga_scores__ (fitnessfcn, Population, InitialScores = [])
  [nrPopulation ncPopulation] = size (Population);
  [nrInitialScores ncInitialScores] = size (InitialScores);
  #assert ((ncInitialScores == 0) || (ncInitialScores == 1)); ## DEBUG
  #assert (nrInitialScores <= nrPopulation); ## DEBUG
  if (nrInitialScores > 0)
    Scores(1:nrInitialScores, 1) = InitialScores(1:nrInitialScores, 1);
  endif
  for index = (nrInitialScores + 1):nrPopulation
    Scores(index, 1) = fitnessfcn (Population(index, 1:ncPopulation));
  endfor
  #assert (size (Scores), [nrPopulation 1]); ## DEBUG
endfunction