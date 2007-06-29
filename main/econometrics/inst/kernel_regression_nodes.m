# Copyright (C) 2006, 2007  Michael Creel <michael.creel@uab.es>
# under the terms of the GNU General Public License.
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

# kernel_regression_nodes: for internal use by kernel_regression - does calculations on nodes

function z = kernel_regression_nodes(eval_points, data, do_cv, kernel, points_per_node, nslaves, debug)

	if (nslaves > 0)
		global NEWORLD
		[info, myrank] = MPI_Comm_rank(NEWORLD);
	else myrank = 0; # if not parallel then do all on master node
	endif

	if myrank == 0 # Do this if I'm master
		startblock = nslaves*points_per_node + 1;
		endblock = rows(eval_points);
	else	# this is for the slaves
		startblock = myrank*points_per_node - points_per_node + 1;
		endblock = myrank*points_per_node;
	endif

	# the block of eval_points this node does
	myeval = eval_points(startblock:endblock,:);
	nn = rows(myeval);
	n = rows(data);

	y = data(:,1);
	data = data(:,2:columns(data));
	W = __kernel_weights(data, myeval, kernel);

	# drop own weight for CV
	if (do_cv) W = W - diag(diag(W)); endif


	W = W ./ (eps + repmat(sum(W,2),1,n)); # add eps to denominator to avoid crashes
	z = W*y;

	if debug
		printf("z on node %d: \n", myrank);
		z'
	endif
endfunction


