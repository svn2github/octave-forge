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

# GMM example file, shows initial consistent estimator,
# estimation of efficient weight, and second round
# efficient estimator 

# This also shows how do use data scaling - WHICH YOU SHOULD DO!
1;


# the form a user-written moment function should take
function m = mymoments(theta, data, momentargs)
	k = momentargs{1}; # use this so that data can hold dep, indeps, and instr
	y = data(:,1);
	x = data(:,2:k+1);
	w = data(:, k+2:columns(data));
	lambda = exp(x*theta);
	e = y ./ lambda - 1;
	m = dmult(e, w);
endfunction	

n = 1000;
k = 5;

x = [ones(n,1) rand(n,k-1)];
w = [x, rand(n,1)];
theta = ones(k,1);
lambda = exp(x*theta);
y = randp(lambda);
[xs, scalecoef] = scale_data(x);


# The arguments for gmm_estimate
theta = zeros(k,1);
data = [y xs w];
weight = eye(columns(w));
moments = "mymoments";
momentargs = {k}; # needed to know where x ends and w starts

# additional args for gmm_results
names = str2mat("theta1", "theta2", "theta3", "theta4", "theta5");
title = "Poisson GMM trial";
control = {100,0,1,1};


# initial consistent estimate: only used to get efficient weight matrix, no screen output
[theta, obj_value, convergence] = gmm_estimate(theta, data, weight, moments, momentargs);

# efficient weight matrix
# this method is valid when moments are not autocorrelated
# the user is reponsible to properly estimate the efficient weight
m = feval(moments, theta, data, momentargs);
weight = inverse(cov(m));

# second round efficient estimator
gmm_results(theta, data, weight, moments, momentargs, names, title, scalecoef, control);

