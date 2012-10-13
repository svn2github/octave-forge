## Copyright (C) 2008, 2009, 2010, 2011, 2012 Moreno Marzolla
##
## This file is part of the queueing toolbox.
##
## The queueing toolbox is free software: you can redistribute it and/or
## modify it under the terms of the GNU General Public License as
## published by the Free Software Foundation, either version 3 of the
## License, or (at your option) any later version.
##
## The queueing toolbox is distributed in the hope that it will be
## useful, but WITHOUT ANY WARRANTY; without even the implied warranty
## of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with the queueing toolbox. If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
##
## @deftypefn {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}] =} qnclosedab (@var{N}, @var{S}, @dots{})
##
## @cindex bounds, asymptotic
## @cindex closed network
##
## This function computes Asymptotic Bounds for throughput and response
## time of closed, single or multiclass queueing networks. Single server
## and delay centers are allowed. Multiple server nodes are not
## supported.
##
## This function dispatches the computation to @code{qnclosedsingleab}
## or @code{qnclosedmultiab}.
##
## @itemize
##
## @item If @var{N} is a scalar, the network is assumed to have a single
## class of requests and control is passed to @code{qnclosedsingleab}.
##
## @item If @var{N} is a vector, the network is assumed to have multiple
## classes of requests, and control is passed to @code{qnclosedmultiab}.
##
## @end itemize
##
## @seealso{qnclosedsingleab, qnclosedmultiab}.
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [Xl Xu Rl Ru] = qnclosedab( N, varargin )
  if ( nargin < 2 || nargin > 5 )
    print_usage();
  endif
  if (isscalar(N))
    [Xl Xu Rl Ru] = qnclosedsingleab(N, varargin{:});
  else
    [Xl Xu Rl Ru] = qnclosedmultiab(N, varargin{:});
  endif
endfunction

%!test
%! fail( "qnclosedab( 1, [] )", "vector" );
%! fail( "qnclosedab( 1, [0 -1])", ">= 0" );
%! fail( "qnclosedab( 0, [1 2] )", "positive integer" );
%! fail( "qnclosedab( -1, [1 2])", "positive integer" );

## Example 9.6 p. 913 Bolch et al.
%!test
%! N = 20;
%! S = [ 4.6*2 8 ];
%! Z = 120;
%! [X_l X_u R_l R_u] = qnclosedab(N, S, 1, 1, Z);
%! assert( [X_u R_l], [0.109 64], 1e-3 );

%!demo
%! S = [10 7 5 4; \
%!      5  2 4 6];
%! Z = [5 3];
%! NN=20;
%! Xl = Xu = Xmva = zeros(NN,2);
%! for n=1:NN
%!   N=[n,10];
%!   [a b] = qnclosedab(N,S,ones(size(S)),ones(1,columns(S)),Z);
%!   [U R Q X] = qnclosedmultimva(N,S,ones(size(S)),ones(1,columns(S)),Z);
%!   Xl(n,:) = a;
%!   Xu(n,:) = b;
%!   Xmva(n,:) = X(:,1)';
%! endfor
%! subplot(2,1,1);
%! plot(1:NN,Xl(:,1),"linewidth", 2, \
%!      1:NN,Xu(:,1),"linewidth", 2, \
%!      1:NN,Xmva(:,1),";MVA;");
%! title("Class 1 throughput");
%! subplot(2,1,2);
%! plot(1:NN,Xl(:,2),"linewidth", 2, \
%!      1:NN,Xu(:,2), "linewidth", 2,\
%!      1:NN,Xmva(:,2),";MVA;");
%! title("Class 2 throughput");
%! xlabel("Number of class 1 requests");