## Copyright (C) 2009  Michael Cree <michael.creel@uab.es>
## under the terms of the GNU General Public License.
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; If not, see <http://www.gnu.org/licenses/>.


# mc_example: shows how Monte Carlo can be done using mpi, Does Monte
# Carlo on the OLS estimator. Uses montecarlo.m
#
# USAGE: from the command prompt, not the octave prompt, execute
# orterun -np 3 octave --eval mc_example

1;
addpath("../src");
function betahat = olswrapper(args)
	n = args{1};
	theta = args{2};
	x = [ones(n,1) randn(n,1)];
	y = x*theta + randn(n,1);
	betahat = ols(y,x);
  	betahat = betahat';
endfunction


n = 30;
theta = [1;1];

reps = 100;
f = "olswrapper";
args = {n, theta};
outfile = "mc_output";
n_pooled = 10;


#montecarlo(f, args, reps, outfile, n_pooled, false, true);

montecarlo(f, args, reps, outfile, n_pooled, true, true);