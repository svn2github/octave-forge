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
# This shows how to call bfgsmin.m

# You can minimize w.r.t. any argument, but the argument minimization is done over
# must be a column vector.

# It is possible to supply analytic derivatives. If the second return of the objective
# function is a column vector the same size as the minimization argument, it is assumed
# to be the gradient vector.

page_screen_output = 0;

# example obj. fn
function obj_value = objective1(x, y)
	z = y - ones(size(y));
	obj_value = log(1 + x'*x) + log(1 + z'*z);
endfunction 

# example obj. fn.: with gradient w.r.t. x
function [obj_value, gradient] = objective2(x, y)
	obj_value = (1 + x'*x) + (1 + y'*y);
	gradient = 2*x; #(1/(1 + x'*x))*2*x;
endfunction 

# Check bfgsmin, illustrating variations

printf("\nEXAMPLE 1: Numeric gradient\n");
x0 = ones(2,1);
y0 = 2*ones(2,1);
control = {10,2,1,1};  # maxiters, verbosity, conv. reg., arg_to_min
[theta, obj_value, convergence] = bfgsmin("objective1", {x0, y0}, control);
printf("\n");

printf("\nEXAMPLE 2: Analytic gradient\n");
control = {50,2,1,1};  # maxiters, verbosity, conv. reg., arg_to_min
[theta, obj_value, convergence] = bfgsmin("objective2", {x0, y0}, control);
printf("\n");


printf("\nEXAMPLE 3: Numeric gradient, non-default tolerances\n");
printf("Note how the gradient tolerance can't be achieved with\n");
printf("numeric differentiation\n");
control = {100,2,1,1};  # maxiters, verbosity, conv. reg., arg_to_min
tols = {1e-12, 1e-8, 1e-8};
[theta, obj_value, convergence] = bfgsmin("objective1", {x0, y0}, control, tols);
printf("\n");

printf("\nEXAMPLE 4: Funny case - min wrt 2nd arg.\n");
control = {50,2,1,2};  # maxiters, verbosity, conv. reg., arg_to_min
[theta, obj_value, convergence] = bfgsmin("objective1", {x0, y0}, control);


printf("\nEXAMPLE 5: Limited memory BFGS, Numeric gradient\n");
x0 = ones(2,1);
y0 = 2*ones(2,1);
control = {10,2,1,1, 3};  # maxiters, verbosity, conv. reg., arg_to_min
[theta, obj_value, convergence] = bfgsmin("objective1", {x0, y0}, control);
printf("\n");


printf("\nEXAMPLE 6: Limited memory BFGS, Analytic gradient\n");
control = {50,2,1,1,3};  # maxiters, verbosity, conv. reg., arg_to_min
[theta, obj_value, convergence] = bfgsmin("objective2", {x0, y0}, control);
printf("\n");







