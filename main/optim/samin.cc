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
// simann.cc (c) 2004 Michael Creel <michael.creel@uab.es>
// References:
//
// The code follows this article:
// Goffe, William L. (1996) "SIMANN: A Global Optimization Algorithm
//	using Simulated Annealing " Studies in Nonlinear Dynamics & Econometrics
//  Oct96, Vol. 1 Issue 3.
// 
// The code uses the same names for control variables,
// for the most part. A notable difference is that the initial
// temperature is found automatically to ensure that the active
// bounds when the temperature begins to reduce cover the entire
// parameter space (defined as a n-dimensional
// rectangle that is the Cartesian product of the
// (lb_i, ub_i), i = 1,2,..n
//
// Also of note:
// Corana et. al., (1987) "Minimizing Multimodal Functions of Continuous
//	Variables with the "Simulated Annealing" Algorithm",
// 	ACM Transactions on Mathematical Software, V. 13, N. 3.
//
// Goffe, et. al. (1994) "Global Optimization of Statistical Functions
// 	with Simulated Annealing", Journal of Econometrics,
// 	V. 60, N. 1/2.  
	
	
#include <oct.h>
#include <octave/parse.h>
#include <octave/Cell.h>
#include <octave/lo-mappers.h>
#include <octave/oct-rand.h>
#include <float.h>

// define argument checks
static bool
any_bad_argument(const octave_value_list& args)
{
  if (!args(0).is_string())
    {
      error("samin: first argument must be string holding objective function name");
      return true;
    }
  if (!args(1).is_cell())
    {
      error("samin: second argument must cell array of function arguments");
      return true;
    }
  if (!args(2).is_cell())
    {
      error("samin: third argument must cell array of algorithm controls");
      return true;
    }	
  Cell control (args(2).cell_value());
  if (!(control.length() == 11))
    {
      error("samin: third argument must be a cell array with 11 elements");
      return true;
    }
  if (!control(0).is_numeric_type())
    {
      error("samin: 1st element of controls must be LB: a vector of lower bounds");
      return true;
    }
  if (!control(1).is_numeric_type())
    {
      error("samin: 2nd element of controls must be UB: a vector of upper bounds");
      return true;
    }
  if (!control(2).is_real_scalar())
    {
      error("samin: 3rd element of controls must be NT: positive integer\n\
		 	loops per temperature reduction");
      return true;
    }
  if (!control(3).is_real_scalar())
    {
      error("samin: 4th element of controls must be NS: positive integer\n\
		 	loops per stepsize adjustment");
      return true;
    }
  if (!control(4).is_real_scalar())
    {
      error("samin: 5th element of controls must be RT:\n\
		 	temperature reduction factor, between 0 and 1");
      return true;
    }
  if (!control(5).is_real_scalar())
    {
      error("samin: 6th element of controls must be integer MAXEVALS ");
      return true;
    }
  if (!control(6).is_real_scalar())
    {
      error("samin: 7th element of controls must be NEPS: positive integer\n\
		 	number of final obj. values that must be within EPS of eachother ");
      return true;
    }
  if (!control(7).is_real_scalar())
    {
      error("samin: 8th element of controls must must be FUNCTOL (> 0)\n\
			used to compare the last NEPS obj values for convergence test");
      return true;
    }
  if (!control(8).is_real_scalar())
    {
      error("samin: 9th element of controls must must be PARAMTOL (> 0)\n\
			used to compare the last NEPS obj values for convergence test");
      return true;
    }

  if (!control(9).is_real_scalar())
    {
      error("samin: 9th element of controls must be VERBOSITY (0, 1, or 2)");
      return true;
    }
  if (!control(10).is_real_scalar())
    {
      error("samin: 10th element of controls must be MINARG (integer)\n\
		 position of argument to minimize wrt");
      return true;
    }
  return false;
}


//-------------- The annealing algorithm --------------
DEFUN_DLD(samin, args, ,
	  "samin: simulated annealing minimization of a function.\n\
\n\
[x, obj, convergence] = samin(\"f\", {args}, {control})\n\
\n\
Arguments:\n\
* \"f\": function name (string)\n\
* {args}: a cell array that holds all arguments of the function,\n\
* {control}: a cell array with 11 elements\n\
	* LB  - vector of lower bounds\n\
	* UB - vector of upper bounds\n\
	* nt - integer: # of iterations between temperature reductions\n\
	* ns - integer: # of iterations between bounds adjustments\n\
	* rt - 0 < rt <1: temperature reduction factor\n\
	* maxevals - integer: limit on function evaluations\n\
	* neps - integer:  # number of values final result is compared to\n\
	* functol -   > 0: the required tolerance level for function value comparisons\n\
	* paramtol -  > 0: the required tolerance level for parameters\n\
	* verbosity - scalar: 0, 1, or 2.\n\
		* 0 = no screen output\n\
		* 1 = summary every temperature change\n\
		* 2 = only final results to screen\n\
	* minarg - integer: which of function args is minimization over?\n\
\n\
Returns:\n\
* x: the minimizer\n\
* obj: the value of f() at x\n\
* convergence: 1 if normal conv, other values if not\n\
\n\
Example: A really stupid way to calculate pi\n\
function a = f(x)\n\
	a = cos(x) + 0.01*(x-pi)^2;\n\
endfunction\n\
\n\
Set up the controls:\n\
ub = 20;\n\
lb = -ub;\n\
nt = 20;\n\
ns = 5;\n\
rt = 0.5;\n\
maxevals = 1e10;\n\
neps = 5;\n\
functol = 1e-10;\n\
paramtol = 1e-5;\n\
verbosity = 2;\n\
minarg = 1;\n\
\n\
Put them in a cell array:\n\
control = {lb, ub, nt, ns, rt, maxevals,\n\
	neps, functol, paramtol, verbosity, minarg};\n\
\n\
Call the minimizer (function argument also in cell array):\n\
samin(\"f\", {-8}, control)\n\
\n\
The result:\n\
================================================\n\
SAMIN final results\n\
Sucessful convergence to tolerance 0.000010\n\
\n\
Obj. fn. value -1.000000\n\
           parameter        search width\n\
            3.141597            0.002170\n\
================================================\n\
ans = 3.1416\n\
")
{
  int nargin = args.length();
  if (!(nargin == 3))
    {
      error("samin: you must supply 3 arguments");
      return octave_value_list();
    }

  // check the arguments
  if (any_bad_argument(args)) return octave_value_list();

  std::string obj_fn (args(0).string_value());
  Cell f_args (args(1).cell_value());
  Cell control (args(2).cell_value());
	
  octave_value_list c_args(2,1); // for cellevall {f, f_args}  
  octave_value_list f_return; // holder for feval returns

  int m, i, j, h, n, nacc, func_evals;
  int nup, nrej, nnew, ndown, lnobds;
  int converge, test;
	
  // user provided controls
  const Matrix lb (control(0).matrix_value());
  const Matrix ub (control(1).matrix_value());
  const int nt (control(2).int_value());
  const int ns (control(3).int_value());
  const double rt (control(4).double_value());
  const double maxevals (control(5).double_value());
  const int neps (control(6).int_value());
  const double functol (control(7).double_value());
  const double paramtol (control(8).double_value());
  const int verbosity (control(9).int_value());
  const int minarg (control(10).int_value());	
	
	
  double f, fp, p, pp, fopt, rand_draw, ratio, t;
  Matrix x  = f_args(minarg - 1).matrix_value();
  Matrix bounds = ub - lb;

  n = x.rows();
  Matrix xopt = x;
  Matrix xp(n, 1);
  Matrix nacp(n,1);
    
  //  Set initial values  
  nacc = 0;
  func_evals = 0;
	
  Matrix fstar(neps,1);  
  fstar.fill(1e20);
 
   
  // check for out-of-bounds starting value
  for(i = 0; i < n; i++)
    {
      if(( x(i) > ub(i)) || (x(i) < lb(i)))
    	{
	  error("samin: initial parameter %d out of bounds", i);
	  return octave_value_list();
    	}
    }	
 
  // Initial obj_value
  c_args(0) = obj_fn;
  c_args(1) = f_args;
  f_return = feval("celleval", c_args); 
  f = f_return(0).double_value(); 

  fopt = f;
  fstar(0) = f;

  // First stage: find initial temperature so that
  // bounds grow to cover parameter space
  t = 1000;
  converge = 0;    
  while((converge==0) & t < sqrt(DBL_MAX))
    {	
      nup = 0;
      nrej = 0;
      nnew = 0;
      ndown = 0;
      lnobds = 0;

      // repeat nt times then adjust temperature
      for(m = 0;m < nt;m++)
	{
	  // repeat ns times, then adjust bounds
	  for(j = 0;j < ns;j++)
	    {
	      // generate new point by taking last
	      // and adding a random value to each of elements,
	      // in turn
	      for(h = 0;h < n;h++)
		{
		  xp = x;
		  f_return = feval("rand");
		  rand_draw = f_return(0).double_value();
		  xp(h) = x(h) + (2.0 * rand_draw - 1.0) * bounds(h);
		  if((xp(h) < lb(h)) || (xp(h) > ub(h)))
		    {
		      xp(h) = lb(h) + (ub(h) - lb(h)) * rand_draw;
		      lnobds = lnobds + 1;
                    }  

		  // Evaluate function at new point
		  f_args(minarg - 1) = xp;
		  c_args(1) = f_args;
		  f_return = feval("celleval", c_args); 
		  fp = f_return(0).double_value();
		  func_evals = func_evals + 1;

                
		  /**  If too many function evaluations occur, terminate the algorithm. **/
                
		  if(func_evals >= maxevals)
		    {
		      warning("samin: NO CONVERGENCE: MAXEVALS exceeded before initial temparature found");
		      if(verbosity >= 1)
			{
			  printf("\n================================================\n");
			  printf("SAMIN results\n");
			  printf("NO CONVERGENCE: MAXEVALS exceeded\n");
			  printf("Stage 1, increasing temperature\n");
			  printf("\nObj. fn. value %f\n", fopt);
			  printf("           parameter        search width\n");
			  for(i = 0; i < n; i++)
			    {
			      printf("%20f%20f\n", xopt(i), bounds(i));
			    }
			  printf("================================================\n");
			} 
		      f_return(0) = xopt;
		      f_return(1) = fopt;
		      f_return(2) = 0;
		      return octave_value_list(f_return);
		    }
                
		  /**  Accept the new point if the function value decreases **/
                
		  if(fp <= f)
		    {
		      x = xp;
		      f = fp;
		      nacc = nacc + 1;
		      nacp(h) = nacp(h) + 1;
		      nup = nup + 1;
                    
		      /**  If greater than any other point, record as new optimum. **/
                    
		      if(fp < fopt)
			{
			  xopt = xp;
			  fopt = fp;
			  nnew = nnew + 1;
			}                   
		    }

		  // If the point is higher, use the Metropolis criteria to decide on
		  // acceptance or rejection.
		  else
		    {
		      p = exp(-(fp - f) / t);
		      f_return = feval("rand");
		      rand_draw = f_return(0).double_value();
		      if(rand_draw < p)
			{
			  x = xp;
			  f = fp;
			  nacc = nacc + 1;
			  nacp(h) = nacp(h) + 1;
			  ndown = ndown + 1;
			}
		      else
			{
			  nrej = nrej + 1;
			}
		    }                
		}
	    }
        
	  //  Adjust bounds so that approximately half of all evaluations are accepted. **/
	  test = 0;
	  for(i = 0;i < n;i++)
	    {
	      ratio = nacp(i) / ns;
	      if(ratio > 0.6)
		{
		  bounds(i) = bounds(i) * (1.0 + 2.0 * (ratio - 0.6) / 0.4);
		}
	      else if(ratio < .4)
		{
		  bounds(i) = bounds(i) / (1.0 + 2.0 * ((0.4 - ratio) / 0.4));
		}
	      // keep within initial bounds
	      if(bounds(i) >= (ub(i) - lb(i)))
		{
		  test = test + 1; // when this gets to n, we're done with fist stage
		  bounds(i) = ub(i) - lb(i);
		}
	    }
	  nacp.fill(0.0);
	  converge = (test == n);
	}
    
      if(verbosity == 1)
	{
	  printf("\nFirst stage: Increasing temperature to cover parameter space\n");
	  printf("\nTemperature  %e", t);
	  printf("\nmin function value so far %f", fopt);
	  printf("\ntotal evaluations so far %d", func_evals);
	  printf("\ntotal moves since temp change %d", nup + ndown + nrej);
	  printf("\ndownhill  %d", nup);
	  printf("\naccepted uphill %d", ndown);
	  printf("\nrejected uphill %d", nrej);
	  printf("\nout of bounds trials %d", lnobds);
	  printf("\nnew minima this temperature %d", nnew);
	  printf("\n\n           parameter        search width\n");
	  for(i = 0; i < n; i++)
	    {
	      printf("%20f%20f\n", xopt(i), bounds(i));
	    }
	  printf("\n");
	}
    
      // Increase temperature quickly
      t = t*t;
      for(i = neps-1; i > 0; i--)
	{
	  fstar(i) = fstar(i-1);
	}		
      f = fopt;
      x = xopt;
    }
	

	
  // Second stage: temperature reduction loop
  converge = 0;    
  while(converge==0)
    {
      nup = 0;
      nrej = 0;
      nnew = 0;
      ndown = 0;
      lnobds = 0;

      // repeat nt times then adjust temperature
      for(m = 0;m < nt;m++)
	{
	  // repeat ns times, then adjust bounds
	  for(j = 0;j < ns;j++)
	    {
	      // generate new point by taking last
	      // and adding a random value to each of elements,
	      // in turn
	      for(h = 0;h < n;h++)
		{
		  xp = x;
		  f_return = feval("rand");
		  rand_draw = f_return(0).double_value();
		  xp(h) = x(h) + (2.0 * rand_draw - 1.0) * bounds(h);
		  if((xp(h) < lb(h)) || (xp(h) > ub(h)))
		    {
		      xp(h) = lb(h) + (ub(h) - lb(h)) * rand_draw;
		      lnobds = lnobds + 1;
		    }
                 

		  // Evaluate function at new point
		  f_args(minarg - 1) = xp;
		  c_args(1) = f_args;
		  f_return = feval("celleval", c_args); 
		  fp = f_return(0).double_value();
		  func_evals = func_evals + 1;

                
		  /**  If too many function evaluations occur, terminate the algorithm. **/
                
		  if(func_evals >= maxevals)
		    {
		      warning("samin: NO CONVERGENCE: maxevals exceeded");
		      if(verbosity >= 1)
			{
			  printf("\n================================================\n");
			  printf("SAMIN results\n");
			  printf("NO CONVERGENCE: MAXEVALS exceeded\n");
			  printf("Stage 2, decreasing temperature\n");
			  printf("\nObj. fn. value %f\n", fopt);
			  printf("           parameter        search width\n");
			  for(i = 0; i < n; i++)
			    {
			      printf("%20f%20f\n", xopt(i), bounds(i));
			    }
			  printf("================================================\n");
			}						
		      f_return(0) = xopt;
		      f_return(1) = fopt;
		      f_return(2) = 0;
		      return octave_value_list(f_return);
		    }
                
		  /**  Accept the new point if the function value decreases **/
                
		  if(fp <= f)
		    {
		      x = xp;
		      f = fp;
		      nacc = nacc + 1;
		      nacp(h) = nacp(h) + 1;
		      nup = nup + 1;
                    
		      /**  If greater than any other point, record as new optimum. **/
                    
		      if(fp < fopt)
			{
			  xopt = xp;
			  fopt = fp;
			  nnew = nnew + 1;
			}                   
		    }

		  // If the point is higher, use the Metropolis criteria to decide on
		  // acceptance or rejection.
		  else
		    {
		      p = exp(-(fp - f) / t);
		      f_return = feval("rand");
		      rand_draw = f_return(0).double_value();
		      if(rand_draw < p)
			{
			  x = xp;
			  f = fp;
			  nacc = nacc + 1;
			  nacp(h) = nacp(h) + 1;
			  ndown = ndown + 1;
			}
		      else
			{
			  nrej = nrej + 1;
			}
		    }                
		}
	    }
        
	  //  Adjust bounds so that approximately half of all evaluations are accepted. **/
	  for(i = 0;i < n;i++)
	    {
	      ratio = nacp(i) / ns;
	      if(ratio > 0.6)
		{
		  bounds(i) = bounds(i) * (1.0 + 2.0 * (ratio - 0.6) / 0.4);
		}
	      else if(ratio < .4)
		{
		  bounds(i) = bounds(i) / (1.0 + 2.0 * ((0.4 - ratio) / 0.4));
		}
	      // keep within initial bounds
	      if(bounds(i) > (ub(i) - lb(i)))
		{
		  bounds(i) = ub(i) - lb(i);
		}
	    }
	  nacp.fill(0.0);
	}
    
      if(verbosity == 1)
	{
	  printf("\nIntermediate results before next temperature reduction\n");
	  printf("\nTemperature  %e", t);
	  printf("\nmin function value so far %f", fopt);
	  printf("\ntotal evaluations so far %d", func_evals);
	  printf("\ntotal moves since last temp reduction  %d", nup + ndown + nrej);
	  printf("\ndownhill  %d", nup);
	  printf("\naccepted uphill %d", ndown);
	  printf("\nrejected uphill %d", nrej);
	  printf("\nout of bounds trials %d", lnobds);
	  printf("\nnew minima this temperature %d", nnew);
	  printf("\n\n           parameter        search width\n");
	  for(i = 0; i < n; i++)
	    {
	      printf("%20f%20f\n", xopt(i), bounds(i));
	    }
	  printf("\n");
	}
    
      // Check for convergence
      // current function value must be within "tol"
      // of last "neps" (an integer) function values,
      // AND the last "neps" function values
      // must be withing tol of overall best
      fstar(0) = f;
      test = 0;
      for(i = 0; i < neps; i++)
	{
	  test = test + fabs(f - fstar(i)) > functol;
	}
      test = (test > 0); // if different from zero, function conv. has failed
      if( ((fopt - fstar(0)) <= functol) && (!test))
	{
	  // check for bound narrow enough for parameter convergence
	  converge = 1;
	  for(i = 0;i < n;i++)
	    {
	      if(bounds(i) > paramtol)
		{
		  converge = 0; // no conv. if bounds too wide
		  break;
		}	
	    }
	}

      // check if too close to bounds, and change convergence message if so
      if (converge) if (lnobds > 0) converge = 2;

      // Are we done yet?    
      if(converge>0)
	{
	  if(verbosity >= 1)
	    {
	      printf("\n================================================\n");
	      printf("SAMIN final results\n");
	      if (converge == 1) printf("NORMAL CONVERGENCE\n\n");
	      if (converge == 2)
		{
		  printf("WARNING: last point satisfies conv. criteria, \n\
						but is too close to bounds of parameter space\n");
		  printf("%f \% of last round evaluations out-of-bounds\n", 100*lnobds/(nup+ndown+nrej));
		  printf("Expand bounds and re-run\n\n");
		}
	      printf("Func. tol. %e   Param. tol. %e\n", functol, paramtol);
	      printf("Obj. fn. value %f\n\n", fopt);
	      printf("           parameter        search width\n");
	      for(i = 0; i < n; i++)
		{
		  printf("%20f%20f\n", xopt(i), bounds(i));
		}
	      printf("================================================\n");
	    }
	  f_return(0) = xopt;
	  f_return(1) = fopt;
	  if (lnobds > 0) converge = 2;
	  f_return(2) = converge;
	  return octave_value_list(f_return); 
	}
    
      // Reduce temperature, record current function value in the
      // list of last "neps" values, and loop again
      t = rt * t;
      for(i = neps-1; i > 0; i--)
	{
	  fstar(i) = fstar(i-1);
	}		
      f = fopt;
      x = xopt;
    }
  f_return(0) = xopt;
  f_return(1) = fopt;
  f_return(2) = converge;
  return octave_value_list(f_return);
}


/* Now that the temperature is low, here's a little joke :
   One polar bear to another, discussing igloos:
   "Man, I love these things - crunchy on the outside,
   chewy on the inside"
*/	



