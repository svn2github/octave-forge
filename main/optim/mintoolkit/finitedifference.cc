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

// ========================= finitedifference ==========================
//  finite differences for numeric differentiation
#include <oct.h>
#include <float.h>
DEFUN_DLD(finitedifference, args, ,"finitedifference, C++ version\n\
differences for numgradient and numhessian")
{
    double x = args(0).double_value();
    int order = args(1).int_value();
	int test;
	double eps, SQRT_EPS, DIFF_EPS, DIFF_EPS1, DIFF_EPS2, diff, d;

	eps = DBL_EPSILON; // machine precision
	SQRT_EPS = sqrt(eps); 
	DIFF_EPS = exp(log(eps)/2);
	DIFF_EPS1 = exp(log(eps)/3);
	DIFF_EPS2 = exp(log(eps)/4);
	if (order == 0) diff = DIFF_EPS;
	else if (order == 1) diff = DIFF_EPS1;
	else diff = DIFF_EPS2;

	test = (fabs(x) + SQRT_EPS) * SQRT_EPS > diff;
	
	if (test)
	{
		d = (fabs(x) + SQRT_EPS) * SQRT_EPS;
	}
	else
	{
		d = diff;
	}		

	return octave_value(d);
}
