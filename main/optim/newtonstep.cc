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

// newton step, for use by minimization algorithms
// since this is not for use by end-users, its documentation
// is a bit short. See bfgsmin for an example of use
// args are
// f: string: function name
// f_args: cell array: arguments of function
// dx: vector: the direction of search
// minarg: integer: (optional) the arg we are minimizing w.r.t.
#include <oct.h>
#include <octave/parse.h>
#include <octave/Cell.h>
#include <octave/lo-ieee.h>
#include <float.h>

DEFUN_DLD(newtonstep, args, , "newtonstep.cc - for internal use by bfgsmin and related functions")
{
  
	
  int nargin = args.length ();
  if (nargin < 3)
    {
      error("newtonstep: you must supply at least 3 arguments");
      return octave_value_list();
    }
	
  if (nargin > 4)
    {
      error("bisectionstep: you must supply at most 4 arguments");
      return octave_value_list();
    }

	
  std::string f (args(0).string_value());
  Cell f_args (args(1).cell_value());
  Matrix dx (args(2).matrix_value());


  double obj, obj_0, obj_left, obj_right, delta, a, gradient, hessian;
  octave_value_list f_return;
  octave_value_list c_args(2,1); // for cellevall {f, f_args}  
  octave_value_list stepobj(2,1);
  int minarg;
	
  // Default values for controls
  minarg = 1; // by default, first arg is one over which we minimize
 
  // possibly minimization not over 1st arg
  if (args.length() == 4)
    {
      minarg = args(3).int_value();
    }	

  Matrix x (f_args(minarg - 1).matrix_value());
  Matrix x_in = x;
	
  gradient = 1.0;
	
  // possibly function return cell array
  // obj. value will be in first position
  c_args(0) = f;
  c_args(1) = f_args;
  f_return = feval("celleval", c_args); 
  obj = f_return(0).double_value();

  obj_0 = obj;
	
  delta = 0.001; // experimentation show that this is a good choice
	
  Matrix x_right = x + delta*dx;
  Matrix x_left = x  - delta*dx;

  // possibly function return cell array
  // obj. value will be in first position
  f_args(minarg - 1) = x_right;
  c_args(1) = f_args;
  f_return = feval("celleval", c_args); 
  obj_right = f_return(0).double_value();
	
  f_args(minarg - 1) = x_left;
  c_args(1) = f_args;
  f_return = feval("celleval", c_args); 
  obj_left = f_return(0).double_value();
	

  gradient = (obj_right - obj_left) / (2*delta);  // take central difference
  hessian =  (obj_right - 2*obj + obj_left) / pow(delta, 2.0);	
  hessian = fabs(hessian); // ensures we're going in a decreasing direction
  if (hessian <= 2*DBL_EPSILON) hessian = 1.0; // avoid div by zero

  a = - gradient / hessian;  // hessian inverse gradient: the Newton step

  if (a < 0) 	// since direction is descending, a must be positive
    { 			// if it is not, go to bisection step
      f_return = feval("bisectionstep", args);
      a = f_return(0).double_value();
      obj = f_return(1).double_value();
      stepobj(0) = a;
      stepobj(1) = obj;
      return octave_value_list(stepobj);
    }

  a = (a < 5.0)*a + 5.0*(a>=5.0); // Let's avoid extreme steps that might cause crashes

  // ensure that this is improvement
  f_args(minarg - 1) = x + a*dx;
  c_args(1) = f_args;
  f_return = feval("celleval", c_args); 
  obj = f_return(0).double_value();

  // if not, fall back to bisection
  if ((obj > obj_0) || lo_ieee_isnan(obj))
    {
      f_return = feval("bisectionstep", args);
      a = f_return(0).double_value();
      obj = f_return(1).double_value();
    }
	
  stepobj(0) = a;
  stepobj(1) = obj;
  return octave_value_list(stepobj);
}
