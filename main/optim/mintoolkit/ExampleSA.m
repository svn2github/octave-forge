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
# This shows how to call samin

# example obj. fn.: standard case where 1st arg is to be minimized over
function [obj_value, junk] = objective(theta, location)
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
dim = 10; # dimension of Rosenbrock function
theta = zeros(dim+1,1);  # starting values
location = 10*(0:dim)/dim;
location = location';

# SA controls
reduction_factor = 0.5;
ns = 20;
nt = 5;
neps = 5;
eps = 1e-3;
maxevals = 1e10;
verbosity = 1;
ub = 20*ones(rows(theta),1);
lb = -ub;
minarg = 1;
control = { lb, ub, nt, ns, neps, \
	 reduction_factor, maxevals, eps, verbosity, 1};
# Check bfgsmin, illustrating variations
t=cputime();
[theta, obj_value] = samin("objective", {theta, location}, control);
t = cputime() - t;
printf("Elapsed time = %f\n\n\n",t);

