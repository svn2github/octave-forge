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

// bisection step, for use by minimization algorithms
// 
// returns optimal stepsize using bisection - first until an improvement
// is found, then until there is no further improvement
//
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

DEFUN_DLD(bisectionstep, args, , "bisectionstep.cc")
{
   	std::string f (args(0).string_value());
	Cell f_args (args(1).cell_value());
	ColumnVector dx (args(2).column_vector_value());

	double obj_0, obj, a;
	octave_value_list f_return;
	octave_value_list c_args(2,1); // for cellevall {f, f_args}  

	octave_value_list stepobj(2,1);
	int minarg, found_improvement;

	// Default values for controls
	minarg = 1; // by default, first arg is one over which we minimize

 	// possibly minimization not over 1st arg
	if (args.length() == 4)
	{
		minarg = args(3).int_value();
	}	
 
	ColumnVector x (f_args(minarg - 1).column_vector_value());
	ColumnVector x_in = x;
	

	// possibly function returns a cell array
	// obj. value will be in first position
	c_args(0) = f;
	c_args(1) = f_args;
	f_return = feval("celleval", c_args); 
	obj_0 = f_return(0).double_value();

	a = 1.0;
	found_improvement = 0;
	// this first loop goes until an improvement is found
  	while (a > 2*DBL_EPSILON) // limit iterations
	{
		f_args(minarg - 1) = x + a*dx;
		c_args(1) = f_args;
		f_return = feval("celleval", c_args); 
		obj = f_return(0).double_value();
 
 		// reduce stepsize if worse, or if function can't be evaluated
		if ((obj >= obj_0) || lo_ieee_isnan(obj))
		{
			a = 0.5 * a;
		}	
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
		stepobj(0) = 0.0;
		stepobj(1) = obj_0;
		return octave_value_list(stepobj);
	}	
	
	// now keep going until we no longer improve, or reach max trials
	while (a > 2*DBL_EPSILON)
	{
	   	a = 0.5*a; 
		f_args(minarg - 1) = x + a*dx;
		c_args(1) = f_args;
		f_return = feval("celleval", c_args); 
		obj = f_return(0).double_value();
 
		// if improved, record new best and try another step
		if ((obj < obj_0) & !lo_ieee_isnan(obj))
		{
			obj_0 = obj;
		}	
		else
		{
			a = a / 0.5; // put it back to best found
			break;
		}				
	}

	stepobj(0) = a;
	stepobj(1) = obj_0;
	return octave_value_list(stepobj);
}
