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
# This shows how to call bfgsmin.m, newtonmin, numgradient, and numhessian

# example obj. fn.: standard case where 1st arg is to be minimized over
function [obj_value, junk] = objective(theta, location)
	x = theta - location + ones(rows(theta),1); # move minimizer to "location"
	obj_value = rosenbrock(x);
	junk = 1; # just an example, nothing important here	
endfunction 

# example obj. fn.: funny case where 2nd arg is to be minimized over
function [obj_value, junk] = objective2(location, theta)
	x = theta - location + ones(rows(theta),1); # move minimizer to "location"
	obj_value = rosenbrock(x);
	junk = 1; # just an example, nothing important here	
endfunction 


# Rosenbrock function - used by the above
# Function value and gradient vector of the rosenbrock function
# The minimizer is at the vector (1,1,..,1),
# and the minimized value is 0.
function [obj_value, gradient] = rosenbrock(x);
	dimension = length(x);
	obj_value = sum(100*(x(2:dimension)-x(1:dimension-1).^2).^2 + (1-x(1:dimension-1)).^2);
	if nargout > 1
	  gradient = zeros(dimension, 1);
	  gradient(1:dimension-1) = - 400*x(1:dimension-1).*(x(2:dimension)-x(1:dimension-1).^2) - 2*(1-x(1:dimension-1));
	  gradient(2:dimension) = gradient(2:dimension) + 200*(x(2:dimension)-x(1:dimension-1).^2);
	endif
endfunction



# initial values
dim = 5; # dimension of Rosenbrock function
theta0 = zeros(dim+1,1);  # starting values
location = 10*(0:dim)/dim;
location = location';


printf("If this was successful, the minimizer should be\n");
printf("a vector of even steps from 0 to 10\n\n");


# Check bfgsmin, illustrating variations

printf("bfgsmin: Standard case - min wrt 1st arg.\n");
t=cputime();
control = [200;2;1;1];  # maxiters, verbosity, conv. reg., arg_to_min
[theta, obj_value, iterations, convergence] = bfgsmin("objective", {theta0, location}, control);
t = cputime() - t;
printf("Elapsed time = %f\n\n\n",t);

printf("bfgsmin: Funny case - min wrt 2nd arg.\n");
t=cputime();
control = [200;2;1;2];  # maxiters, verbosity, conv. reg., arg_to_min
[theta, obj_value, iterations, convergence] = bfgsmin("objective2", {location, theta0}, control);
t = cputime() - t;
printf("Elapsed time = %f\n\n\n",t);

printf("newtonmin: Standard case - min wrt 1st arg.\n");
t=cputime();
control = [200;2;1;1];  # maxiters, verbosity, conv. reg., arg_to_min
[theta, obj_value, iterations, convergence] = newtonmin("objective", {theta0, location}, control);
t = cputime() - t;
printf("Elapsed time = %f\n\n\n",t);


# Illustrate numgradient
ng = numgradient("rosenbrock", {theta-location});
[junk, ag] = rosenbrock(theta-location);
printf("Checking NumGradient\n");
printf("Numeric   Analytic\n");
for i=1:dim+1
	printf("%f  %f\n", ng(i), ag(i));
endfor


# Illustrate NumHessian
h = numhessian("rosenbrock", {theta0});
h = h(1:4,1:4);
printf("\n\n\nNumeric Hessian, leading 4x4 block\n");
disp(h);
