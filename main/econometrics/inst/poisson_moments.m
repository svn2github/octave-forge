# Copyright (C) 2005  Michael Creel <michael.creel@uab.es>
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
 
# the form a user-written moment function should take

function m = poisson_moments(theta, data, momentargs)
	k = momentargs{1}; # use this so that data can hold dep, indeps, and instr
	y = data(:,1);
	x = data(:,2:k+1);
	w = data(:, k+2:columns(data));
	lambda = exp(x*theta);
	e = y ./ lambda - 1;
	m = dmult(e, w);
endfunction	
