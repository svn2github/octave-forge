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


# montecarlo.m: generates a specified number of replications of a
# function's output and displays them on screen. At the moment,
# this is a toy implementation that serves only as an example
# Compare to montecarlo.m in the econometrics package, which
# uses MPITB
#
# USAGE: montecarlo_basic(f, f_args, reps)
#
# IMPORTANT: f should return a row vector of output from feval(f,f_args)
#
# * Arg 1: (required) the function that generates a row vector of output
# * Arg 2: (required) the arguments of the function, in a cell
# * Arg 3: (required) the number of replications to generate
function output = montecarlo_basic(f, args, reps)


	MPI_Init();
	# the string NEWORLD is just a label could be whater you want    
        CW = MPI_Comm_Load("NEWORLD");


	my_rank = MPI_Comm_rank(CW);
	nodes = MPI_Comm_size(CW);
	# Could be any number
	mytag = 48;

	if (my_rank != 0) # the compute nodes
		to_do = floor(reps/nodes);
		for i = 1:to_do
			contrib = feval(f, args);
			if (i == 1) contribs = zeros(to_do,columns(contrib)); endif
			contribs(i,:) = contrib;
		endfor
		contribs = [ones(to_do,1)*my_rank contribs]; # add in identification
		[info] = MPI_Send(contribs,0,mytag,CW);
	else 	# work for the frontend
		to_do = floor(reps/nodes);
		contrib = feval(f, args); # find out size of return
		cols = columns(contrib);
		results = zeros(reps, cols+1); # make the container
		start = reps - (nodes - 1)*to_do + 1; # frontend writes last results
		results(start,:) = [0 contrib];
		for i = (start + 1):reps
			contrib = feval(f, args);
			results(i,:) = [0 contrib];
		endfor

		# now collect the results fron the nodes
		for node = 1:nodes-1
			[contribs, info] = MPI_Recv(node,mytag,CW);
			results(node*to_do - to_do + 1: node*to_do, :) = contribs;
		endfor

		disp(results);

	end

	MPI_Finalize();

endfunction