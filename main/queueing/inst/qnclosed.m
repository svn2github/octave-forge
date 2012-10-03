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
## @deftypefn {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}] =} qnclosed (@var{N}, @var{S}, @var{V}, @dots{})
##
## @cindex closed network
##
## This function computes steady-state performance measures of closed
## queueing networks using the Mean Value Analysis (MVA) algorithm. The
## qneneing network is allowed to contain fixed-capacity centers, delay
## centers or general load-dependent centers. Multiple request
## classes are supported.
##
## This function dispatches the computation to one of
## @code{qnclosedsinglemva}, @code{qnclosedsinglemvald} or
## @code{qnclosedmultimva}.
##
## @itemize
##
## @item If @var{N} is a scalar, the network is assumed to have a single
## class of requests; in this case, the exact MVA algorithm is used to
## analyze the network. If @var{S} is a vector, then @code{@var{S}(k)}
## is the average service time of center @math{k}, and this function
## calls @code{qnclosedsinglemva} which supports load-independent
## service centers. If @var{S} is a matrix, @code{@var{S}(k,i)} is the
## average service time at center @math{k} when @math{i =1, @ldots{}, N}
## jobs are present; in this case, the network is analyzed with the
## @code{qnclosedsinglemvald} function.
##
## @item If @var{N} is a vector, the network is assumed to have multiple
## classes of requests, and is analyzed using the exact multiclass
## MVA algorithm as implemented in the @code{qnclosedmultimva} function.
##
## @end itemize
##
## @seealso{qnclosedsinglemva, qnclosedsinglemvald, qnclosedmultimva}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [U R Q X] = qnclosed( N, S, V, varargin )
  if ( nargin < 3 )
    print_usage();
  endif
  if ( isscalar(N) )
    if ( isvector(S) ) 
      [U R Q X] = qnclosedsinglemva( N, S, V, varargin{:} );
    else
      [U R Q X] = qnclosedsinglemvald( N, S, V, varargin{:} );
    endif
  else
    [U R Q X] = qnclosedmultimva( N, S, V, varargin{:} );
  endif
endfunction

%!demo
%! P = [0 0.3 0.7; 1 0 0; 1 0 0]; # Transition probability matrix
%! S = [1 0.6 0.2]; # Average service times
%! m = ones(1,3); # All centers are single-server
%! Z = 2; # External delay
%! N = 15; # Maximum population to consider
%!
%! V = qnvisits(P); # Compute number of visits from P
%! D = V .* S; # Compute service demand from S and V
%! X_bsb_lower = X_bsb_upper = zeros(1,N);
%! X_ab_lower = X_ab_upper = zeros(1,N);
%! X_mva = zeros(1,N);
%! for n=1:N
%!   [X_bsb_lower(n) X_bsb_upper(n)] = qnclosedbsb(n, D, Z);
%!   [X_ab_lower(n) X_ab_upper(n)] = qnclosedab(n, D, Z);
%!   [U R Q X] = qnclosed( n, S, V, m, Z );
%!   X_mva(n) = X(1)/V(1);
%! endfor
%! close all;
%! plot(1:N, X_ab_lower,"g;Asymptotic Bounds;", \
%!      1:N, X_bsb_lower,"k;Balanced System Bounds;", \
%!      1:N, X_mva,"b;MVA;", "linewidth", 2, \
%!      1:N, X_bsb_upper,"k", \
%!      1:N, X_ab_upper,"g" );
%! axis([1,N,0,1]);
%! xlabel("Number of Requests n");
%! ylabel("System Throughput X(n)");
%! legend("location","southeast");
