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
 
# func: function to mimimize
# args: args of function - first is arg we min w.r.t.
# startvals: kxp matrix of values to try for sure (don't include all zeros, that's automatic)
# max iters per start value
# number of additional random start values to try
		 
function theta = Battery(func, args, startvals, maxiters)

# setup
[k,trials] = size(startvals);
bestobj = inf;
besttheta = zeros(k,1);
bfgscontrol = [maxiters;0;1;1];
# now try the supplied start values, and optionally the random start values
for i = 1:trials
	args{1} = startvals(:,i);
	[theta, obj_value, iters, convergence] = BFGSMin (func, args, bfgscontrol);
	
	if obj_value < bestobj
		besttheta = theta;
		bestobj = obj_value;
	endif
endfor
	
theta = besttheta;
endfunction
