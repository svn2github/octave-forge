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
## Version: 1.1

function mutationChildren = \
      __ga_mutationfcn__ (parents, options, nvars, FitnessFcn,
                          state, thisScore,
                          thisPopulation)

  ## preconditions
  [nr_parents nc_parents] = size (parents);
  assert (nr_parents, 1); ## DEBUG
                                #TODO move controls on
                                #options.PopInitRange in a more general
                                #function
  [nrPopInitRange, ncPopInitRange] = size (options.PopInitRange);
  assert (nrPopInitRange, 2); ## DEBUG
  assert ((ncPopInitRange == 1) || (ncPopInitRange == nvars)); ## DEBUG
  assert (columns (thisPopulation), nvars); ## DEBUG

  mutationChildren = \
      options.MutationFcn{1, 1} (parents, options, nvars, FitnessFcn,
                                 state, thisScore,
                                 thisPopulation);

  ## postconditions
  assert (size (mutationChildren), [nc_parents, nvars]); ## DEBUG
endfunction