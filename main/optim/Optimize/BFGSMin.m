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
 
#============================ BFGSMin.m =====================================
# Minimize a function of the form 
#
#	Value = f(args)
#
# or
#
#	ValueGradient = f(args)
#
# where 
#
#	"args" is a cell array, minimization is w.r.t. FIRST element
#	"Value" is the scalar value of f
#	"ValueGradient" = {value, gradient} is a cell array
#		containing the value and the gradient of f.
#
# That is, your function can either return a scalar value,
# or it can return the value and the gradient vector together
# in a cell array.
#
# Brief summary of syntax follows, for a more extensive example,
# that shows how to write objective functions, see the file ExampleBFGSMin.m
#
#
# Calling syntax:
#
#	[theta, obj_value, iters, convergence] = BFGSMin(func, args, control)
#
# 	NOTE: the last argument is optional
#
#
# Input arguments:  
#	func - (string) the function to minimize
#	args - arguments, in a cell array.
#	control - OPTIONAL 3x1 vector
#		* 1st elem. controls maximum iterations
#			scalar > 0 - max. iters
#			or -1 for infinity (default)
#		* 2nd elem. is verbosity control 
#			0 = no results printed (default)
#			1 = intermediate results
#			2 = only last iteration results
#		* 3rd elem. specifies convergence criterion
#			1 = function, gradient, and parameter change
#				are all tested (default)
#			0 = only function conv tested
#
# Outputs:
#	theta - the minimizer
# 	obj_value - the minimized funtion value
# 	iters - number of iterations used
# 	convergence (1 = success, 0 = failure)

function [theta, obj_value, iters, convergence] = BFGSMin(func, args, control, gradient_type)
	
	# Check number of args
	if (nargin > 3) error("\nBFGSMin: you have provided more than 3 arguments\n"); endif
	
	# Check types of required arguments
	if !ischar(func) error("\nBFGSMin: first argument must be a string that gives name of objective function\n"); endif
	if !iscell(args) error("\nBFGSMin: arguments to objective function must be in a cell array\n"); endif

	# Set defaults for optional args
		# default strong criterion
		criterion = 1; 
		# tolerances
		func_tol  = 10*sqrt(eps);
		param_tol = 1e-5;
		gradient_tol = 1e-4;  
		# max iters, and screen display
		max_iters = inf;
		convergence = -1; # if this doesn't change, it means that maxiters were exceeded
		verbosity = 0; 

	# Now use options that are user-provided
	# Control verbosity, max iterations, and arg wrt which we minimize (optional)
	if nargin > 2 
		if !isvector(control) error("\nBFGSMin: 3rd argument must be a vector\n"); endif	
		control = control(:);		
		if (rows(control) != 3)
			error("\nBFGSMin: 3rd argument must be a 3x1 vector\n");
		else
			max_iters = control(1,:);
			if max_iters == -1, max_iters = inf; endif
			verbosity = control(2,:);
			criterion = control(3,:);
		endif	
	endif	

	# initialize things
	theta = args{1};
  	thetain = theta;
  	H = eye (prod (sz = size (theta)));

	# Initial gradient and obj_value
	temp = feval(func, args);
	if isscalar(temp)
		numeric_gradient = 1; # remember for future iterations
		last_obj_value = temp; 
		g = NumGradient(func, args);
	else
		numeric_gradient = 0;
		last_obj_value = temp{1};
		g = temp{2};
	endif		
	
	g = g(:); # make sure it's a column vector
	if sum(isnan(g)) > 0
		warning("BFGSMin: Initial gradient could not be calculated: exiting");
		convergence = 2;
		break;
	endif

	# the main loop
	iters = 0;	 
 	while iters < max_iters  # successful termination checks are inside loop
    	iters += 1;
		theta = args{1};
		d = -H*g;
		# Regular step
		[stepsize, obj_value] = NewtonStep(func, d, args);
		# Supposing regular step fails ...
		if isnan(stepsize) # try steepest descent on first failure of linesearch
			d = -g;
			warning("BFGSMin: Stepsize failure in BFGS direction, trying steepest descent direction");
 			[stepsize, obj_value] = NewtonStep(func, d, args);
	
			if isnan(stepsize)
			  warning("BFGSMin: failure to find direction of improvement: exiting");
			  theta = thetain;
			  convergence = 2;
			  break;
			endif
		endif
      	p = stepsize*d;

		# check normal convergence: all 3 must be satisfied
		conv1 = abs(obj_value - last_obj_value)/max(1,abs(last_obj_value)) < func_tol;
		conv2 = (norm (p) / max (1,norm (theta(:)))) < param_tol;
		conv3 = (norm(g) <= gradient_tol);

		# Want intermediate results?
		if verbosity == 1
			printf("\nBFGSMin intermediate results: Iteration %d\n",iters);
			printf("Stepsize %8.7f\n", stepsize);
			printf("Objective function value %16.10f\n", last_obj_value);
			if numeric_gradient
				printf("Using numeric gradient\n");
			else
				printf("Using analytic gradient\n");	
			endif	
			printf("Function conv %d  Param conv %d  Gradient conv %d\n", conv1, conv2, conv3);	
			printf("  params  gradient  change\n");
	 		for j = 1:rows(theta)
				printf("%8.4f %8.4f %8.4f\n",theta(j,:),g(j,:),p(j,:));
			endfor		
			printf("\n");
		endif
	
		if criterion == 1
			if (conv1 && conv2 && conv3)
		  	convergence = 1;
	     	break;
    	endif
		elseif conv1
			convergence = 1;
			break;
		endif;
			
  	    last_obj_value = obj_value;	
		thetanew = theta + p;
		argsnew = args;
		args{1} = thetanew;
		argsnew{1} = thetanew;

		# get gradient at new parameter value
		if numeric_gradient
			g_new = NumGradient(func, args);
		else
			temp = feval(func, args);
			g_new = temp{2};
		endif		

 		g_new = g_new(:);

		# Update the quasi-Hessian
		# Note: if the new gradient fails and the Hessian is identity matrix
		# we will break out with failure, since we've already tried Hessian
		# reset.
		# Perform normal iteration if gradient succeeds
		if sum(isnan(g_new)) == 0
			q = g_new-g;
  	    	g = g_new;
			denominator = q'*p;
	  	  	if denominator < eps  # reset Hessian if necessary
			  	H = eye(rows(theta));
		  	else
		   	  	H += (1+(q'*H*q)/denominator) * (p*p')/denominator - (p*q'*H+H*q*p')/denominator;
  			endif

		# otherwise reset Hessian and try with last good gradient
		# if we already reset Hessian then we're out of luck
		elseif H == eye (prod (sz = size (theta))) 
			convergence = 2;
			theta = thetain;
			break;
		# Here's the Hessian re-set
		else	
			H = eye (prod (sz = size (theta)));
		endif
	
  endwhile
	# Want last iteration results?
	if verbosity == 2
		printf("\nBFGSMin final results: Iteration %d\n",iters);
		printf("Stepsize %8.7f\n", stepsize);
		printf("Objective function value %16.10f\n", last_obj_value);
		if numeric_gradient
			printf("Used numeric gradient\n");
		else
			printf("Used analytic gradient\n");	
		endif	
		printf("Function conv %d  Param conv %d  Gradient conv %d\n", conv1, conv2, conv3);	
		printf("  params  gradient  change\n");
		for j = 1:rows(theta)
			printf("%8.4f %8.4f %8.4f\n",theta(j,:),g(j,:),p(j,:));
		endfor		
		printf("\n");
	endif

endfunction
#============================ end BFGSMin =====================================
