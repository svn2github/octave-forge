## Copyright (C) 2003,2004,2005  Michael Creel <michael.creel@uab.es>
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
## along with this program; if not, write to the Free Software
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

function contrib = mle_obj_nodes(theta, data, model, modelargs, nn)
  global NEWORLD NSLAVES
	
	# Who am I?
	[info, rank] = MPI_Comm_rank(NEWORLD); 
	if rank == 0 # Do this if I'm master
		startblock = NSLAVES*nn + 1;
		endblock = rows(data);
	else	# this is for the slaves
		startblock = rank*nn-nn+1;
		endblock = rank*nn;
	endif	

	data = data(startblock:endblock,:);
  contrib = feval(model, theta, data, modelargs);
	contrib = sum(contrib);

endfunction
