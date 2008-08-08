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
## Version: 0.3.1

function mutationChildren = \
      mutationgaussian (parents,
                        options, nvars, FitnessFcn, state,
                        thisScore, thisPopulation)
  [nr, nc] = size (options.PopInitRange);

  if ((nr != 2)
      ((nc != 1) && (nc != nvars)))
    error ("'PopInitRange' must be 2-by-1 or 2-by-nvars");
  endif

  ## obtain a 2-by-nvars LocalPopInitRange
  LocalPopInitRange = options.PopInitRange;
  if (nc == 1)
    LocalPopInitRange = LocalPopInitRange * ones (1, nvars);
  endif

  LB = LocalPopInitRange(1, 1:nvars);
  UB = LocalPopInitRange(2, 1:nvars);

  ## start mutationgaussian logic
  p1 = parents(1, 1:nvars);
  Scale = options.MutationFcn{1, 2};
  assert (size (Scale), [1 1]); ## DEBUG
  Shrink = options.MutationFcn{1, 3};
  assert (size (Shrink), [1 1]); ## DEBUG

  ## initial standard deviation (i.e. when state.Generation == 0)
  tmp_std = Scale * (UB - LB); ## vector = scalar * vector

  ## recursively compute current standard deviation
  for k = 1:state.Generation
    tmp_std = \ ## vector = scalar * vector
        (1 - Shrink * (k / options.Generations)) * tmp_std;
  endfor

  current_std = tmp_std;
  assert (size (current_std), [1 nvars]); ## DEBUG

  ## finally add random numbers
  mutationChildren = p1 + current_std .* randn (1, nvars);
endfunction