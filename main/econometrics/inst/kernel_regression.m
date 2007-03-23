# Copyright (C) 2006 Michael Creel <michael.creel@uab.es>
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
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

# kernel_regression: kernel regression estimator
#
# usage:
# 	fit = kernel_regression(eval_points, depvar, condvars, bandwidth)
#
# inputs:
#	eval_points: PxK matrix of points at which to calculate the density
#	dev_var: Nx1 vector of observations of the dependent variable
# 	condvars: NxK matrix. N observations on the K conditioning variables.
#	bandwidth: positive scalar, the smoothing parameter. The fit
# 		is more smooth as the bandwidth increases.
#	do_cv: bool (optional). default false. If true, calculate leave-1-out
#		density for cross validation
#	nslaves: int (optional, default 0). Number of compute nodes for parallel evaluation
#	debug: bool (optional, default false). show results on compute nodes if doing
#		 parallel run
#	bandwith_matrix (optional): nonsingular KxK matrix. Rotates data.
# 		Default is Choleski decomposition of inverse of covariance,
#		to approximate independence after the transformation, which
#		makes a product kernel a reasonable choice.
#	kernel (optional): string. Name of the kernel function. Default is radial
#		symmetric Epanechnikov kernel.
# outputs:
#	fit: Px1 vector: the fitted value at each of the P evaluation points.
#

function z = kernel_regression(eval_points, depvar, condvars, bandwidth, do_cv, nslaves, debug, bandwith_matrix, kernel)

	if nargin < 4; error("kernel_regression: at least 4 arguments are required"); endif

	# set defaults for optional args
	# default ordinary density, not leave-1-out
	if (nargin < 5)	do_cv = false; endif
	# default serial
	if (nargin < 6)	nslaves = 0; endif
	# debug or not (default)
	if (nargin < 7)	debug = false; endif;
	# default bandwidth matrix (up to factor of proportionality)
	if (nargin < 8) bandwidth_matrix = chol(cov(condvars)); endif # default bandwidth matrix
	# default kernel
	if (nargin < 9) kernel = "__kernel_epanechnikov"; endif 	# default kernel

	nn = rows(eval_points);
	n = rows(depvar);

	# Inverse bandwidth matrix H_inv
	H = bandwidth_matrix*bandwidth;
	H_inv = inv(H);

	# weight by inverse bandwidth matrix
	eval_points = eval_points*H_inv;
	condvars = condvars*H_inv;

	data = [depvar condvars]; # put it all together for sending to nodes

	# check if doing this parallel or serial
	global PARALLEL NSLAVES NEWORLD NSLAVES TAG
	PARALLEL = 0;

	if nslaves > 0
		PARALLEL = 1;
		NSLAVES = nslaves;
		LAM_Init(nslaves, debug);
	endif

	if !PARALLEL # ordinary serial version
		points_per_node = nn; # do the all on this node
		z = kernel_regression_nodes(eval_points, data, do_cv, kernel, points_per_node, nslaves, debug);
	else # parallel version
		z = zeros(nn,1);
		points_per_node = floor(nn/(NSLAVES + 1)); # number of obsns per slave
		# The command that the slave nodes will execute
		cmd=['z_on_node = kernel_regression_nodes(eval_points, data, do_cv, kernel, points_per_node, nslaves, debug); ',...
		'MPI_Send(z_on_node, 0, TAG, NEWORLD);'];

		# send items to slaves

		NumCmds_Send({"eval_points", "data", "do_cv", "kernel", "points_per_node", "nslaves", "debug","cmd"}, {eval_points, data, do_cv, kernel, points_per_node, nslaves, debug, cmd});

		# evaluate last block on master while slaves are busy
		z_on_node = kernel_regression_nodes(eval_points, data, do_cv, kernel, points_per_node, nslaves, debug);
		startblock = NSLAVES*points_per_node + 1;
		endblock = nn;
		z(startblock:endblock,:) = z(startblock:endblock,:) + z_on_node;

		# collect slaves' results
		z_on_node = zeros(points_per_node,1); # size may differ between master and compute nodes - reset here
		for i = 1:NSLAVES
			MPI_Recv(z_on_node,i,TAG,NEWORLD);
			startblock = i*points_per_node - points_per_node + 1;
			endblock = i*points_per_node;
			z(startblock:endblock,:) = z(startblock:endblock,:) + z_on_node;
		endfor

		# clean up after parallel
		LAM_Finalize;
	endif
endfunction
