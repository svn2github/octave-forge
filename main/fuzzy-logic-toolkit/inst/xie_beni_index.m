## Copyright (C) 2011-2012 L. Markowsky <lmarkov@users.sourceforge.net>
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
## @deftypefn {Function File} {@var{vxb} =} xie_beni_index (@var{input_data}, @var{cluster_centers}, @var{soft_partition})
##
## Return the Xie-Beni validity index for a given soft partition.
##
## The arguments to xie_beni_index are:
## @itemize @w
## @item
## @var{input_data} - a matrix of input data points; each row corresponds to one point
## @item
## @var{cluster_centers} - a matrix of cluster centers; each row corresponds to one point
## @item
## @var{soft_partition} - the membership degree of each input data point in each cluster
## @end itemize
##
## The return value is:
## @itemize @w
## @item
## @var{vxb} - the Xie-Beni validity index for the given partition
## @end itemize
##
## For more information about the @var{input_data}, @var{cluster_centers},
## and @var{soft_partition} matrices, please see the documentation for function
## fcm.
##
## @seealso{fcm, gustafson_kessel, partition_coeff, partition_entropy}
##
## @end deftypefn

## Author:        L. Markowsky
## Keywords:      fuzzy-logic-toolkit fuzzy xie beni cluster validity
## Directory:     fuzzy-logic-toolkit/inst/
## Filename:      xie_beni_index.m
## Last-Modified: 26 Aug 2012

function vxb = xie_beni_index (input_data, cluster_centers, ...
                               soft_partition)

  ## If xie_beni_index was called with an incorrect number of arguments,
  ## or the argument does not have the correct type, print an error
  ## message and halt.

  if (nargin != 3)
    puts ("Type 'help xie_beni_index' for more information.\n");
    error ("xie_beni_index requires 3 arguments\n");
  elseif (!is_real_matrix (input_data))
    puts ("Type 'help xie_beni_index' for more information.\n");
    error ("xie_beni_index's first argument must be matrix of reals\n");
  elseif (!(is_real_matrix (cluster_centers) &&
            (columns (cluster_centers) == columns (input_data))))
    puts ("Type 'help xie_beni_index' for more information.\n");
    puts ("xie_beni_index's second argument must be matrix of reals\n");
    puts ("with the same number of columns as the input_data\n");
    error ("invalid second argument to xie_beni_index\n");
  elseif (!(is_real_matrix (soft_partition) &&
            (min (min (soft_partition)) >= 0) &&
            (max (max (soft_partition)) <= 1)))
    puts ("Type 'help xie_beni_index' for more information.\n");
    puts ("xie_beni_index's third argument must be a matrix of\n");
    puts ("real numbers mu, with 0 <= mu <= 1\n");
    error ("invalid third argument to xie_beni_index\n");
  endif

  ## Compute and return the Xie-Beni index.

  vxb = xie_beni_private (input_data, cluster_centers, soft_partition);

endfunction

##----------------------------------------------------------------------
## Function: xie_beni_private
## Purpose:  Return the Xie-Beni index for the given soft partition.
## Note:     The following is an implementation of Equations 13.11,
##           13.12, and 13.13 in Fuzzy Logic: Intelligence, Control and
##           Information, by J. Yen and R. Langari, Prentice Hall, 1999,
##           page 384 (International Edition). 
##----------------------------------------------------------------------

function vxb = xie_beni_private (X, V, Mu)

  sqr_dist = square_distance_matrix (X, V);
  sum_sigma = sum (sum (Mu .* sqr_dist));
  n = rows (X);
  d_sqr_min = min_sqr_dist_between_centers (V);
  vxb = sum_sigma / (n * d_sqr_min);

endfunction

##----------------------------------------------------------------------
## Function: min_sqr_dist_between_centers
## Purpose:  Return the square of the minimum distance between
##           cluster centers.
##----------------------------------------------------------------------

function d_sqr_min = min_sqr_dist_between_centers (V)

  k = rows (V);
  d_sqr_matrix = NaN(k, k);

  for i = 1 : (k - 1)
    Vi = V(i, :);
    for j = (i + 1) : k
      Vi_to_Vj = V(j, :) - Vi;
      d_sqr_matrix(i, j) = sum (Vi_to_Vj .* Vi_to_Vj);
    endfor
  endfor

  d_sqr_min = min (min (d_sqr_matrix));

endfunction

##----------------------------------------------------------------------
## Xie-Beni Index Demo #1
##----------------------------------------------------------------------

%!demo
%! ## Use the Fuzzy C-Means and Gustafson-Kessel algorithms to classify
%! ## a small set of unlabeled data points and evaluate the quality
%! ## of the resulting clusters.
%!
%! ## Note: The input_data is taken from Chapter 13, Example 17 in
%! ##       Fuzzy Logic: Intelligence, Control and Information, by
%! ##       J. Yen and R. Langari, Prentice Hall, 1999, page 381
%! ##       (International Edition). 
%! 
%! input_data = [2 12; 4 9; 7 13; 11 5; 12 7; 14 4]
%! number_of_clusters = 2
%! 
%! ## Using fcm, classify the input data, print the cluster centers,
%! ## and calculate and print the partition coefficient.
%! [cluster_centers, soft_partition, obj_fcn_history] = ...
%!   fcm (input_data, number_of_clusters, [NaN NaN NaN 0]);
%! puts ("\nResults using the Fuzzy C-Means algorithm:\n\n");
%! cluster_centers
%! printf ("Xie-Beni index: %f\n", ...
%!        xie_beni_index (input_data, cluster_centers, soft_partition));
%! 
%! ## Using gustafson_kessel, classify the input data, print the cluster
%! ## centers, and calculate and print the partition coefficient.
%! [cluster_centers, soft_partition, obj_fcn_history] = ...
%!   gustafson_kessel (input_data, number_of_clusters, [1 1 1], ...
%!                     [NaN NaN NaN 0]);
%! puts ("\nResults using the Gustafson-Kessel algorithm:\n\n");
%! cluster_centers
%! printf ("Xie-Beni index: %f\n\n", ...
%!        xie_beni_index (input_data, cluster_centers, soft_partition));

##----------------------------------------------------------------------
## Xie-Beni Index Demo #2
##----------------------------------------------------------------------

%!demo
%! ## Use the Fuzzy C-Means and Gustafson-Kessel algorithms to classify
%! ## three-dimensional unlabeled data points and evaluate the quality
%! ## of the resulting clusters.
%!
%! ## Note: The input_data was selected to form three areas of
%! ##       different shapes.
%!
%! input_data = [1 11 5; 1 12 6; 1 13 5; 2 11 7; 2 12 6; 2 13 7; 3 11 6;
%!               3 12 5; 3 13 7;  1 1 10; 1 3 9; 2 2 11; 3 1 9; 3 3 10;
%!               3 5 11; 4 4 9; 4 6 8; 5 5 8; 5 7 9; 6 6 10; 9 10 12;
%!               9 12 13; 9 13 14; 10 9 13; 10 13 12; 11 10 14;
%!               11 12 13; 12 6 12; 12 7 15; 12 9 15; 14 6 14; 14 8 13]
%! number_of_clusters = 3
%!
%! ## Using fcm, classify the input data, print the cluster centers,
%! ## and calculate and print the partition coefficient.
%! [cluster_centers, soft_partition, obj_fcn_history] = ...
%!   fcm (input_data, number_of_clusters, [NaN NaN NaN 0]);
%! puts ("\nResults using the Fuzzy C-Means algorithm:\n\n");
%! cluster_centers
%! printf ("Xie-Beni index: %f\n", ...
%!        xie_beni_index (input_data, cluster_centers, soft_partition));
%! 
%! ## Using gustafson_kessel, classify the input data, print the cluster
%! ## centers, and calculate and print the partition coefficient.
%! [cluster_centers, soft_partition, obj_fcn_history] = ...
%!   gustafson_kessel (input_data, number_of_clusters, [1 1 1], ...
%!                     [NaN NaN NaN 0]);
%! puts ("\nResults using the Gustafson-Kessel algorithm:\n\n");
%! cluster_centers
%! printf ("Xie-Beni index: %f\n\n", ...
%!        xie_beni_index (input_data, cluster_centers, soft_partition));
