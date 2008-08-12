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
## @deftypefn{Function File} {@var{mutationChildren} =} mutationgaussian (@var{parents}, @var{options}, @var{nvars}, @var{FitnessFcn}, @var{state}, @var{thisScore}, @var{thisPopulation})
## Single point mutation.
##
## @seealso{ga, gaoptimset}
## @end deftypefn

## Author: Luca Favatella <slackydeb@gmail.com>
## Version: 1.3

function mutationChildren = \
      mutationgaussian (parents,
                        options, nvars, FitnessFcn, state,
                        thisScore, thisPopulation)
  [nr_parents nc_parents] = size (parents);
  #assert (nr_parents, 1); ## DEBUG
  [nrPopInitRange, ncPopInitRange] = size (options.PopInitRange);
  #assert (nrPopInitRange, 2); ## DEBUG
  #assert ((ncPopInitRange == 1) || (ncPopInitRange == nvars)); ## DEBUG
  #assert (columns (thisPopulation), nvars); ## DEBUG

  ## obtain a 2-by-nvars LocalPopInitRange
  LocalPopInitRange = options.PopInitRange;
  if (ncPopInitRange == 1)
    LocalPopInitRange(1:2, 1:nvars) = LocalPopInitRange * ones (1, nvars);
  endif
  LB(1, 1:nvars) = LocalPopInitRange(1, 1:nvars);
  UB(1, 1:nvars) = LocalPopInitRange(2, 1:nvars);

  ## start mutationgaussian logic
  Scale = options.MutationFcn{1, 2};
  #assert (size (Scale), [1 1]); ## DEBUG
  Shrink = options.MutationFcn{1, 3};
  #assert (size (Shrink), [1 1]); ## DEBUG

  ## initial standard deviation (i.e. when state.Generation == 0)
  tmp_std = Scale * (UB - LB); ## vector = scalar * vector

  ## recursively compute current standard deviation
  for k = 1:state.Generation
    tmp_std(1, 1:nvars) = (1 - Shrink * (k / options.Generations)) * tmp_std;
  endfor
  current_std(1, 1:nvars) = tmp_std;
  expanded_current_std(1:nc_parents, 1:nvars) = \
      ones (nc_parents, 1) * current_std;

  ## finally add random numbers
  mutationChildren(1:nc_parents, 1:nvars) = \
      thisPopulation(parents(1, 1:nc_parents), 1:nvars) + \
      expanded_current_std .* randn (nc_parents, nvars);
endfunction