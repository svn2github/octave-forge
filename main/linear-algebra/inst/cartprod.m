## Copyright (C) 2008 Muthiah Annamalai <muthiah.annamalai@uta.edu>
## 
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; If not, see <http://www.gnu.org/licenses/>.
##

## -*- texinfo -*-
## @deftypefn {Function File} {} cartprod (@var{varargin} )
##
## Computes the cartesian product of given column vectors ( row vectors ).
## The vector elements are assumend to be numbers.
##
## Alternatively the vectors can be specified by as a matrix, by its columns.
##
## To calculate the cartesian product of vectors,
## P = A x B x C x D ... . Requires A, B, C, D be column vectors.
## The algorithm is iteratively calcualte the products,
##  ( ( (A x B ) x C ) x D ) x  etc.
##
## @example
## @group
##   cartprod(1:2,3:4,0:1)
##   ans =   1   3   0
##           2   3   0
##           1   4   0
##           2   4   0
##           1   3   1
##           2   3   1
##           1   4   1
##           2   4   1
## @end group
## @end example
## @end deftypefn
## @seealso{kron}


function P = cartprod( varargin )
     if ( nargin < 1 )
  	     error('usage: cartprod(A,B,C, ... )')
     end
      
     %% kludge allows to use input matrix arguments
     if ( rows(varargin{1}) > 1 && columns(varargin{1}) > 1 )
 	     A = varargin{1};
	    for itr = 1:columns(A)
		  varargin{itr} = A(:,itr);
 	    end
     end
      
     itr = 1; P = [];
     while ( itr <= length(varargin) )
	  B = varargin{itr};
          B = reshape(B,[length(B),1]);      
	  rP = rows(P); lB=length(B);
	  if ( rP == 0 ) 
		P = B; itr = itr + 1;
		continue;
	  end
	  Q = repmat(P,[lB,1]);	  
          R = reshape(repmat(B,[1,rP]).',[lB*rP,1]);
          P = [Q,R];
          itr = itr + 1;
     end     
     return
end%!
%!assert(cartprod(1:2,0:1),[1 0; 2 0; 1 1; 2 1])
%!

