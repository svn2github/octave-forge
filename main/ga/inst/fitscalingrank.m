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
## @deftypefn{Function File} {@var{expectation} =} fitscalingrank (@var{scores}, @var{nParents})
## Convert the raw fitness scores that are returned by the fitness
## function to values in a range that is suitable for the selection
## function.
##
## @seealso{ga, gaoptimset}
## @end deftypefn

## Author: Luca Favatella <slackydeb@gmail.com>
## Version: 1.1

function expectation = fitscalingrank (scores, nParents)
  [nr nc] = size (scores);
  #assert (nc, 1); ## DEBUG
  r(1, 1:nr) = ranks (scores);
                                #TODO
                                #ranks ([7,2,2]) == [3.0,1.5,1.5]
                                #is [3,1,2] (or [3,2,1]) useful? 
  expectation_wo_nParents(1, 1:nr) = arrayfun (@(n) 1 / sqrt (n), r);
  expectation(1, 1:nr) = \
      (nParents / sum (expectation_wo_nParents)) * \
      expectation_wo_nParents;
  #assert (sum (expectation), nParents, 1e-9); ## DEBUG

  ## start DEBUG
  #[trash index_min_scores] = min (scores);
  #[trash index_max_expectation] = max (expectation);
  #assert (index_min_scores, index_max_expectation);
  #[trash index_max_scores] = max (scores);
  #[trash index_min_expectation] = min (expectation);
  #assert (index_max_scores, index_min_expectation);
  ## end DEBUG
endfunction