## Copyright (C) 2012 L. Markowsky <lmarkov@users.sourceforge.net>
##
## This file is part of the fuzzy-logic-toolkit.
##
## The fuzzy-logic-toolkit is free software; you can redistribute it
## and/or modify it under the terms of the GNU General Public License
## as published by the Free Software Foundation; either version 3 of
## the License, or (at your option) any later version.
##
## The fuzzy-logic-toolkit is distributed in the hope that it will be
## useful, but WITHOUT ANY WARRANTY; without even the implied warranty
## of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with the fuzzy-logic-toolkit; see the file COPYING.  If not,
## see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{V} =} fcm_init_prototype (@var{X}, @var{k})
##
## Initialize k cluster centers to random locations in the ranges
## given by the min/max values of each feature of the dataset.
##
## @seealso{fcm, fcm_update_membership_fcn, fcm_update_cluster_centers, fcm_compute_objective_fcn, fcm_compute_convergence_criterion}
##
## @end deftypefn

## Author:        L. Markowsky
## Keywords:      fuzzy-logic-toolkit fuzzy partition clustering fcm private
## Directory:     fuzzy-logic-toolkit/inst/private/
## Filename:      fcm_init_prototype.m
## Last-Modified: 7 July 2012

function V = fcm_init_prototype (X, k)

  num_features = columns (X);
  min_feature_value = min (X);
  max_feature_value = max (X);
  V = rand (k, num_features);

  for i = 1 : num_features
    V(:, i) = (max_feature_value(i) - min_feature_value(i)) * V(:, i) + ...
                min_feature_value(i);
  endfor

endfunction
