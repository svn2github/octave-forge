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

## usage: [obj_value, score] = mle_obj(theta, data, model, modelargs)
##
## Returns the average log-likelihood for a specified model
## This is for internal use by mle_estimate

# this takes a general model and calculates average log likelihood
function [obj_value, score] = mle_obj(theta, data, model, modelargs)
	[obj_value, score] = feval(model, theta, data, modelargs);
	obj_value = - mean(obj_value);

	# let's bullet-proof this in case the model goes nuts
	if (((abs(obj_value) == Inf)) || (isnan(obj_value)))
		obj_value = realmax;
	endif

	if isnumeric(score) score = - mean(score)'; endif
endfunction	
