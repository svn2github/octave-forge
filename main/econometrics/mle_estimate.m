## Copyright (C) 2003,2004,2005  Michael Creel michael.creel@uab.es
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
## along with this program; if not, write to the Free Software
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

## usage: [theta, obj_value, convergence] = 
##   mle_estimate(theta, data, model, modelargs, control)
##
## Please see mle_example for information on how to use this
 
## call the minimizing routine
function [theta, obj_value, convergence] = mle_estimate(theta, data, model, modelargs, control)
  if nargin == 4
    [theta, obj_value, convergence] = bfgsmin("mle_obj", {theta, data, model, modelargs});
  else
    [theta, obj_value, convergence] = bfgsmin("mle_obj", {theta, data, model, modelargs}, control);
  endif
	obj_value = - obj_value; # recover from minimization rather than maximization
endfunction	
