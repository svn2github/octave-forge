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

// numhessian: numeric second derivative

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
    error("numhessian: first argument must be string holding objective function name");
    return true;
  }

  if (!args(1).is_cell())
  {
    error("numhessian: second argument must cell array of function arguments");
    return true;
  }

	// minarg, if provided
  if (args.length() == 3)
  {
 		int tmp = args(2).int_value();
		if (error_state)
		{
			error("numhessian: 3rd argument, if supplied,  must an integer\n\
that specifies the argument wrt which differentiation is done");
			return true;
		}
		if ((tmp > args(1).length())||(tmp < 1))  
		{
			error("numhessian: 3rd argument must be a positive integer that indicates \n\
which of the elements of the second argument is the one to differentiate with respect to");
			return true;
		}
  }	
  return false;
}


DEFUN_DLD(numhessian, args, ,
	  "numhessian(f, {args}, minarg)\n\
\n\
Numeric second derivative of f with respect\n\
to argument \"minarg\".\n\
* first argument: function name (string)\n\
* second argument: all arguments of the function (cell array)\n\
* third argument: (optional) the argument to differentiate w.r.t.\n\
	(scalar, default=1)\n\
\n\
If the argument\n\
is a k-vector, the Hessian will be a kxk matrix\n\
\n\
function a = f(x, y)\n\
	a = x'*x + log(y);\n\
endfunction\n\
\n\
numhessian(\"f\", {ones(2,1), 1})\n\
ans =\n\
\n\
    2.0000e+00   -7.4507e-09\n\
   -7.4507e-09    2.0000e+00\n\
\n\
Now, w.r.t. second argument:\n\
numhessian(\"f\", {ones(2,1), 1}, 2)\n\
ans = -1.0000\n\
")
{
  int nargin = args.length();

  if (!((nargin == 2)|| (nargin == 3)))
    {
      error("numhessian: you must supply 2 or 3 arguments");
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

  int i, j, minarg;
  double di, hi, pi, dj, hj, pj, hia;
  double hja, fpp, fmm, fmp, fpm, obj_value;


  // Default values for controls
  minarg = 1; // by default, first arg is one over which we minimize
 
  // possibly minimization not over 1st arg
  if (args.length() == 3)
    {
      minarg = args(2).int_value();
    }	

  Matrix parameter = f_args(minarg - 1).matrix_value();

  const int k = parameter.rows();
  Matrix derivative(k, k);
 	
  f_return = feval("celleval", c_args); 
  obj_value = f_return(0).double_value();
 
  for (i = 0; i<k;i++)	// approximate 2nd deriv. by central difference 
    {
      pi = parameter(i);
      fdiff_args(minarg - 1) = pi;
      fdiff_args(1) = 2;
      f_return = feval("finitedifference", fdiff_args);
      hi = f_return(0).double_value();
      for (j = 0; j < i; j++) // off-diagonal elements
	{
	  pj = parameter(j);
	  fdiff_args(minarg - 1) = pj;
	  fdiff_args(1) = 2;
	  f_return = feval("finitedifference", fdiff_args);
	  hj = f_return(0).double_value();
	
	  // +1 +1
	  parameter(i) = di = pi + hi;
	  parameter(j) = dj = pj + hj; 
	  hia = di - pi;
	  hja = dj - pj;
	  f_args(minarg - 1) = parameter;
	  c_args(1) = f_args;
	  f_return = feval("celleval", c_args);
	  fpp = f_return(0).double_value();

	  // -1 -1
	  parameter(i) = di = pi - hi;
	  parameter(j) = dj = pj - hj; 
	  hia = hia + pi - di;
	  hja = hja + pj - dj;
	  f_args(minarg - 1) = parameter;
	  c_args(1) = f_args;
	  f_return = feval("celleval", c_args);
	  fmm = f_return(0).double_value();
			
	  // +1 -1
	  parameter(i) = pi + hi;
	  parameter(j) = pj - hj;
	  f_args(minarg - 1) = parameter;
	  c_args(1) = f_args;
	  f_return = feval("celleval", c_args);
	  fpm = f_return(0).double_value();

	  // -1 +1 
	  parameter(i) = pi - hi;
	  parameter(j) = pj + hj;
	  f_args(minarg - 1) = parameter;
	  c_args(1) = f_args;
	  f_return = feval("celleval", c_args);
	  fmp = f_return(0).double_value();

	  derivative(j,i) = ((fpp - fpm) + (fmm - fmp)) / (hia * hja);
	  derivative(i,j) = derivative(j,i);

	  parameter(j) = pj;
	}

      // diagonal elements
      // +1 +1  
      parameter(i) = di = pi + 2 * hi;
      f_args(minarg - 1) = parameter;
      c_args(1) = f_args;
      f_return = feval("celleval", c_args);
      fpp = f_return(0).double_value();

      hia = (di - pi) / 2;

      // -1 -1 
      parameter(i) = di = pi - 2 * hi;
      f_args(minarg - 1) = parameter;
      c_args(1) = f_args;
      f_return = feval("celleval", c_args);
      fmm = f_return(0).double_value();
      hia = hia + (pi - di) / 2;

      derivative(i,i) = ((fpp - obj_value) + (fmm - obj_value)) / (hia * hia);

      parameter(i) = pi;
    }

  return octave_value(derivative);
}
