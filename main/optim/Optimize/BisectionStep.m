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
 
#============================ BisectionStep =====================================
#
# this is used by BFGSMin
#
# Uses bisection to find a stepsize that leads to a decrease, then
# continues until no further improvement
# Michael Creel michael.creel@uab.es
# 13/01/2004
#
# usage:
#
# 	[a, obj_value] = BisectionStep(f, dx, args)
#
# inputs: 
#
#	f: the objective function
# 	dx: the direction
# 	args: the arguments of the function, in a cell array.
#		The first argument is the one w.r.t.
#		which we are minimizing.

function [a, obj] = BisectionStep(f, dx, args)

	if !iscell(args) args = {args}; endif
	x = args{1};
	args_in = args;

	obj_0 = feval(f, args);
	if iscell(obj_0) obj_0 = obj_0{1}; endif

	a = 1;

	# this first loop goes until an improvement is found
  	while a > 2*eps # limit iterations
		args{1} = x + a*dx;
		obj = feval(f, args);
		if iscell(obj) obj = obj{1}; endif

		if (obj > obj_0) || isnan(obj)  # reduce stepsize if worse, or if function can't be evaluated
			a = 0.5 * a;
		else
			obj_0 = obj;
			break;
		endif
	endwhile
	
	# now keep going until we no longer improve, or reach max trials
	while a > 2*eps

	   	a = 0.5*a; 
		args{1} = x + a*dx;
		obj = feval(f, args);
		if iscell(obj) obj = obj{1}; endif
	
		# if improved, record new best and try another step
		if ((obj < obj_0) & !isnan(obj))
			obj_0 = obj;
		else 
			a = a / 0.5; # put it back to best found
			break;
		endif;				
	endwhile
	obj = obj_0;
endfunction
#============================ end BisectionStep =====================================
