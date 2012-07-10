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
## @deftypefn {Function File} {@var{cluster_centers} =} gustafson_kessel (@var{input_data}, @var{num_clusters})
## @deftypefnx {Function File} {@var{cluster_centers} =} gustafson_kessel (@var{input_data}, @var{num_clusters}, @var{cluster_volume})
## @deftypefnx {Function File} {@var{cluster_centers} =} gustafson_kessel (@var{input_data}, @var{num_clusters}, @var{cluster_volume}, @var{options})
## @deftypefnx {Function File} {@var{cluster_centers} =} gustafson_kessel (@var{input_data}, @var{num_clusters}, @var{cluster_volume}, [@var{m}, @var{max_iterations}, @var{epsilon}, @var{display_intermediate_results}])
## @deftypefnx {Function File} {[@var{cluster_centers}, @var{soft_partition}, @var{obj_fcn_history}] =} gustafson_kessel (@var{input_data}, @var{num_clusters})
## @deftypefnx {Function File} {[@var{cluster_centers}, @var{soft_partition}, @var{obj_fcn_history}] =} gustafson_kessel (@var{input_data}, @var{num_clusters}, @var{cluster_volume})
## @deftypefnx {Function File} {[@var{cluster_centers}, @var{soft_partition}, @var{obj_fcn_history}] =} gustafson_kessel (@var{input_data}, @var{num_clusters}, @var{cluster_volume}, @var{options})
## @deftypefnx {Function File} {[@var{cluster_centers}, @var{soft_partition}, @var{obj_fcn_history}] =} gustafson_kessel (@var{input_data}, @var{num_clusters}, @var{cluster_volume}, [@var{m}, @var{max_iterations}, @var{epsilon}, @var{display_intermediate_results}])
##
## Using the Gustafson-Kessel algorithm, calculate and return the soft partition
## of a set of unlabeled data points. 
##
## Also, if @var{display_intermediate_results} is true, display intermediate 
## results after each iteration.
##
## The required arguments to gustafson_kessel are:
## @itemize @w
## @item
## @var{input_data} - a matrix of input data points; each row corresponds to one point
## @item
## @var{num_clusters} - the number of clusters to form
## @end itemize
##
## The third (optional) argument to gustafson_kessel is a vector of cluster volumes.
## If omitted, a vector of 1's will be used as the default.
##
## The fourth (optional) argument to gustafson_kessel is a vector consisting of:
## @itemize @w
## @item
## @var{m} - the parameter (exponent) in the objective function; default = 2.0
## @item
## @var{max_iterations} - the maximum number of iterations before stopping; default = 100
## @item
## @var{epsilon} - the stopping criteria; default = 1e-5
## @item
## @var{display_intermediate_results} - if 1, display results after each iteration, and if 0, do not; default = 1
## @end itemize
##
## The default values are used if any of the four elements of the vector are missing or
## evaluate to NaN.
##
## The return values are:
## @itemize @w
## @item
## @var{cluster_centers} - a matrix of the cluster centers; each row corresponds to one point
## @item
## @var{soft_partition} - a constrained soft partition matrix
## @item
## @var{obj_fcn_history} - the values of the objective function after each iteration
## @end itemize
##
## Three important matrices used in the calculation are X (the input points
## to be clustered), V (the cluster centers), and Mu (the membership of each
## data point in each cluster). Each row of X and V denotes a single point,
## and Mu(i, j) denotes the membership degree of input point X(j, :) in the
## cluster having center V(i, :).
##
## X is identical to the required argument @var{input_data}; V is identical
## to the output @var{cluster_centers}; and Mu is identical to the output
## @var{soft_partition}.
##
## If n denotes the number of input points and k denotes the number of
## clusters to be formed, then X, V, and Mu have the dimensions:
##
## @example
## @group
##                               1    2   ...  #features
##                          1 [                           ]
##    X  =  input_data  =   2 [                           ]
##                        ... [                           ]
##                          n [                           ]
## @end group
## @end example
##
## @example
## @group
##                                    1    2   ...  #features
##                               1 [                           ]
##    V  =  cluster_centers  =   2 [                           ]
##                             ... [                           ]
##                               k [                           ]
## @end group
## @end example
##
## @example
## @group
##                                    1    2   ...   n
##                               1 [                    ]
##    Mu  =  soft_partition  =   2 [                    ]
##                             ... [                    ]
##                               k [                    ]
## @end group
## @end example
##
## @seealso{fcm, fcm_demo_1, fcm_demo_2, gustafson_kessel_demo_1, gustafson_kessel_demo_2, partition_coeff, partition_entropy, xie_beni_index}
##
## @end deftypefn

## Author:        L. Markowsky
## Keywords:      fuzzy-logic-toolkit fuzzy partition clustering gustafson_kessel
## Directory:     fuzzy-logic-toolkit/inst/
## Filename:      gustafson_kessel.m
## Last-Modified: 10 July 2012

function [cluster_centers, soft_partition, obj_fcn_history] = ...
           gustafson_kessel (input_data, num_clusters, cluster_volume = [], options = [2.0, 100, 1e-5, 1])

  ## If gustafson_kessel was called with an incorrect number of arguments, or the
  ## arguments do not have the correct type, print an error message and halt.

  if ((nargin < 2) || (nargin > 4))
    puts ("Type 'help gustafson_kessel' for more information.\n");
    error ("gustafson_kessel requires 2, 3, or 4 arguments\n");
  elseif (!is_real_matrix (input_data))
    puts ("Type 'help gustafson_kessel' for more information.\n");
    error ("gustafson_kessel's first argument must be matrix of real numbers\n");
  elseif (!(is_int (num_clusters) && (num_clusters > 1)))
    puts ("Type 'help gustafson_kessel' for more information.\n");
    error ("gustafson_kessel's second argument must be an integer greater than 1\n");
  elseif (!(isequal (cluster_volume, []) || ...
           (isreal (cluster_volume) && isvector (cluster_volume))))
    puts ("Type 'help gustafson_kessel' for more information.\n");
    error ("gustafson_kessel's third (optional) argument must be a vector of real numbers\n");
  elseif (!(isreal (options) && isvector (options)))
    puts ("Type 'help gustafson_kessel' for more information.\n");
    error ("gustafson_kessel's fourth (optional) argument must be a vector of real numbers\n");
  endif

  ## If the cluster volume matrix was not entered, create a default value
  ## (a vector of 1's).

  if (isequal (cluster_volume, []))
    cluster_volume = ones (1, num_clusters);
  endif

  ## Assign options to the more readable variable names: m, max_iterations,
  ## epsilon, and display_intermediate_results. If options are missing or
  ## NaN (not a number), use the default values.

  default_options = [2.0, 100, 1e-5, 1];

  for i = 1 : 4
    if ((length (options) < i) || isna (options(i)) || isnan (options(i)))
      options(i) = default_options(i);
    endif
  endfor

  m = options(1);
  max_iterations = options(2);
  epsilon = options(3);
  display_intermediate_results = options(4);

  ## Call a private function to compute the output.

  [cluster_centers, soft_partition, obj_fcn_history] = ...
    gustafson_kessel_private (input_data, num_clusters, cluster_volume, m, ...
                              max_iterations, epsilon, display_intermediate_results);
endfunction

##------------------------------------------------------------------------------
## Function: gustafson_kessel_private
## Purpose:  Classify unlabeled data points using the Gustafson-Kessel
##           algorithm.
## Note:     This function (gustafson_kessel_private) is an implementation of
##           Algorithm 4.2 in Fuzzy and Neural Control, by Robert Babuska,
##           November 2009, p. 69.
##------------------------------------------------------------------------------

function [V, Mu, obj_fcn_history] = ...
  gustafson_kessel_private (X, k, cluster_volume, m, max_iterations, epsilon, display_intermediate_results)

  ## Initialize the prototype and the calculation.
  V = fcm_init_prototype (X, k);
  obj_fcn_history = zeros (max_iterations);
  convergence_criterion = epsilon + 1;
  iteration = 0;

  ## Calculate a few numbers here to reduce redundant computation.
  k = rows (V);
  n = rows (X);
  sqr_dist = square_distance_matrix (X, V);

  ## Loop until the objective function is within tolerance or the maximum
  ## number of iterations has been reached.
  while (convergence_criterion > epsilon && ++iteration <= max_iterations)
    V_previous = V;
    Mu = fcm_update_membership_fcn (V, X, m, k, n, sqr_dist);
    Mu_m = Mu .^ m;
    V = fcm_update_cluster_centers (Mu_m, X, k);
    sqr_dist = gk_square_distance_matrix (X, V, Mu_m, cluster_volume);
    obj_fcn_history(iteration) = fcm_compute_objective_fcn (Mu_m, sqr_dist);
    if (display_intermediate_results)
      printf ("Iteration count = %d,  Objective fcn = %8.6f\n", ...
               iteration, obj_fcn_history(iteration));
    endif
    convergence_criterion = fcm_compute_convergence_criterion (V, V_previous);
  endwhile

  ## Remove extraneous entries from the tail of the objective function history.
  if (convergence_criterion <= epsilon)
    obj_fcn_history = obj_fcn_history(1 : iteration);
  endif

endfunction

##------------------------------------------------------------------------------
## Function: gk_square_distance_matrix
##------------------------------------------------------------------------------

function sqr_dist = gk_square_distance_matrix (X, V, Mu_m, cluster_volume)

  k = rows (V);
  n = rows (X);
  num_features = columns (X);
  sqr_dist = zeros (k, n);

  for i = 1 : k
    Vi = V(i, :);
    covariance_matrix = compute_covariance_matrix (X, V, Mu_m, i);

    for j = 1 : n
      Vi_to_Xj = X(j, :) - Vi;
      A = cluster_volume(i) * ...
          det (covariance_matrix) ^ (1.0 / num_features) * ...
          inv (covariance_matrix);
      sqr_dist(i, j) = sum (Vi_to_Xj .* (A * Vi_to_Xj')');

    endfor

  endfor

endfunction

##------------------------------------------------------------------------------
## Function: compute_covariance_matrix
##------------------------------------------------------------------------------

function covariance_matrix = compute_covariance_matrix (X, V, Mu_m, i)

  num_features = columns (V);
  n = rows (X);
  num = zeros (num_features);
  denom = 0.0;
  Vi = V(i, :);

  for j = 1 : n
    Vi_to_Xj = X(j, :) - Vi;
    num += Mu_m(i, j) * Vi_to_Xj' * Vi_to_Xj;
    denom += Mu_m(i, j);
  endfor

  covariance_matrix = num / denom;

endfunction

