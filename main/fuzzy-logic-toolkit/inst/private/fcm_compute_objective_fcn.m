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
## @deftypefn {Function File} {@var{obj_fcn} =} fcm_compute_objective_fcn (@var{Mu_m}, @var{sqr_dist})
##
## Compute the objective function for the current iteration.
##
## @seealso{fcm, fcm_init_prototype, fcm_update_membership_fcn, fcm_update_cluster_centers, fcm_compute_convergence_criterion}
##
## @end deftypefn

## Author:        L. Markowsky
## Keywords:      fuzzy-logic-toolkit fuzzy partition clustering fcm private
## Directory:     fuzzy-logic-toolkit/inst/private/
## Filename:      fcm_compute_objective_fcn.m
## Last-Modified: 7 July 2012

##------------------------------------------------------------------------------
## Note:     This function is an implementation of Equation 13.3 in
##           Fuzzy Logic: Intelligence, Control and Information, by J. Yen and
##           R. Langari, Prentice Hall, 1999, page 379 (International Edition). 
##------------------------------------------------------------------------------

function obj_fcn = fcm_compute_objective_fcn (Mu_m, sqr_dist)

  obj_fcn = sum (sum (Mu_m .* sqr_dist));

endfunction
