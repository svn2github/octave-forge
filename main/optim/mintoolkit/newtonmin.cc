// Copyright (C) 2004   Michael Creel   <michael.creel@uab.es>
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 2 of the License, or
//  (at your option) any later version.
// 
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
// 
//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software
//  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 

// newtonmin
// 
// newton-raphson minimization of function of form 
//
// [value, return_2,..., return_m] = f(arg_1, arg_2,..., arg_n)
// 
// By default, minimization is w.r.t. arg_1, but this can be overridden

#include <oct.h>
#include <octave/parse.h>
#include <octave/Cell.h>
#include <octave/lo-mappers.h>

// define argument checks
static bool
any_bad_argument(const octave_value_list& args)
{
	if (!args(0).is_string())
    {
        error("newtonmin: first argument must be string holding objective function name");
        return true;
    }
	if (!args(1).is_cell())
    {
        error("newtonmin: second argument must cell array of function arguments");
        return true;
    }
 	if (args.length() == 3)
	{
		if (!args(2).is_real_matrix() || (!(args(2).length() == 4)))
    	{
        	error("newtonmin: 3rd argument, if supplied,  must a 4x1 vector of control options");
	        return true;
    	}
	}	
    return false;
}


DEFUN_DLD(newtonmin, args, ,
 " newton minimization of a function.\n\
\n\
* first argument is function name (string)\n\
* second is a cell array that holds all arguments of the function,\n\
* third argument is a optional 4x1 control vector\n\
	* elem 1: maximum iterations  (-1 = infinity (default))\n\
	* elem 2: verbosity\n\
		- 0 = no screen output (default)\n\
		- 1 = summary every iteration\n\
		- 2 = only last iteration summary\n\
	* elem 3: convergence criterion\n\
		 - 1 = strict (function, gradient and param change) (default)\n\
		 - 2 = weak - only function convergence required\n\
	* elem 4: arg with respect to which minimization is done\n\
	(default = first)\n\
\n\
Example:\n\
function a = f(x,y)\n\
	a = x'*x + y'*y;\n\
endfunction\n\
\n\
In this example, x is optimized since it's the first\n\
element of the cell array, y is a fixed constant = 1\n\
\n\
newtonmin(\"f\", {ones(2,1), 1}, [10,2,1,1])\n\
\n\
newtonmin final results: Iteration 1\n\
Stepsize 0.0000000\n\
Objective function value     1.0000000000\n\
Function conv 1  Param conv 1  Gradient conv 1\n\
  params  gradient  change\n\
  0.0000   0.0000   0.0000\n\
  0.0000   0.0000   0.0000\n\
\n\
ans =\n\
\n\
   6.1497e-12\n\
   6.1497e-12\n\
")
{
	int nargin = args.length();
	if ((nargin < 2) || (nargin > 3))
    {
      	error("newtonmin: you must supply 2 or 3 arguments");
	    return octave_value_list();
    }

    // check the arguments
	if (any_bad_argument(args)) return octave_value_list();


	std::string f (args(0).string_value());
	Cell f_args (args(1).cell_value());

	octave_value_list step_args(4,1);  // for stepsize: {f, f_args, direction, minarg}
	octave_value_list g_args(3,1); // for numgradient {f, f_args, minarg}
	octave_value_list c_args(2,1); // for cellevall {f, f_args}  
	
	step_args(0) = f; 
	step_args(1) = f_args;

	g_args(0) = f;
	g_args(1) = f_args;
	
	c_args(0) = f;
	c_args(1) = f_args;
	
	octave_value_list f_return; // holder for feval returns

	int criterion, max_iters, convergence, verbosity, minarg, iter;
	int gradient_failed, i, j, k, conv1, conv2, conv3;

	double func_tol, param_tol, gradient_tol, stepsize, obj_value;
	double last_obj_value, denominator, test, tempscalar;
	Matrix control, thetain, thetanew, H, g, d, g_new, p, q, temp, H1, H2;
	
	// tolerances
	func_tol  = 10*sqrt(2.22e-16);
	param_tol = 1e-6;
	gradient_tol = 1e-5;  

	// Default values for controls
	max_iters = INT_MAX; // no limit on iterations
	verbosity = 0; // by default don't report results to screen
	criterion = 1; // strong convergence required
	minarg = 1; // by default, first arg is one over which we minimize
 
 	// use provided controls, if applicable
	if (args.length() == 3)
	{
		control = args(2).matrix_value();
		max_iters = (int) control(0);
		if (max_iters == -1) max_iters = INT_MAX;
		verbosity = (int) control(1);
		criterion = (int) control(2);
		minarg = (int) control(3);
	}	

	step_args(3) = minarg;
	g_args(2) = minarg;
	
 	Matrix theta  = f_args(minarg - 1).matrix_value();

	k = theta.rows();
	
	// initialize things
	convergence = -1; // if this doesn't change, it means that maxiters were exceeded
 	thetain = theta;
	H = identity_matrix(k,k);

	// Initial obj_value
	f_return = feval("celleval", c_args); 
	last_obj_value = f_return(0).double_value();

	// initial gradient
	f_return = feval("numgradient", g_args);
	g = f_return(0).matrix_value();
	g = g.transpose();

	// check that gradient is ok
	gradient_failed = 0;  // test = 1 means gradient failed
	for (i=0; i<k;i++)
	{
		gradient_failed = gradient_failed + xisnan(g(i));
	}
	if (gradient_failed)
	{
		error("newtonmin: Initial gradient could not be calculated: exiting");
		convergence = 2;
	}

	// MAIN LOOP STARTS HERE
 	for (iter = 0; iter < max_iters; iter++)
	{
 		d = -H*g;

		// Regular step
		step_args(2) = d;
		f_args(minarg - 1) = theta;
		step_args(1) = f_args;
		f_return = feval("newtonstep", step_args);
		stepsize = f_return(0).double_value();
		obj_value = f_return(1).double_value();
		
		// Steepest descent if regular step fails
		if (xisnan(stepsize)) 
		{
			d = -g; // try steepest descent
			step_args(2) = d;
			f_return = feval("newtonstep", step_args);
			stepsize = f_return(0).double_value();
			obj_value = f_return(1).double_value();

			warning("newtonmin: Stepsize failure in newton direction, trying steepest descent direction");
			// if that didn't work, were out of luck
			if (xisnan(stepsize))
			{
				warning("newtonmin: unable to find direction of improvement: exiting");
				theta = thetain;
				convergence = 2;
				break;
			}
 		}
      	p = stepsize*d;

 		// check normal convergence: all 3 must be satisfied
		// function convergence
		if (fabs(last_obj_value) > 1.0)
		{
 			conv1 = (fabs(obj_value - last_obj_value)/fabs(last_obj_value)) < func_tol;
		}
		else
		{
			conv1 = fabs(obj_value - last_obj_value) < func_tol;
		}	
		// parameter change convergence
		temp = theta.transpose() * theta;
		test = sqrt(temp(0,0));
		if (test > 1)
		{
			temp = p.transpose() * p;
			conv2 = (temp(0,0) / test) < param_tol ;
			
		}
		else
		{
			temp = p.transpose() * p;
			conv2 = temp(0,0) < param_tol;
		}		
		// gradient convergence
		temp = g.transpose() * g;
		conv3 = sqrt(temp(0,0)) < gradient_tol;


		// Want intermediate results?
		if (verbosity == 1)
		{
			printf("\nnewtonmin intermediate results: Iteration %d\n",iter);
			printf("Stepsize %8.7f\n", stepsize);
			printf("Objective function value %16.10f\n", last_obj_value);
			printf("Function conv %d  Param conv %d  Gradient conv %d\n", conv1, conv2, conv3);	
			printf("  params  gradient  change\n");
	 		for (j = 0; j<k; j++)
			{
				printf("%8.4f %8.4f %8.4f\n",theta(j),g(j),p(j));
			}		
			printf("\n");
		}
	
		// Are we done?
		if (criterion == 1)
		{
			if (conv1 && conv2 && conv3)
			{
		  	convergence = 1;
	     	break;
			}
		}		
		else if (conv1)
		{
				convergence = 1;
				break;
		}
		
			
  	    last_obj_value = obj_value;	
		thetanew = theta + p;
		theta = thetanew;

		// get gradient at new parameter value
		f_args(minarg - 1) = theta;
		g_args(1) = f_args;
		f_return = feval("numgradient", g_args);
		g_new = f_return(0).matrix_value();
		g_new = g_new.transpose();

		// Check that gradient is ok
		gradient_failed = 0;  // test = 1 means gradient failed
		for (i=0; i<k;i++)
		{
			gradient_failed = gradient_failed + xisnan(g_new(i));
		}

		// Hessian		
		if (!gradient_failed)
		{
			g = g_new;
			f_return = feval("numhessian", g_args);
			H = f_return(0).matrix_value();
			H = H.inverse();
		}	
		else // failed gradient - try Hessian reset
		{
			// if we already tried it, we're out of luck
			if (H == identity_matrix(k,k))
			{
				convergence = 2;
				theta = thetain;
				warning("NewtonMin: failure of gradient: exiting");
				break;
			}	
			H = identity_matrix(k,k);
		}	
	}
	
 	// Want last iteration results?
	if (verbosity == 2)
	{
		printf("\n================================================\n");
		printf("NEWTONMIN final results\n");
		if (convergence == -1) printf("NO CONVERGENCE: maxiters exceeded\n");
		if ((convergence == 1) & (criterion == 1)) printf("STRONG CONVERGENCE\n");
		if ((convergence == 1) & !(criterion == 1)) printf("WEAK CONVERGENCE\n");
		if (convergence == 2) printf("NO CONVERGENCE: algorithm failed\n");
		printf("\nObj. fn. value %f     Iteration %d\n", last_obj_value, iter);
		printf("Function conv %d  Param conv %d  Gradient conv %d\n", conv1, conv2, conv3);	
		printf("\n  param  gradient  change\n");
		for (j = 0; j<k; j++)
		{
			printf("%8.4f %8.4f %8.4f\n",theta(j),g(j),p(j));
		}		
	printf("================================================\n");
	}
	f_return(0) = theta;
	f_return(1) = obj_value;
	f_return(2) = iter;
	f_return(3) = convergence;
	return octave_value_list(f_return);
}
