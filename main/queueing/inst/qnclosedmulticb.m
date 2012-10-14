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
## @deftypefn {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}] =} qnclosedmulticb (@var{N}, @var{D})
## @deftypefnx {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}] =} qnclosedmulticb (@var{N}, @var{S}, @var{V})
##
## @cindex multiclass network, closed
## @cindex bounds, composite
##
## Composite Bound (CB) on throughput and response time for multiclass networks.
##
## This function implements the Composite Bound Method described in T.
## Kerola, @cite{The Composite Bound Method (CBM) for Computing
## Throughput Bounds in Multiple Class Environments}, Technical Report
## CSD-TR-475, Purdue University, march 13, 1984 (revised august 27,
## 1984).
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
## at center @math{k} (@code{@var{S}(c,k) @geq{} 0}).
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
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [Xl Xu Rl Ru] = qnclosedmulticb( N, S, V )

  if ( nargin < 2 || nargin > 3 )
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
    V = ones(size(S));
  else
    (ismatrix(V) && size_equal(S,V) ) || \
	error("V must be a %d x %d matrix", C, K);
    all(all(V>=0)) || \
	error("V must contain nonnegative values");
  endif

  [Xl] = qnclosedmultibsb(N, S, V);
  Xu = zeros(1,C);

  D = S .* V;

  D_max = max(D,[],2)';
  for r=1:C # FIXME: vectorize this

    ## This is equation (13) from T. Kerola, The Composite Bound Method
    ## (CBM) for Computing Throughput Bounds in Multiple Class
    ## Environments, Technical Report CSD-TR-475, Purdue University,
    ## march 13, 1984 (revised august 27, 1984)
    ## http://docs.lib.purdue.edu/cgi/viewcontent.cgi?article=1394&context=cstech

    ## The only modification here is to apply also the upper bound
    ## 1/D_max(r), eveb though it seems redundant.

    s = (1:C != r); # boolean array
    tmp = (1 .- Xl(s)*D(s,:)) ./ D(r,:);
    Xu(r) = min([tmp 1/D_max(r)]);
  endfor

  Rl = N ./ Xu;
  Ru = N ./ Xl;
endfunction

%!demo
%! S = [10 7 5 4; \
%!      5  2 4 6];
%! NN=20;
%! Xl = Xu = Xmva = zeros(NN,2);
%! for n=1:NN
%!   N=[n,10];
%!   [a b] = qnclosedmulticb(N,S);
%!   Xl(n,:) = a; Xu(n,:) = b;
%!   [U R Q X] = qnclosedmultimva(N,S,ones(size(S)));
%!   Xmva(n,:) = X(:,1)';
%! endfor
%! subplot(2,1,1);
%! plot(1:NN,Xl(:,1),"linewidth", 2, 1:NN,Xu(:,1),"linewidth", 2, \
%!      1:NN,Xmva(:,1),";MVA;");
%! title("Class 1 throughput");
%! subplot(2,1,2);
%! plot(1:NN,Xl(:,2),"linewidth", 2, 1:NN,Xu(:,2), "linewidth", 2,\
%!      1:NN,Xmva(:,2),";MVA;");
%! title("Class 2 throughput");
%! xlabel("Number of class 1 requests");
