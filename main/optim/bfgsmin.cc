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

// bfgsmin
// 
// bfgs minimization of function of form 
//
// [value, return_2,..., return_m] = f(arg_1, arg_2,..., arg_n)
// 
// By default, minimization is w.r.t. arg_1, but this can be overridden

#include <oct.h>
#include <octave/parse.h>
#include <octave/Cell.h>
#include <octave/lo-mappers.h>
#include <float.h>

// define argument checks
static bool
any_bad_argument(const octave_value_list& args)
{
	if (!args(0).is_string())
    {
        error("bfgsmin: first argument must be string holding objective function name");
        return true;
    }
	if (!args(1).is_cell())
    {
        error("bfgsmin: second argument must cell array of function arguments");
        return true;
    }
 	if (args.length() == 3)
	{
		if (!args(2).is_cell() || (!(args(2).length() == 4)))
    	{
        	error("bfgsmin: 3rd argument, if supplied,  must a 4-element cell array of control options");
	        return true;
    	}
	}
 	if (args.length() == 4)
	{
		if (!args(3).is_cell() || (!(args(3).length() == 3)))
    	{
        	error("bfgsmin: 4th argument, if supplied, must a 3-element cell array of tolerances");
	        return true;
    	}
	}	

    return false;
}


DEFUN_DLD(bfgsmin, args, ,
"bfgsmin: bfgs minimization of a function.\n\
\n\
[x, obj, convergence] = bfgsmin(\"f\", {args}, {control}, {tols})\n\
\n\
Arguments:\n\
* \"f\": function name (string)\n\
* {args}: a cell array that holds all arguments of the function,\n\
* {control}: an optional cell array of 4 elements\n\
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
* {tols}: an optional cell array of 3 elements\n\
	* elem 1: function change tolerance, default 1e-12\n\
	* elem 2: parameter change tolerance, default 1e-6\n\
	* elem 3: gradient tolerance, default 1e-5\n\
\n\
Returns:\n\
* x: the minimizer\n\
* obj: the value of f() at x\n\
* convergence: 1 if normal conv, other values if not\n\
\n\
Example:\n\
function a = f(x,y)\n\
	a = x'*x + y'*y;\n\
endfunction\n\
\n\
In this example, x is optimized since it's the first\n\
element of the cell array, y is a fixed constant = 1\n\
\n\
bfgsmin(\"f\", {ones(2,1), 1}, [10,2,1,1])\n\
\n\
bfgsmin final results: Iteration 1\n\
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
	if ((nargin < 2) || (nargin > 4))
    {
      	error("bfgsmin: you must supply 2, 3 or 4 arguments");
	    return octave_value_list();
    }

    // check the arguments
	if (any_bad_argument(args)) return octave_value_list();


	std::string f (args(0).string_value());
	Cell f_args (args(1).cell_value());

	octave_value_list step_args(4,1);  // for stepsize: {f, f_args, direction, minarg}
	octave_value_list g_args(3,1); // for numgradient {f, f_args, minarg}
	octave_value_list c_args(2,1); // for celleval {f, f_args}  
	
	octave_value_list f_return; // holder for feval returns

	int max_iters, verbosity, criterion, minarg;
	int convergence, iter;
	int gradient_failed, i, j, k, conv_fun, conv_param, conv_grad;
	int have_gradient = 0;
	double func_tol, param_tol, gradient_tol, stepsize, obj_value;
	double obj_in, last_obj_value, denominator, test;
	Matrix H, tempmatrix, H1, H2;
	ColumnVector thetain, d, g, g_new, p, q;

 	// use provided controls, if applicable
	if (args.length() >= 3)
	{
		Cell control (args(2).cell_value());
		if (xisinf (control(0).double_value()))
		  max_iters = -1;
		else 
		  max_iters = control(0).int_value();
		if (max_iters == -1) max_iters = INT_MAX;
		verbosity = control(1).int_value();
		criterion = control(2).int_value();
		minarg = control(3).int_value();
	}	
	else
	{
		// Default values for controls
		max_iters = INT_MAX; // no limit on iterations
		verbosity = 0; // by default don't report results to screen
		criterion = 1; // strong convergence required
		minarg = 1; // by default, first arg is one over which we minimize
 	}
	
	
	 // use provided tolerances, if applicable
	if (args.length() == 4)
	{
		Cell tols (args(3).cell_value());
		func_tol = tols(0).double_value();
		param_tol = tols(1).double_value();
		gradient_tol = tols(2).double_value();
	}	
	else
	{
		// Default values for tolerances
		func_tol  = 1e-12;
		param_tol = 1e-6;
		gradient_tol = 1e-5;  

 	}
	
	step_args(0) = f; 
	step_args(1) = f_args;
	step_args(3) = minarg;

	g_args(0) = f;
	g_args(1) = f_args;
	g_args(2) = minarg;
	
	c_args(0) = f;
	c_args(1) = f_args;

 	ColumnVector theta  = f_args(minarg - 1).column_vector_value();

	k = theta.rows();
	
	// initialize things
	convergence = -1; // if this doesn't change, it means that maxiters were exceeded
 	thetain = theta;
	H = identity_matrix(k,k);

	// Initial obj_value
	f_return = feval("celleval", c_args); 
	obj_in = f_return(0).double_value();
	last_obj_value = obj_in;
	
	// maybe we have analytic gradient?
	// if the function returns more than one item, and the second
	// is a kx1 vector, it is assumed to be the gradient
	if (f_return.length() > 1)
	{
		if (f_return(1).is_real_matrix())
		{
			if ((f_return(1).rows() == k) & (f_return(1).columns() == 1))
			{
				g = f_return(1).column_vector_value();
				have_gradient = 1; // future reference
			}	
		}
		else have_gradient = 0;
		
	}
	if (!have_gradient) // use numeric gradient
	{
		f_return = feval("numgradient", g_args);
		tempmatrix = f_return(0).matrix_value();
		g = tempmatrix.row(0).transpose();
	}

	// check that gradient is ok
	gradient_failed = 0;  // test = 1 means gradient failed
	for (i=0; i<k;i++)
	{
		gradient_failed = gradient_failed + xisnan(g(i));
	}
	if (gradient_failed)
	{
		error("bfgsmin: Initial gradient could not be calculated: exiting");
		convergence = 2;
	}

	// MAIN LOOP STARTS HERE
 	for (iter = 0; iter < max_iters; iter++)
	{
		// make sure the messages aren't stale
		conv_fun = -1; 
		conv_param =  -1;
		conv_grad = -1;

		d = -H*g;

		// stepsize: try bfgs direction, then steepest descent if it fails
		step_args(2) = d;
		f_args(minarg - 1) = theta;
		step_args(1) = f_args;
		f_return = feval("newtonstep", step_args);
		stepsize = f_return(0).double_value();
		obj_value = f_return(1).double_value();
		if (stepsize == 0.0) // fall back to steepest descent
		{
			d = -g; // try steepest descent
			step_args(2) = d;
			f_return = feval("newtonstep", step_args);
			stepsize = f_return(0).double_value();
			obj_value = f_return(1).double_value();
		}

		p = stepsize*d;

 		// check normal convergence: all 3 must be satisfied
		// function convergence
		if (fabs(last_obj_value) > 1.0)
		{
 			conv_fun = (fabs(obj_value - last_obj_value)/fabs(last_obj_value)) < func_tol;
		}
		else
		{
			conv_fun = fabs(obj_value - last_obj_value) < func_tol;
		}	
		// parameter change convergence
		test = sqrt(theta.transpose() * theta);
		if (test > 1)
		{
			conv_param = sqrt(p.transpose() * p) / test < param_tol ;
			
		}
		else
		{
			conv_param = sqrt(p.transpose() * p) < param_tol;
		}		
		// gradient convergence
		conv_grad = sqrt(g.transpose() * g) < gradient_tol;


		// Want intermediate results?
		if (verbosity == 1)
		{
			printf("\nBFGSMIN intermediate results: Iteration %d\n",iter);
			printf("Stepsize %8.7f\n", stepsize);
			if (have_gradient) printf("Using analytic gradient\n");
			else printf("Using numeric gradient\n");
			printf("Objective function value %16.10f\n", last_obj_value);
			printf("Function conv %d  Param conv %d  Gradient conv %d\n", conv_fun, conv_param, conv_grad);	
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
			if (conv_fun && conv_param && conv_grad)
			{
		  	convergence = 1;
	     	break;
			}
		}		
		else if (conv_fun)
		{
				convergence = 1;
				break;
		}
		
			
  	    last_obj_value = obj_value;	
		theta = theta + p;

		// new gradient
		f_args(minarg - 1) = theta;
		if (have_gradient)
		{
			c_args(1) = f_args;
			f_return = feval("celleval", c_args);
			g_new = f_return(1).column_vector_value();
		}
		else // use numeric gradient
		{
			g_args(1) = f_args;
			f_return = feval("numgradient", g_args);
			tempmatrix = f_return(0).matrix_value();
			g_new = tempmatrix.row(0).transpose();
		}

		// Check that gradient is ok
		gradient_failed = 0;  // test = 1 means gradient failed
		for (i=0; i<k;i++)
		{
			gradient_failed = gradient_failed + xisnan(g_new(i));
		}

	// Hessian update if gradient ok		
		if (!gradient_failed)
		{
			q = g_new-g;
  	    	g = g_new;
			denominator = q.transpose()*p;
	  	  	if ((fabs(denominator) < DBL_EPSILON))  // reset Hessian if necessary
			{  	
				if (verbosity == 1) printf("bfgsmin: Hessian reset\n");
				H = identity_matrix(k,k);
			}	
		  	else 
			{
				H1 = (1.0+(q.transpose() * H * q) / denominator) / denominator \
					* (p * p.transpose());
				H2 = (p * q.transpose() * H + H*q*p.transpose());
				H2 = H2 / denominator;
			  	H = H + H1 - H2;
			}
		}
		else H = identity_matrix(k,k); // reset hessian if gradient fails
		// then try to start again with steepest descent
	}
	
 	// Want last iteration results?
	if (verbosity == 2)
	{
		printf("\n================================================\n");
		printf("BFGSMIN final results\n");
		if (convergence == -1) printf("NO CONVERGENCE: maxiters exceeded\n");
		if ((convergence == 1) & (criterion == 1)) printf("STRONG CONVERGENCE\n");
		if ((convergence == 1) & !(criterion == 1)) printf("WEAK CONVERGENCE\n");
		if (convergence == 2) printf("NO CONVERGENCE: algorithm failed\n");
		if (have_gradient) printf("Used analytic gradient\n");
		else printf("Used numeric gradient\n");
		printf("\nObj. fn. value %f     Iteration %d\n", obj_value, iter);
		printf("Function conv %d  Param conv %d  Gradient conv %d\n", conv_fun, conv_param, conv_grad);	
		printf("\n  param  gradient  change\n");
		for (j = 0; j<k; j++)
		{
			printf("%8.4f %8.4f %8.4f\n",theta(j),g(j),p(j));
		}		
	printf("================================================\n");

	}
	f_return(0) = theta;
	f_return(1) = obj_value;
	f_return(2) = convergence;
	return octave_value_list(f_return);
}
