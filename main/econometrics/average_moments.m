## Copyright (C) 2003  Michael Creel michael.creel@uab.es
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.

# average moments (separate function so it can be differentiated)

function m = average_moments(theta, data, moments, momentargs)
	m = feval(moments, theta, data, momentargs);
	m = mean(m)';  # returns Gx1 moment vector
endfunction
