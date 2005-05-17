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

// numgradient: numeric central difference gradient

#include <oct.h>
#include <octave/parse.h>
#include <octave/lo-mappers.h>
#include <octave/Cell.h>

// argument checks
static bool
any_bad_argument(const octave_value_list& args)
{
	if (!args(0).is_string())
	{
		error("numgradient: first argument must be string holding objective function name");
		return true;
	}
	
	if (!args(1).is_cell())
	{
		error("numgradient: second argument must cell array of function arguments");
		return true;
	}
	
	// minarg, if provided
	if (args.length() == 3)
	{
		int tmp = args(2).int_value();
		if (error_state)
		{
			error("numgradient: 3rd argument, if supplied,  must an integer\n\
that specifies the argument wrt which differentiation is done");
			return true;
		}
		if ((tmp > args(1).length())||(tmp < 1))
		{
			error("numgradient: 3rd argument must be a positive integer that indicates \n\
which of the elements of the second argument is the\n\
one to differentiate with respect to");
			return true;
		}
	}
	return false;
}


DEFUN_DLD(numgradient, args, , "numgradient(f, {args}, minarg)\n\
\n\
Numeric central difference gradient of f with respect\n\
to argument \"minarg\".\n\
* first argument: function name (string)\n\
* second argument: all arguments of the function (cell array)\n\
* third argument: (optional) the argument to differentiate w.r.t.\n\
	(scalar, default=1)\n\
\n\
\"f\" may be vector-valued. If \"f\" returns\n\
an n-vector, and the argument is a k-vector, the gradient\n\
will be an nxk matrix\n\
\n\
Example:\n\
function a = f(x);\n\
	a = [x'*x; 2*x];\n\
endfunction\n\
numgradient(\"f\", {ones(2,1)})\n\
ans =\n\
\n\
  2.00000  2.00000\n\
  2.00000  0.00000\n\
  0.00000  2.00000\n\
")
{
	int nargin = args.length();
	if (!((nargin == 2)|| (nargin == 3)))
	{
		error("numgradient: you must supply 2 or 3 arguments");
		return octave_value_list();
	}

	// check the arguments
	if (any_bad_argument(args)) return octave_value_list();
	
	std::string f (args(0).string_value());
	Cell f_args (args(1).cell_value());
	octave_value_list c_args(2,1); // for cellevall {f, f_args}
	c_args(0) = f;
	c_args(1) = f_args;
	octave_value_list fdiff_args(2,1);
	octave_value_list f_return;
	Matrix obj_value, obj_left, obj_right;
	double p, d, delta, delta_right, delta_left;
	int i, j, minarg;

	// Default values for controls
	minarg = 1; // by default, first arg is one over which we minimize
	
	// possibly minimization not over 1st arg
	if (args.length() == 3) minarg = args(2).int_value();
	Matrix parameter = f_args(minarg - 1).matrix_value();
	
	// initial function value
	f_return = feval("celleval", c_args);
	obj_value = f_return(0).matrix_value();
	
	const int n = obj_value.rows(); // find out dimension
	const int k = parameter.rows();
	Matrix derivative(n, k);
	Matrix columnj;
	
	for (j=0; j<k; j++) // get 1st derivative by central difference
	{
		p = parameter(j);
		fdiff_args(0) = p;
		fdiff_args(1) = 1;
		f_return = feval("finitedifference", fdiff_args);
		delta = f_return(0).double_value();
		
		// right side
		parameter(j) = d = p + delta;
		delta_right = d - p;
		f_args(minarg - 1) = parameter;
		c_args(1) = f_args;
		f_return = feval("celleval", c_args);
		obj_right = f_return(0).matrix_value();
		
		// left size
		d = p - delta;
		parameter(j) = d;
		delta_left = p - d;
		f_args(minarg - 1) = parameter;
		c_args(1) = f_args;
		f_return = feval("celleval", c_args);
		obj_left = f_return(0).matrix_value();
		
		parameter(j) = p;  // restore original parameter
		columnj = (obj_right - obj_left) / (delta_right + delta_left);
		for (i=0; i<n; i++) derivative(i, j) = columnj(i);
	}

	return octave_value(derivative);
}
