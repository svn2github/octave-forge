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
 
#============================ QuadInterpStep =====================================
#
# this is for use by BFGSMin, though by default NewtonStep is used
#
# Uses quadratic interpolation to attempt to find a good stepsize
# falls back to BisectionStep if no improvement found
# Michael Creel michael.creel@uab.es
# 13/01/2004
#
# usage:
# 		[a, obj_value] = QuadInterpStep(f, dx, args)
# inputs: 
#		f: the objective function
# 		dx: the direction
# 		args: the arguments of the function, in a cell array.
#			The first argument is the one w.r.t.
#			which we are minimizing.

function [a, obj] = QuadInterpStep(f, dx, args)

	if !iscell(args) args = {args}; endif
	x = args{1};
	args_in = args;

	evaluations = 0;
	obj_0 = feval(f, args);
	
 	left = 0.1;
	right = 3;
	center = 1;

	args{1} = x + left*dx;
	obj_left = feval(f, args);
	args{1} = x + center*dx;
	obj_center = feval(f, args);
	args{1} = x + right*dx;
	obj_right = feval(f, args);

	# Best is on L extreme
	if (obj_left < obj_center) & (obj_left < obj_right)
		obj = obj_left;
		a = left;

	# Best is on R extreme
	elseif (obj_right < obj_center) & (obj_right < obj_left)
		obj = obj_right;
		a = right;
	# Best is in middle - do interp
	else
		a = obj_left*(center^2 - right^2) + obj_center*(right^2 - left^2) + obj_right*(left^2 - center^2);
		a = 0.5 * a / (obj_left*(center - right) + obj_center*(right - left) + obj_right*(left - center));	
		args{1} = x + a*dx;
		obj = feval(f, args);
	endif

	# fall back to bisection if this is not improvement or there is some sort of crash
	if ((obj > obj_0) || (!isreal(obj)) || (!isreal(a))) [a, obj] = BisectionStep(f, dx, args_in); endif
	
endfunction

#============================ end QuadInterpStep =====================================
