# Copyright (C) 2004   Michael Creel   <michael.creel@uab.es>
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

1;
# This shows how to call lbfgsmin.m

# example obj. fn
function obj_value = objective1(x, y)
	obj_value = log(1 + x'*x) + log(1 + y'*y);
endfunction 

# example obj. fn.: with gradient
function [obj_value, gradient] = objective2(x, y)
	obj_value = log(1 + x'*x) + log(1 + y'*y);
	gradient = (1/(1 + x'*x))*2*x;
endfunction 

# Check lbfgsmin, illustrating variations

printf("EXAMPLE 1: Numeric gradient");
x0 = ones(2,1);
y0 = 2*ones(2,1);
control = {50,2,1,1,5};  # maxiters, verbosity, conv. reg., arg_to_min
[theta, obj_value, convergence] = lbfgsmin("objective1", {x0, y0}, control);
printf("\n");

printf("EXAMPLE 2: Analytic gradient");
control = {50,2,1,1,5};  # maxiters, verbosity, conv. reg., arg_to_min
[theta, obj_value, convergence] = lbfgsmin("objective2", {x0, y0}, control);
printf("\n");


printf("EXAMPLE 3: Numeric gradient, non-default tolerances\n");
control = {10,2,1,1,5};  # maxiters, verbosity, conv. reg., arg_to_min
tols = {1e-12, 1e-8, 1e-8};
[theta, obj_value, convergence] = lbfgsmin("objective1", {x0, y0}, control, tols);
printf("\n");

printf("EXAMPLE 4: Funny case - min wrt 2nd arg.");
control = {50,2,1,2,5};  # maxiters, verbosity, conv. reg., arg_to_min
[theta, obj_value, convergence] = lbfgsmin("objective1", {x0, y0}, control);


