// Copyright (C) 2004,2005  Michael Creel   <michael.creel@uab.es>
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
// bfgs or limited memory bfgs minimization of function of form 
//
// [value, return_2,..., return_m] = f(arg_1, arg_2,..., arg_n)
// 
// By default, minimization is w.r.t. arg_1, but this can be overridden

#include <oct.h>
#include <octave/parse.h>
#include <octave/Cell.h>
#include <octave/lo-mappers.h>
#include <float.h>
#include "error.h"

// define argument checks
static bool
any_bad_argument(const octave_value_list& args)
{

        int i;
	
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

  
  	// controls should be 4 or 5 element cell array of integers
	if (args.length() > 2)
	{
		Cell control (args(2).cell_value()); // get them to look at them
		if (error_state)
		{
			error("bfgsmin: 3rd argument must be a cell array of 4 or 5 integers");
			return true;
		}	
		
        // there should be 4 or 5 elements, depending on if bfgs or lbfgs
	if (((control.length() < 4) || (control.length() > 5)))
	{
		error("bfgsmin: 3rd argument must be a cell array of 4 or 5 integers");
		return true;
	}
		
	// special treatment for 1st element - it can be Inf or an integer
	if (!xisinf (control(0).double_value()))
	{
		int tmp = control(0).int_value();
		if (error_state)
		{
			error("bfgsmin: 3rd argument must be a cell array of 4 or 5 integers");
			return true;
		}	
	}	

        // now the other 3 or 4 elements	
		for (i=1; i < control.length(); i++)
		{
			int tmp = control(i).int_value();
			if (error_state)
			{
				error("bfgsmin: 3rd argument must be a cell array of 4 or 5 integers");
				return true;
			}
			if (i == 3) // minarg must point to one of args(1)
			{
				if ((tmp > args(1).length())||(tmp < 1))  
				{
					error("bfgsmin: 4th element of controls must be a positive integer that indicates \n\
which of the elements of the second argument is the one minimization is over");
					return true;
				}
			}		
			if (i == 4) // memory must be zero (bfgs) or positive integer (lbfgs)
			{
				if (tmp < 0)
				{
					error("bfgsmin: 5th argument of controls, if provided\n\
must be 0 (bfgs) or positive integer (memory for lbfgs)");
					return true;
				}
			}		

		}
	}

  
  	// tolerances should be 3 element cell array of doubles
  	if (args.length() > 3)
  	{
    		// type is cell
		Cell tols (args(3).cell_value());
		if (error_state)
		{
			error("bfgsmin: 4th argument must be a cell array of 3 positive doubles");
			return true;
		}	

		// there should be 3 elements
		if (!(tols.length()==3))
		{
			error("bfgsmin: 4th argument, if supplied, must a 3-element cell array of tolerances");
			return true;
		}
		
		for (i=0; i<3; i++)
		{
			double tmp = tols(i).double_value();
			if (error_state)
			{
				error("bfgsmin: 4th argument must be a cell array of 3 positive doubles");
				return true;
			}	

			if(tmp < 0)
			{	
				error("bfgsmin: 4th argument must be a cell array of 3 positive doubles");
				return true;
			}	
		}
	}	
  	return false;
}

// this is the lbfgs direction, used if control has 5 elements
ColumnVector lbfgs_recursion(int memory, Matrix& sigmas, Matrix& gammas, ColumnVector d)
{
	if (memory == 0)
  	{
    		const int n = sigmas.columns();
    		ColumnVector sig = sigmas.column(n-1);
    		ColumnVector gam = gammas.column(n-1);
    		// do conditioning if there is any memory
    		double cond = gam.transpose()*gam;
    		if (cond > 0)
		{
	  		cond = (sig.transpose()*gam) / cond;
	  		d = cond*d;
		}
   		 return d;
  	}	
  	else
  	{
    		const int k = d.rows();
    		const int n = sigmas.columns();
    		int i, j;
    		ColumnVector sig = sigmas.column(memory-1);
    		ColumnVector gam = gammas.column(memory-1);
   	 	double rho;
    		rho = 1.0 / (gam.transpose() * sig);
    		double alpha;
    		alpha = rho * (sig.transpose() * d);
    		d = d - alpha*gam;
    		d = lbfgs_recursion(memory - 1, sigmas, gammas, d);
    		d = d + (alpha - rho * gam.transpose() * d) * sig;
  	}
  	return d;
}			


DEFUN_DLD(bfgsmin, args, ,
"bfgsmin: bfgs minimization of a function with respect to a column vector.\n\
\n\
By default, numeric derivatives are used, but see bfgsmin_example.m\n\
for how to use analytic derivatives\n\
\n\
Usage: [x, obj, convergence] = bfgsmin(\"f\", args, control, tols)\n\
\n\
Arguments:\n\
* \"f\": function name (string)\n\
* args: a cell array that holds all arguments of the function\n\
	The argument with respect to which minimization is done\n\
	MUST be a COLUMN vector\n\
* control: an optional cell array of 4 or 5 elements\n\
	* elem 1: maximum iterations  (-1 = infinity (default))\n\
	* elem 2: verbosity\n\
		0 = no screen output (default)\n\
		1 = summary every iteration\n\
		2 = only final results\n\
	* elem 3: convergence criterion\n\
		1 = strict (function, gradient and param change) (default)\n\
		2 = weak - only function convergence required\n\
	* elem 4: arg with respect to which minimization is done\n\
		(default = first)\n\
	* elem 5: (optimal) Memory limit for lbfgs. If it's a positive integer\n\
		then lbfgs will be use. Otherwise ordinary bfgs is used\n\
* tols: an optional cell array of 3 elements\n\
	* elem 1: function change tolerance, default 1e-12\n\
	* elem 2: parameter change tolerance, default 1e-6\n\
	* elem 3: gradient tolerance, default 1e-4\n\
\n\
Returns:\n\
* x: the minimizer\n\
* obj: the value of f() at x\n\
* convergence: 1 if normal conv, other values if not\n\
* iters: number of iterations performed\n\
\n\
Example:\n\
function a = f(x,y)\n\
	a = x'*x + y'*y;\n\
endfunction\n\
\n\
In this example, x is optimized since it's the first\n\
element of the cell array, y is a fixed constant = 1\n\
\n\
bfgsmin(\"f\", {ones(2,1), 1}, {10,2,1,1})\n\
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
	int memory, gradient_failed, i, j, k, conv_fun, conv_param, conv_grad;
	int have_gradient = 0;
	double func_tol, param_tol, gradient_tol, stepsize, obj_value;
	double obj_in, last_obj_value, denominator, test;
	Matrix H, tempmatrix, H1, H2;
	ColumnVector thetain, d, g, g_new, p, q, sig, gam;


	// Default values for controls
	max_iters = INT_MAX; // no limit on iterations
	verbosity = 0; // by default don't report results to screen
	criterion = 1; // strong convergence required
	minarg = 1; // by default, first arg is one over which we minimize
	      memory = 0;

	// use provided controls, if applicable
	if (args.length() > 2)
	{
		Cell control (args(2).cell_value());
		if (xisinf (control(0).double_value()))  // this is to allow 'Inf' as first element of control
		  	max_iters = -1;
		else 
			max_iters = control(0).int_value();
		if (max_iters == -1) max_iters = INT_MAX;
		verbosity = control(1).int_value();
		criterion = control(2).int_value();
		minarg = control(3).int_value();
		if (control.length() > 4) memory = control(4).int_value();
	}     
 

	// type checking for minimization parameter done here, since we don't know minarg
	// until now	
	if (!(f_args(minarg - 1).is_real_matrix() || (f_args(minarg - 1).is_real_scalar())))
	{
		error("bfgsmin: minimization must be with respect to a column vector");
		return octave_value_list();
	}
	if ((f_args(minarg - 1).is_real_matrix()) && (f_args(minarg - 1).columns() != 1))
	{
		error("bfgsmin: minimization must be with respect to a column vector");
		return octave_value_list();
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
		gradient_tol = 1e-4;  
	}


	// arguments for stepsize function
	step_args(0) = f; 
	step_args(1) = f_args;
	step_args(3) = minarg;

	// arguments for numgradient
	g_args(0) = f;
	g_args(1) = f_args;
	g_args(2) = minarg;

	// arguments for celleval (to calculate objective function value)
	c_args(0) = f;
	c_args(1) = f_args;
	
	// get the minimization argument
	ColumnVector theta  = f_args(minarg - 1).column_vector_value();
	k = theta.rows();
	
	// containers for items in limited memory version
	Matrix sigmas(k,memory);
	Matrix gammas(k,memory);

	
	// initialize things
	convergence = -1; // if this doesn't change, it means that maxiters were exceeded
	thetain = theta;
	H = identity_matrix(k,k);

	// Initial obj_value
	f_return = feval("celleval", c_args);
	obj_in = f_return(0).double_value();
	if (error_state) // check that objective function returns a double
	{
		error("bfgsmin: objective function did not return a scalar numeric value");
        	return octave_value_list();
	}      

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
		if (error_state)
		{
			error("bfgsmin: unable to calculate numeric gradient of objective function: need to recompile numgradient?");
			return octave_value_list();
		}
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

    		if(memory > 0) // lbfgs
		{
			if (iter < memory) d = lbfgs_recursion(iter, sigmas, gammas, g);
			else d = lbfgs_recursion(memory, sigmas, gammas, g);
			d = -d;
		}
		else d = -H*g; // ordinary bfgs

		// stepsize: try (l)bfgs direction, then steepest descent if it fails
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
		if (test > 1) conv_param = sqrt(p.transpose() * p) / test < param_tol ;
		else conv_param = sqrt(p.transpose() * p) < param_tol;
		// gradient convergence
		conv_grad = sqrt(g.transpose() * g) < gradient_tol;

		// Want intermediate results?
		if ((verbosity > 0) && (verbosity < 2))
		{
			printf("\n======================================================\n");
			printf("BFGSMIN intermediate results\n");
			printf("\n");
			if (memory > 0) printf("Using LBFGS, memory is last %d iterations\n",memory);
			if (have_gradient) printf("Using analytic gradient\n");
			else printf("Using numeric gradient\n");
			printf("\n");
			printf("------------------------------------------------------\n");
			printf("Function conv %d  Param conv %d  Gradient conv %d\n", conv_fun, conv_param, conv_grad); 
			printf("------------------------------------------------------\n");
			printf("Objective function value %g\n", last_obj_value);
			printf("Stepsize %g\n", stepsize);
			printf("%d iterations\n", iter);
			printf("------------------------------------------------------\n");
			printf("\n param	gradient  change\n");
			for (j = 0; j<k; j++) printf("%8.4f %8.4f %8.4f\n",theta(j),g(j),p(j));
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
		for (i=0; i<k;i++) gradient_failed = gradient_failed + xisnan(g_new(i));

		if (memory == 0) //use bfgs
		{
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
		else // use lbfgs
		{
			// save components for Hessian if gradient ok
			if (!gradient_failed)
			{
				sig = p; // change in parameter
				gam = g_new - g; // change in gradient
				g = g_new;
				// shift remembered vectors to the right (forget last)
				for(j = memory - 1; j > 0; j--)
				{
					for(i = 0; i < k; i++)
					{
						sigmas(i,j) = sigmas(i,j-1);
						gammas(i,j) = gammas(i,j-1);
					}
				}
				// insert new vectors in left-most column
				for(i = 0; i < k; i++)
				{
					sigmas(i, 0) = sig(i);
					gammas(i, 0) = gam(i);
				}
			}
			else // failed gradient - loose memory and use previous theta
			{
				sigmas.fill(0.0);
				gammas.fill(0.0);
				theta = theta - p;
			}
		}		
	}
	
	// Want last iteration results?
	if (verbosity > 0)
	{
		printf("\n======================================================\n");
		printf("BFGSMIN final results\n");
		printf("\n");
		if (memory > 0) printf("Used LBFGS, memory is last %d iterations\n",memory);
		if (have_gradient) printf("Used analytic gradient\n");
		else printf("Used numeric gradient\n");
		printf("\n");
		printf("------------------------------------------------------\n");
		if (convergence == -1)                      printf("NO CONVERGENCE: max iters exceeded\n");
		if ((convergence == 1) & (criterion == 1))  printf("STRONG CONVERGENCE\n");
		if ((convergence == 1) & !(criterion == 1)) printf("WEAK CONVERGENCE\n");
		if (convergence == 2)                       printf("NO CONVERGENCE: algorithm failed\n");
		printf("Function conv %d  Param conv %d  Gradient conv %d\n", conv_fun, conv_param, conv_grad);	
		printf("------------------------------------------------------\n");
		printf("Objective function value %g\n", last_obj_value);
		printf("Stepsize %g\n", stepsize);
		printf("%d iterations\n", iter);
		printf("------------------------------------------------------\n");
		printf("\n param    gradient  change\n");
		for (j = 0; j<k; j++) printf("%8.4f %8.4f %8.4f\n",theta(j),g(j),p(j));
	}
	f_return(0) = theta;
	f_return(1) = obj_value;
	f_return(2) = convergence;
	f_return(3) = iter;
	return octave_value_list(f_return);
}
