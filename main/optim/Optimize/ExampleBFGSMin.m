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
 
# This shows how to call BFGSMin.m

# This minimizes the Rosenbrock function, with minimizer translated
# to "location". The "location" translation illustrates how
# additional arguments (those w.r.t. which we are NOT minimizing)
# may be used in definition of the objective function.
# The argument w.r.t. which we minimize must be the FIRST argument
# in the cell array that is the argument to BFGSMin.

# Function value and gradient vector of the rosenbrock function
# The minimizer is at the vector (1,1,..,1),
# and the minimized value is 0.
1;

function [obj_value, gradient] = rosenbrock(x);
	dimension = length(x);
	obj_value = sum(100*(x(2:dimension)-x(1:dimension-1).^2).^2 + (1-x(1:dimension-1)).^2);
	if nargout > 1
	  gradient = zeros(dimension, 1);
	  gradient(1:dimension-1) = - 400*x(1:dimension-1).*(x(2:dimension)-x(1:dimension-1).^2) - 2*(1-x(1:dimension-1));
	  gradient(2:dimension) = gradient(2:dimension) + 200*(x(2:dimension)-x(1:dimension-1).^2);
	endif
endfunction

# The example objective functions

# example obj. fn. - this shows how to use analytic gradient
function output = objective(args)
	theta = args{1};
	location = args{2};
	x = theta - location + ones(rows(theta),1); # move minimizer to "location"
	[obj_value, grad] = rosenbrock(x);	
	output = {obj_value, grad};
endfunction 

# example obj. fn. - this shows how to use numerical grafient
function obj_value = objective2(args)
	theta = args{1};
	location = args{2};
	x = theta - location + ones(rows(theta),1); # move minimizer to "location"
	obj_value = rosenbrock(x);	
endfunction 



t = cputime;

# control options and initial value
control = [1000;2;1];  # max 1000 iterations; only report results of last iteration; strong convergence required
dim = 10; # dimension of Rosenbrock function
theta = zeros(dim+1,1);  # starting values
location = 5*(0:dim)/dim;
location = location';

args = {theta, location}; # BFGSMin requires arguments to be in a cell array

# do the minimization
printf("If this was successful, the minimizer should be\n");
printf("a vector of even steps from 0 to 5\n\n");

printf("ANALYTIC GRADIENT\n");
[theta, obj_value, iterations, convergence] = BFGSMin("objective", args, control);
t = cputime() - t;
printf("Elapsed time = %f\n",t);

printf("NUMERIC GRADIENT\n");
# without last arg to BFGSMin(), default is numeric
[theta, obj_value, iterations, convergence] = BFGSMin("objective2", args, control); 
t = cputime - t;
fprintf("Elapsed time = %f\n",t);
