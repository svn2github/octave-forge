// Copyright (C) 2004,2005,2006  Michael Creel   <michael.creel@uab.es>
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

// the functions defined in this file are:
// __bfgsmin_obj: bulletproofed objective function that allows checking for availability of analytic gradient
// __numgradient: numeric gradient, used only if analytic not supplied
// __bisectionstep: fallback stepsize algorithm
// __newtonstep: default stepsize algorithm
// __bfgsmin: the DLD function that does the minimization, to be called from bfgsmin.m



#include <oct.h>
#include <octave/parse.h>
#include <octave/Cell.h>
#include <float.h>
#include "error.h"


int __bfgsmin_obj(double &obj, const std::string f, octave_value_list f_args, const ColumnVector theta, const int minarg)
{
	octave_value_list f_return;
	int success = 1;

	f_args(minarg - 1) = theta;
	f_return = feval(f, f_args);
	obj = f_return(0).double_value();
	// bullet-proof the objective function
	if (error_state)
	{
		warning("__bfgsmin_obj: objective function could not be evaluated - setting to DBL_MAX");
		obj = DBL_MAX;
		success = 0;
	}
	return success;
}


// __numgradient: numeric central difference gradient for bfgs.
// This is the same as numgradient, except the derivative is known to be a vector, it's defined as a column,
// and the finite difference delta is incorporated directly rather than called from a function
int __numgradient(ColumnVector &derivative, const std::string f, const octave_value_list f_args, const int minarg)
{
	double SQRT_EPS, diff, delta, obj_left, obj_right, p;
	int j, test, success;

	ColumnVector parameter = f_args(minarg - 1).column_vector_value();

	int k = parameter.rows();
	ColumnVector g(k);

	for (j=0; j<k; j++) // get 1st derivative by central difference
	{
		p = parameter(j);
		// determine delta for finite differencing
		SQRT_EPS = sqrt(DBL_EPSILON);
		diff = exp(log(DBL_EPSILON)/3);
		test = (fabs(p) + SQRT_EPS) * SQRT_EPS > diff;
		if (test) delta = (fabs(p) + SQRT_EPS) * SQRT_EPS;
		else delta = diff;
		// right side
		parameter(j) = p + delta;
		success = __bfgsmin_obj(obj_right, f, f_args, parameter, minarg);
		if (!success) error("__numgradient: objective function failed, can't compute numeric gradient");
		// left size
		parameter(j) = p - delta;
		success = __bfgsmin_obj(obj_left, f, f_args, parameter, minarg);
		if (!success) error("__numgradient: objective function failed, can't compute numeric gradient");		parameter(j) = p;  // restore original parameter for next round
		g(j) = (obj_right - obj_left) / (2*delta);
	}
	derivative = g;
	return success;
}


int __bfgsmin_gradient(ColumnVector &derivative, const std::string f, octave_value_list f_args, const ColumnVector theta, const int minarg, int try_analytic_gradient, int &have_analytic_gradient) {
	octave_value_list f_return;
	int k = theta.rows();
	int success;
	ColumnVector g(k);
	Matrix check_gradient(k,1);

	if (have_analytic_gradient) {
		f_args(minarg - 1) = theta;
		f_return = feval(f, f_args);
		g = f_return(1).column_vector_value();
	}

	else if (try_analytic_gradient) {
		f_args(minarg - 1) = theta;
		f_return = feval(f, f_args);
		if (f_return.length() > 1) {
			if (f_return(1).is_real_matrix()) {
        			if ((f_return(1).rows() == k) & (f_return(1).columns() == 1)) {
					g = f_return(1).column_vector_value();
					have_analytic_gradient = 1;
				}
				else have_analytic_gradient = 0;
			}
			else have_analytic_gradient = 0;
		}
		else have_analytic_gradient = 0;
		if (!have_analytic_gradient) __numgradient(g, f, f_args, minarg);
	}
	else __numgradient(g, f, f_args, minarg);

	// check that gradient is ok
	check_gradient.column(0) = g;
	if (check_gradient.any_element_is_inf_or_nan()) {
		error("__bfgsmin_gradient: gradient contains NaNs or Inf");
		success = 0;
	}
	else success = 1;

	derivative = g;
	return success;
}


// this is the lbfgs direction, used if control has 5 elements
ColumnVector lbfgs_recursion(const int memory, const Matrix sigmas, const Matrix gammas, ColumnVector d)
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

// __bisectionstep: fallback stepsize method if __newtonstep fails
int __bisectionstep(double &step, double &obj, const std::string f, const octave_value_list f_args, const ColumnVector dx, const int minarg, const int verbose)
{
	double obj_0, a;
	int found_improvement;

	ColumnVector x (f_args(minarg - 1).column_vector_value());

	// initial values
	obj_0 = obj;
	a = 1.0;
	found_improvement = 0;

	// this first loop goes until an improvement is found
	while (a > 2*DBL_EPSILON) // limit iterations
	{
		__bfgsmin_obj(obj, f, f_args, x + a*dx, minarg);
		// reduce stepsize if worse, or if function can't be evaluated
		if ((obj >= obj_0) || lo_ieee_isnan(obj)) a = 0.5 * a;
		else
		{
			obj_0 = obj;
			found_improvement = 1;
			break;
		}
	}
	// If unable to find any improvement break out with stepsize zero
	if (!found_improvement)
	{
		if (verbose) warning("bisectionstep: unable to find improvement, setting step to zero");
		step = 0.0;
		obj = obj_0;
		return found_improvement;
	}
	// now keep going until we no longer improve, or reach max trials
	while (a > 2*DBL_EPSILON)
	{
		a = 0.5*a;
		__bfgsmin_obj(obj, f, f_args, x + a*dx, minarg);
		// if improved, record new best and try another step
		if (obj < obj_0) obj_0 = obj;
		else
		{
			a = a / 0.5; // put it back to best found
			break;
		}
	}
	step = a;
	obj = obj_0;
	return found_improvement;
}

// __newtonstep: default stepsize algorithm
int __newtonstep(double &a, double &obj, const std::string f, const octave_value_list f_args, const ColumnVector dx, const int minarg, const int verbose)
{
	double obj_0, obj_left, obj_right, delta, inv_delta_sq, gradient, hessian;
	int found_improvement = 0;

	ColumnVector x (f_args(minarg - 1).column_vector_value());

	// initial value without step
	__bfgsmin_obj(obj_0, f, f_args, x, minarg);

	delta = 0.001; // experimentation show that this is a good choice
	inv_delta_sq = 1.0 / (delta*delta);
	ColumnVector x_right = x + delta*dx;
	ColumnVector x_left = x  - delta*dx;

	// right
	__bfgsmin_obj(obj_right, f, f_args, x_right, minarg);
	// left
	__bfgsmin_obj(obj_left, f, f_args, x_left, minarg);

	gradient = (obj_right - obj_left) / (2*delta);  // take central difference
	hessian =  inv_delta_sq*(obj_right - 2*obj_0 + obj_left);
	hessian = fabs(hessian); // ensures we're going in a decreasing direction
	if (hessian < 2*DBL_EPSILON) hessian = 1.0; // avoid div by zero
	a = - gradient / hessian;  // hessian inverse gradient: the Newton step
	if (a < 0) 	// since direction is descending, a must be positive
	{ 		// if it is not, go to bisection step
		if (verbose) warning("__stepsize: no improvement with Newton step, falling back to bisection");
		found_improvement = __bisectionstep(a, obj, f, f_args, dx, minarg, verbose);
		return 0;
	}

	a = (a < 10.0)*a + 10.0*(a>=10.0); // Let's avoid extreme steps that might cause crashes

	// ensure that this is improvement
	__bfgsmin_obj(obj, f, f_args, x + a*dx, minarg);

	// if not, fall back to bisection
	if ((obj >= obj_0) || lo_ieee_isnan(obj))
	{
		if (verbose) warning("__stepsize: no improvement with Newton step, falling back to bisection");
		found_improvement = __bisectionstep(a, obj, f, f_args, dx, minarg, verbose);
	}
	else found_improvement = 1;

	return found_improvement;
}




DEFUN_DLD(__bfgsmin, args, ,"__bfgsmin: backend for bfgs minimization\n\
Users should not use this directly. Use bfgsmin.m instead") {
	std::string f (args(0).string_value());
  	Cell f_args_cell (args(1).cell_value());
	octave_value_list f_args, f_return; // holder for return items

	int max_iters, verbosity, criterion, minarg, convergence, iter, memory, \
		gradient_ok, i, j, k, conv_fun, conv_param, conv_grad, have_gradient, \
		try_gradient, warnings;
	double func_tol, param_tol, gradient_tol, stepsize, obj_value, obj_in, last_obj_value, denominator, test;
	Matrix H, H1, H2;
	ColumnVector thetain, d, g, g_new, p, q, sig, gam;

	// controls
	Cell control (args(2).cell_value());
	max_iters = control(0).int_value();
	if (max_iters == -1) max_iters = INT_MAX;
	verbosity = control(1).int_value();
	criterion = control(2).int_value();
	minarg = control(3).int_value();
	memory = control(4).int_value();
	func_tol = control(5).double_value();
	param_tol = control(6).double_value();
	gradient_tol = control(7).double_value();

	// want to see warnings?
	warnings = 0;
	if (verbosity == 3) warnings = 1;

	// copy cell contents over to octave_value_list to use feval()
	k = f_args_cell.length();
	f_args(k); // resize only once
	for (i = 0; i<k; i++) f_args(i) = f_args_cell(i);

	// get the minimization argument
	ColumnVector theta  = f_args(minarg - 1).column_vector_value();
	k = theta.rows();

	// containers for items in limited memory version
	Matrix sigmas(k,memory);
	Matrix gammas(k,memory);

	// initialize things
	have_gradient = 0; // have analytic gradient
	try_gradient = 1;  // try to get analytic gradient
	convergence = -1; // if this doesn't change, it means that maxiters were exceeded
	thetain = theta;
	H = identity_matrix(k,k);

	// Initial obj_value
	__bfgsmin_obj(obj_in, f, f_args, theta, minarg);

	// Initial gradient (try analytic, and use it if it's close enough to numeric)
	__bfgsmin_gradient(g, f, f_args, theta, minarg, 1, have_gradient);	// try analytic
	if (have_gradient) {					// check equality if analytic available
		have_gradient = 0;				// force numeric
		__bfgsmin_gradient(g_new, f, f_args, theta, minarg, 0, have_gradient);
		p = g - g_new;
		have_gradient = sqrt(p.transpose() * p) < gradient_tol;
	}

	last_obj_value = obj_in; // initialize, is updated after each iteration
	// MAIN LOOP STARTS HERE
	for (iter = 0; iter < max_iters; iter++) {
  		// make sure the messages aren't stale
		conv_fun = -1;
		conv_param = -1;
		conv_grad = -1;

    		if(memory > 0) {  // lbfgs
			if (iter < memory) d = lbfgs_recursion(iter, sigmas, gammas, g);
			else d = lbfgs_recursion(memory, sigmas, gammas, g);
			d = -d;
		}
		else d = -H*g; // ordinary bfgs

		// stepsize: try (l)bfgs direction, then steepest descent if it fails
		f_args(minarg - 1) = theta;
		__newtonstep(stepsize, obj_value, f, f_args, d, minarg, warnings);
		if (stepsize == 0.0) {  // fall back to steepest descent
			if (warnings) warning("bfgsmin: BFGS direction fails, switch to steepest descent");
			d = -g; // try steepest descent
			__newtonstep(stepsize, obj_value, f, f_args, d, minarg, warnings);
			if (stepsize == 0.0) {  // if true, exit, we can't find a direction of descent
				warning("bfgsmin: failure, exiting. Try different start values?");
				f_return(0) = theta;
				f_return(1) = obj_value;
				f_return(2) = -1;
				f_return(3) = iter;
				return octave_value_list(f_return);
			}
		}
		p = stepsize*d;

		// check normal convergence: all 3 must be satisfied
		// function convergence
		if (fabs(last_obj_value) > 1.0)	{
			conv_fun = (fabs(obj_value - last_obj_value)/fabs(last_obj_value)) < func_tol;
		}
		else {
			conv_fun = fabs(obj_value - last_obj_value) < func_tol;
		}
		// parameter change convergence
		test = sqrt(theta.transpose() * theta);
		if (test > 1) conv_param = sqrt(p.transpose() * p) / test < param_tol ;
		else conv_param = sqrt(p.transpose() * p) < param_tol;		// Want intermediate results?
		// gradient convergence
		conv_grad = sqrt(g.transpose() * g) < gradient_tol;

		// Want intermediate results?
		if (verbosity > 1) {
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
		if (criterion == 1) {
			if (conv_fun && conv_param && conv_grad) {
				convergence = 1;
				break;
			}
		}
		else if (conv_fun) {
			convergence = 1;
			break;
		}
		last_obj_value = obj_value;
		theta = theta + p;

		// new gradient
		gradient_ok = __bfgsmin_gradient(g_new, f, f_args, theta, minarg, try_gradient, have_gradient);

		if (memory == 0) {  //bfgs?
			// Hessian update if gradient ok
			if (gradient_ok) {
				q = g_new-g;
				g = g_new;
				denominator = q.transpose()*p;
				if ((fabs(denominator) < DBL_EPSILON)) {  // reset Hessian if necessary
					if (verbosity == 1) printf("bfgsmin: Hessian reset\n");
					H = identity_matrix(k,k);
				}
				else {
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
		else {  // otherwise lbfgs
			// save components for Hessian if gradient ok
			if (gradient_ok) {
				sig = p; // change in parameter
				gam = g_new - g; // change in gradient
				g = g_new;
				// shift remembered vectors to the right (forget last)
				for(j = memory - 1; j > 0; j--) {
					for(i = 0; i < k; i++) 	{
						sigmas(i,j) = sigmas(i,j-1);
						gammas(i,j) = gammas(i,j-1);
					}
				}
				// insert new vectors in left-most column
				for(i = 0; i < k; i++) {
					sigmas(i, 0) = sig(i);
					gammas(i, 0) = gam(i);
				}
			}
			else { // failed gradient - loose memory and use previous theta
				sigmas.fill(0.0);
				gammas.fill(0.0);
				theta = theta - p;
			}
		}
	}

	// Want last iteration results?
	if (verbosity > 0) {
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
	f_return(3) = iter;
	f_return(2) = convergence;
	f_return(1) = obj_value;
	f_return(0) = theta;
	return f_return;
}
