## Copyright (C) 2009 Riccardo Corradini <riccardocorradini@yahoo.it>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

# mc_example: shows how Monte Carlo can be done using mpi, Does Monte
# Carlo on the OLS estimator. Uses montecarlo.m
#
# USAGE: from the command prompt, not the octave prompt, execute
# orterun -np 3 octave --eval mc_example

1;
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

reps = 1000;
f = "olswrapper";
args = {n, theta};
outfile = "mc_output";
n_pooled = 10;
verbose = true;

# montecarlo(f, args, reps, outfile, n_pooled, false, verbose);

if not(MPI_Initialized) MPI_Init; endif
montecarlo(f, args, reps, outfile, n_pooled, verbose);
if not(MPI_Finalized) MPI_Finalize; endif
