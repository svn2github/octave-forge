# Copyright (C) 2003  Michael Creel michael.creel@uab.es
# under the terms of the GNU General Public License.
# The GPL license is in the file COPYING
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
#============================ NewtonStep =====================================
#
# this is for use by BFGSMin
#
# Uses a Newton interation to attempt to find a good stepsize
# falls back to BisectionStep if no improvement found
# Michael Creel michael.creel@uab.es
# 13/01/2004
#
# usage:
# 		[a, obj_value] = NewtonStep(f, dx, args)
# inputs: 
#		f: the objective function
# 		dx: the direction
# 		args: the arguments of the function, in a cell array.
#			The first argument is the one w.r.t.
#			which we are minimizing.

function [a, obj] = NewtonStep(f, dx, args)

	if !iscell(args) args = {args}; endif
	x = args{1};
	args_in = args;
	
	gradient = 1;
	evaluations = 0;
	obj_0 = obj = feval(f, args);
		
	delta = 0.001; # experimentation show that this is a good choice
	
	x_right = x + delta*dx;
	x_left = x  - delta*dx;
	
	args{1} = x_right;
	obj_right = feval(f, args);
	args{1} = x_left;
	obj_left = feval(f, args);

  	gradient = (obj_right - obj_left) / (2*delta);  # take central difference
  	hessian = (obj_right - 2*obj + obj_left) / (delta^2);	
	hessian = abs(hessian); # ensures we're going in a decreasing direction
	if hessian <= eps, hessian = 1; endif # avoid div by zero

	a = - gradient/hessian;  # hessian inverse gradient: the Newton step

	# check that this is improvement
	args{1} = x+a*dx;
	obj = feval(f, args);
	# if not, fall back to bisection
	if ((obj > obj_0) || isnan(obj))
		[a, obj] = BisectionStep(f, dx, args_in);
	endif

endfunction


#============================ end NewtonStep =====================================
