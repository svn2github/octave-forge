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
## @deftypefn {Script File} {} gustafson_kessel_demo_2
## Use the Gustafson-Kessel algorithm to classify unlabeled data points and
## evaluate the quality of the resulting clusters.
##
## The demo:
## @itemize @minus
## @item
## classifies three-dimensional unlabeled data points using the
## Gustafson-Kessel algorithm into three fuzzy clusters
## @item
## calculates and prints (on standard output) three validity measures:
## the partition coefficient, the partition entropy, and the Xie-Beni
## validity index
## @item
## plots the input points together with the cluster centers
## @end itemize
##
## For a description of the data structures used in the script, see the
## documentation for gustafson_kessel.
##
## @seealso{gustafson_kessel, gustafson_kessel_demo_1, partition_coeff, partition_entropy, xie_beni_index, fcm, fcm_demo_1, fcm_demo_2}
##
## @end deftypefn

## Author:        L. Markowsky
## Keywords:      fuzzy-logic-toolkit fuzzy partition clustering fcm demo
## Directory:     fuzzy-logic-toolkit/inst/
## Filename:      gustafson_kessel_demo_2.m
## Last-Modified: 8 July 2012

##------------------------------------------------------------------------------
## Note: The input_data was selected to form three areas of different shapes.
##------------------------------------------------------------------------------

## Use gustafson_kessel to classify the data in matrix x.
input_data = [1 11 5; 1 12 6; 1 13 5; 2 11 7; 2 12 6; 2 13 7; 3 11 6; 3 12 5;
              3 13 7;  1 1 10; 1 3 9; 2 2 11; 3 1 9; 3 3 10; 3 5 11; 4 4 9;
              4 6 8; 5 5 8; 5 7 9; 6 6 10; 9 10 12; 9 12 13; 9 13 14; 10 9 13;
              10 13 12; 11 10 14; 11 12 13; 12 6 12; 12 7 15; 12 9 15; 14 6 14;
              14 8 13]
number_of_clusters = 3
[cluster_centers, soft_partition, obj_fcn_history] = ...
  gustafson_kessel (input_data, number_of_clusters, [1 1 1], [NaN NaN NaN 0])

## Calculate and print the three validity measures.
printf ("Partition Coefficient: %f\n", partition_coeff (soft_partition));
printf ("Partition Entropy (with a = 2): %f\n", partition_entropy (soft_partition, 2));
printf ("Xie-Beni Index: %f\n\n", xie_beni_index (input_data, cluster_centers, soft_partition));
 
## Plot the data points in two dimensions (using features 1 and 2)
## as small blue x's.
figure ('NumberTitle', 'off', 'Name', 'Gustafson-Kessel Demo 2');
for i = 1 : rows (input_data)
  plot (input_data(i, 1), input_data(i, 2), 'LineWidth', 2, 'marker', 'x', ...
        'color', 'b');
  hold on;
endfor

## Plot the cluster centers in two dimensions (using features 1 and 2)
## as larger red *'s.
for i = 1 : number_of_clusters
  plot (cluster_centers(i, 1), cluster_centers(i, 2), 'LineWidth', 4, ...
        'marker', '*', 'color', 'r');
  hold on;
endfor

## Make the figure look a little better:
##   -- scale and label the axes
##   -- show gridlines
xlim ([0 15]);
ylim ([0 15]);
xlabel ('Feature 1');
ylabel ('Feature 2');
grid
 
## Plot the data points in two dimensions (using features 1 and 3)
## as small blue x's.
figure ('NumberTitle', 'off', 'Name', 'Gustafson-Kessel Demo 2');
for i = 1 : rows (input_data)
  plot (input_data(i, 1), input_data(i, 3), 'LineWidth', 2, 'marker', 'x', ...
        'color', 'b');
  hold on;
endfor

## Plot the cluster centers in two dimensions (using features 1 and 3)
## as larger red *'s.
for i = 1 : number_of_clusters
  plot (cluster_centers(i, 1), cluster_centers(i, 3), 'LineWidth', 4, ...
        'marker', '*', 'color', 'r');
  hold on;
endfor

## Make the figure look a little better:
##   -- scale and label the axes
##   -- show gridlines
xlim ([0 15]);
ylim ([0 15]);
xlabel ('Feature 1');
ylabel ('Feature 3');
grid
hold
