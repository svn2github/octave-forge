# Copyright (C) 2003,2004  Michael Creel michael.creel@uab.es
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

# Computes Delta method mean and covariance of a nonlinear
# transformation defined by "func"
function [theta_transf, vartheta] = delta_method(func, theta, otherargs, vartheta)
	theta_transf = feval(func, theta, otherargs); 
	D = numgradient(func, {theta, otherargs});

	var_transf = D * vartheta * D';

endfunction
