# Copyright (C) 2003  Michael Creel michael.creel@uab.es
# under the terms of the GNU General Public License.
# The GPL license is in the file COPYING
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
#============================= NumGradient =============================
# Central difference gradient of a function of the form
# f(args), where args is a cell array.
#
# The gradient is respect to the FIRST element of args.
#
# * Allows diff. of vector-valued function
# * Uses systematic finite difference
#
# See ExampleNumGradient.m

function derivative = NumGradient(f, args)

	if !iscell(args) args = {args}; endif
	parameter = args{1};

    k = rows(parameter);

	obj_value = feval(f, args);
	if iscell(obj_value) obj_value = obj_value{1}; endif
	
	n = rows(obj_value);
    derivative = zeros(n, k);

    for i = 1:k    # get 1st derivative by central difference 
        p = parameter(i);
        delta = FiniteDifference(p,1);

        # right side
		parameter(i) = d = p + delta;
		delta_right = d - p;
		args{1} = parameter;
   	  	obj_right = feval(f, args);
		if iscell(obj_right) obj_right = obj_right{1}; endif
	
	  	# left size
		parameter(i) = d = p - delta;
		delta_left = p - d;
		args{1} = parameter;
	  	obj_left = feval(f, args);
		if iscell(obj_left) obj_left = obj_left{1}; endif
	
		parameter(i) = p;  # restore original parameter 

        derivative(:,i) = (obj_right - obj_left) / (delta_right + delta_left);  # take central difference
	endfor        
endfunction
#=========================== END NumGradient ===========================
