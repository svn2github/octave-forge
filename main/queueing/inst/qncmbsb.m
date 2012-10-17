## Copyright (C) 2012 Moreno Marzolla
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
## @deftypefn {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}] =} qncmbsb (@var{N}, @var{D})
## @deftypefnx {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}] =} qncmbsb (@var{N}, @var{S}, @var{V})
##
## @cindex bounds, balanced system
## @cindex multiclass network, closed
##
## Compute Balanced System Bounds for multiclass networks.
## Only single-server nodes are supported.
##
## @strong{INPUTS}
##
## @table @var
##
## @item N
## @code{@var{N}(c)} is the number of class @math{c} requests in the system.
##
## @item D
## @code{@var{D}(c, k)} is class @math{c} service demand 
## at center @math{k} (@code{@var{D}(c,k) @geq{} 0}).
##
## @item S
## @code{@var{S}(c, k)} is the mean service time of class @math{c}
## requests at center @math{k} (@code{@var{S}(c,k) @geq{} 0}).
##
## @item V
## @code{@var{V}(c,k)} is the average number of visits of class @math{c}
## requests to center @math{k} (@code{@var{V}(c,k) @geq{} 0}). 
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @var
##
## @item Xl
## @itemx Xu
## Lower and upper class @math{c} throughput bounds.
##
## @item Rl
## @itemx Ru
## Lower and upper class @math{c} response time bounds.
##
## @end table
##
## @seealso{qnclosedsinglebsb}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [Xl Xu Rl Ru] = qncmbsb( N, S, V, m, Z )

  ## FIXME: parameter Z is not used, some dead code is left below

  if ( nargin<2 || nargin>5 )
    print_usage();
  endif

  ( isvector(N) && length(N)>0 ) || \
      error("N must be a nonempty vector");
  all(N >= 0) || \
      error( "N must contain nonnegative values" );
  sum(N)>0 || \
      error( "The network has no requests" );
  N = N(:)';

  C = length(N); # number of classes

  ( ismatrix(S) && rows(S) == C ) || \
      error("S/D must be a matrix with %d rows", C);
  all(all(S>=0)) || \
      error("S/D must contain nonnegative values");

  K = columns(S);

  if ( nargin<3 )
    D = S;
  else
    (ismatrix(V) && size_equal(S,V) ) || \
	error("V must be a %d x %d matrix", C, K);
    all(all(V>=0)) || \
	error("V must contain nonnegative values");
    D = S .* V;
  endif

  if ( nargin<4 )
    m = ones(1,K);
  else
    (isvector(m) && length(m) == K ) || \
	error("m must be a vector with %d elements", K);
    all(m<=1) || \
	error("Multiple-server nodes are not supported");
    m = m(:)';
  endif

  if (nargin<5)
    Z = zeros(1,C);
  else
    (isvector(Z) && length(Z) == C ) || \
	error("Z must be a vector with %d elements", C);
    all(Z>=0) || \
	error("Z must contain nonnegative values");
    Z = Z(:)';
  endif

  ## Equations from T. Kerola, The Composite Bound Method (CBM) for
  ## Computing Throughput Bounds in Multiple Class Environments},
  ## Technical Report CSD-TR-475, Department of Computer Sciences,
  ## Purdue University, mar 13 1984 (Revisted aug 27, 1984), available
  ## at
  ## http://docs.lib.purdue.edu/cgi/viewcontent.cgi?article=1394&context=cstech

  Dc = sum(D,2)';
  D_max = max(D,[],2)';
  D_min = min(D,[],2)';
  Xl = N ./ (Dc .+ (sum(N)-1) .* D_max);
  Xu = min( 1./D_max, N ./ ((K+sum(N)-1) .* D_min));
  Rl = N ./ Xu;
  Ru = N ./ Xl;
endfunction

%!test
%! fail("qncmbsb([],[])", "nonempty");
%! fail("qncmbsb([0 0], [1 2])", "no requests");
%! fail("qncmbsb([1 0], [1 2 3])", "2 rows");
%! fail("qncmbsb([1 0], [1 2 3; 4 5 -1])", "nonnegative");
%! fail("qncmbsb([1 2], [1 2 3; 4 5 6], [1 2 3])", "2 x 3");
%! fail("qncmbsb([1 2], [1 2 3; 4 5 6], [1 2 3; 4 5 -1])", "nonnegative");
%! fail("qncmbsb([1 2], [1 2 3; 1 2 3], [1 2 3; 1 2 3], [1 1])", "3 elements");
%! fail("qncmbsb([1 2], [1 2 3; 1 2 3], [1 2 3; 1 2 3], [1 1 2])", "not supported");
%! fail("qncmbsb([1 2], [1 2 3; 1 2 3], [1 2 3; 1 2 3], [1 1 -1],[1 2 3])", "2 elements");
%! fail("qncmbsb([1 2], [1 2 3; 1 2 3], [1 2 3; 1 2 3], [1 1 -1],[1 -2])", "nonnegative");

%!demo
%! S = [10 7 5 4; \
%!      5  2 4 6];
%! NN=20;
%! Xl = Xu = Rl = Ru = Xmva = Rmva = zeros(NN,2);
%! for n=1:NN
%!   N=[n,10];
%!   [a b c d] = qncmbsb(N,S);
%!   Xl(n,:) = a; Xu(n,:) = b; Rl(n,:) = c; Ru(n,:) = d;
%!   [U R Q X] = qncmmva(N,S,ones(size(S)));
%!   Xmva(n,:) = X(:,1)'; Rmva(n,:) = sum(R,2)';
%! endfor
%! subplot(2,2,1);
%! plot(1:NN,Xl(:,1), 1:NN,Xu(:,1), 1:NN,Xmva(:,1),";MVA;", "linewidth", 2);
%! title("Class 1 throughput");
%! subplot(2,2,2);
%! plot(1:NN,Xl(:,2), 1:NN,Xu(:,2), 1:NN,Xmva(:,2),";MVA;", "linewidth", 2);
%! title("Class 2 throughput");
%! subplot(2,2,3);
%! plot(1:NN,Rl(:,1), 1:NN,Ru(:,1), 1:NN,Rmva(:,1),";MVA;", "linewidth", 2);
%! title("Class 1 response time");
%! subplot(2,2,4);
%! plot(1:NN,Rl(:,2), 1:NN,Ru(:,2), 1:NN,Rmva(:,2),";MVA;", "linewidth", 2);
%! title("Class 2 response time");