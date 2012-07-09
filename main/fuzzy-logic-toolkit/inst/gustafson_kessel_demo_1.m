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
## @deftypefn {Script File} {} gustafson_kessel_demo_1
## Use the Gustafson-Kessel algorithm to classify unlabeled data points and
## evaluate the quality of the resulting clusters.
##
## The demo:
## @itemize @minus
## @item
## classifies a small set of unlabeled data points using the Gustafson-Kessel
## algorithm into two fuzzy clusters
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
## @seealso{gustafson_kessel, gustafson_kessel_demo_2, partition_coeff, partition_entropy, xie_beni_index, fcm, fcm_demo_1, fcm_demo_2}
##
## @end deftypefn

## Author:        L. Markowsky
## Keywords:      fuzzy-logic-toolkit fuzzy partition clustering gustafson_kessel demo
## Directory:     fuzzy-logic-toolkit/inst/
## Filename:      gustafson_kessel_demo_1.m
## Last-Modified: 8 July 2012

##------------------------------------------------------------------------------
## Note: The input_data is taken from Chapter 13, Example 17 in
##       Fuzzy Logic: Intelligence, Control and Information, by J. Yen and
##       R. Langari, Prentice Hall, 1999, page 381 (International Edition). 
##------------------------------------------------------------------------------

## Use gustafson_kessel to classify the data in matrix x.
input_data = [2 12; 4 9; 7 13; 11 5; 12 7; 14 4]
number_of_clusters = 2
[cluster_centers, soft_partition, obj_fcn_history] = ...
  gustafson_kessel (input_data, number_of_clusters)

## Calculate and print the three validity measures.
printf ("Partition Coefficient: %f\n", partition_coeff (soft_partition));
printf ("Partition Entropy (with a = 2): %f\n", partition_entropy (soft_partition, 2));
printf ("Xie-Beni Index: %f\n\n", xie_beni_index (input_data, cluster_centers, soft_partition));
 
## Plot the data points as small blue x's.
figure ('NumberTitle', 'off', 'Name', 'Gustafson-Kessel Demo 1');
for i = 1 : rows (input_data)
  plot (input_data(i, 1), input_data(i, 2), 'LineWidth', 2, 'marker', 'x', ...
        'color', 'b');
  hold on;
endfor

## Plot the cluster centers as larger red *'s.
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
hold
