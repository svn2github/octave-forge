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
 
# Shows how to call numeric derivatives, and verifies with analytic

# The Rosenbrock function - used to define objective functions
# Function value and gradient vector of the rosenbrock function
# The minimizer is x = [1; 1;...;1], and the minimized value is 0.
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
function [obj_value, grad] = objective(args)
	theta = args{1};
	[obj_value, grad] = rosenbrock(theta);	
endfunction 

# example obj. fn. - this shows how to use numerical grafient
function [obj_value, grad] = objective2(args)
	theta = args{1};
	obj_value = rosenbrock(theta);	
	grad = "na";
endfunction 

# Here's how to get the numeric gradient
args = {randn(10,1)};
ngradient = NumGradient("objective", args);

# Analytic gradient, to verify
[o, agradient] = objective(args);
ngradient = ngradient';
printf("\nCheck NumGradient\n");
printf("\nDerivatives of the Rosenbrock function, random start values\n\n");
printf("    Numeric       Analytic      Difference\n");
results = [ngradient agradient ngradient - agradient];
disp(results);
