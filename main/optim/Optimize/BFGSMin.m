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
# Minimize a function of the form [value, gradient] = f(args),
# where args is a cell array.
#
# Minimization is with respect to the FIRST element of args.
# If the gradient is not available, the function should return "na" or some other
# string.
#
# * numeric or analytic gradient
# * default strict convergence criteria
# * can control verbosity and convergence criteria
# * attempts to be robust
#
# Brief summary of syntax follows, for a more 
# extensive example, see the file ExampleBFGSMin.m
#
# calling syntax: 
#
#	[theta, obj_value, iters, convergence] = BFGSMin(func, args, control)
#
# or
#
# 	[theta, obj_value, iters, convergence] = BFGSMin(func, args)
#
# input arguments:  
#					func - (string) the function to minimize
#					args - arguments, in a cell array.
#					control - optional 3x1 vector
#							* 1st elem is max iters (scalar > 0, or -1 for infinity)
#							* 2nd elem is verbosity control 
#							  (0 = no results printed)
#							  (1 = intermediate results)
#							  (2 = only last iteration results)
#							* 3rd arg specifies convergence criterion
#								1 (default) =  function, gradient, and parameter change
#											are all tested
#								0 = only function conv tested
#
# Outputs: 			theta - the minimizer
# 					obj_value - the minimized funtion value
# 					iters - number of iterations used
# 					convergence (1 = success, 0 = failure)


function [theta, obj_value, iters, convergence] = BFGSMin(func, args, control)
	
	# convert to cell array if, needed
	if !iscell(args) args = {args}; endif
	theta = args{1};

	# Set defaults
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


  # Control verbosity, max iterations, and arg wrt which we minimize (optional)
	if nargin == 3 
		max_iters = control(1,:);
		if max_iters == -1, max_iters = inf; endif
		verbosity = control(2,:);
		criterion = control(3,:);
	endif
 
	# initialize things
  	thetain = theta;
  	H = eye (prod (sz = size (theta)));

	# Initial gradient and obj_value
	[last_obj_value, g] = feval(func, args); 
	
	# use numeric derivatives if analytic aren't given
	numeric_gradient = 0;
	if isstr(g)
		numeric_gradient = 1; # don't repeat this test in future
		g = NumGradient(func, args);
	endif 

	g = g(:); # make sure it's a column vector
	if sum(isnan(g)) > 0
		warning("BFGS: Initial gradient could not be calculated: exiting");
		convergence = 2;
		break;
	endif

	iters = 0;	 

 	while iters < max_iters  # succesful termination checks are inside loop
    	iters += 1;
		theta = args{1};
		d = -H*g;
		# Regular step
		[stepsize, obj_value] = NewtonStep(func, d, args);
		# Supposing regular step fails ...
		if isnan(stepsize) # try steepest descent on first failure of linesearch
			d = -g;
			warning("BFGS: Stepsize failure in BFGS direction, trying steepest descent direction");
 			[stepsize, obj_value] = NewtonStep(func, d, args);
	
			if isnan(stepsize)
			  warning("BFGS: failure to find direction of improvement: exiting");
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
			printf("\nIteration %d\n",iters);
			printf("Stepsize %8.7f\n", stepsize);
			printf("Objective function value %16.10f\n", last_obj_value);
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
			g_new = NumGradient(func, argsnew);
		else
			[dummy, g_new] = feval(func, argsnew); 
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
		printf("\nIteration %d\n",iters);
		printf("Stepsize %8.7f\n", stepsize);
		printf("Objective function value %16.10f\n", last_obj_value);
		printf("Function conv %d  Param conv %d  Gradient conv %d\n", conv1, conv2, conv3);	
		printf("  params  gradient  change\n");
		for j = 1:rows(theta)
			printf("%8.4f %8.4f %8.4f\n",theta(j,:),g(j,:),p(j,:));
		endfor		
		printf("\n");
	endif

endfunction
#============================ end BFGSMin =====================================
