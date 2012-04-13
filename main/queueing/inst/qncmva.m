## Copyright (C) 2011, 2012 Moreno Marzolla
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
## @deftypefn {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}] =} qncmva (@var{N}, @var{S}, @var{Sld}, @var{V})
## @deftypefnx {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}] =} qncmva (@var{N}, @var{S}, @var{Sld}, @var{V}, @var{Z})
##
## @cindex Mean Value Analysys (MVA)
## @cindex CMVA
##
## Implementation of the Conditional MVA (CMVA) algorithm, a numerically
## stable variant of MVA for load-dependent servers. CMVA is described
## in G. Casale, @cite{A Note on Stable Flow-Equivalent Aggregation in
## Closed Networks}. The network is made of @math{M} service centers and
## a delay center. Servers @math{1, \ldots, M-1} are load-independent;
## server @math{M} is load-dependent.
##
## @strong{INPUTS}
##
## @table @var
##
## @item N
## Population size (number of requests in the system, @code{@var{N} @geq{} 0}).
## If @code{@var{N} == 0}, this function returns
## @code{@var{U} = @var{R} = @var{Q} = @var{X} = 0}
##
## @item S
## @code{@var{S}(k)} is the mean service time on server @math{k = 1, @dots{}, M-1}
## (@code{@var{S}(k) > 0}).
##
## @item Sld
## @code{@var{Sld}(n)} is the mean service time on server @math{M}
## when there are @math{n} requests, @math{n=1, @dots{}, N}.
## @code{@var{Sld}(n) = } @math{1 / \mu(n)}, where @math{\mu(n)} is the
## service rate at center @math{N} when there are @math{n} requests.
##
## @item V
## @code{@var{V}(k)} is the average number of visits to service center
## @math{k= 1, @dots{}, M} (@code{@var{V}(k) @geq{} 0}).
##
## @item Z
## External delay for customers (@code{@var{Z} @geq{} 0}). Default is 0.
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @var
##
## @item U
## @code{@var{U}(k)} is the utilization of center @math{k=1, @dots{}, M}
##
## @item R
## @code{@var{R}(k)} is the response time at center @math{k=1, @dots{}, M}.
## The system response time @var{Rsys}
## can be computed as @code{@var{Rsys} = @var{N}/@var{Xsys} - Z}
##
## @item Q
## @code{@var{Q}(k)} is the average number of requests at center
## @math{k=1, @dots{}, M}.
##
## @item X
## @code{@var{X}(k)} is the throughput of center @math{k=1, @dots{}, M}.
##
## @end table
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [U R Q X] = qncmva( N, S, Sld, V, Z )

  if ( nargin < 4 || nargin > 5 )
    print_usage();
  endif

  isscalar(N) && N >= 0 || \
      error("N must be a positive scalar");

  isvector(S) || \
      error("S must be a vector");
  S = S(:)'; # make S a row vector
  M = length(S)+1; # number of service centers (escluding the delay center)
  
  isvector(Sld) && length(Sld) == N && all(Sld>=0) || \
      error("Sld must be a vector with %d elements >= 0", N);
  Sld = Sld(:)'; # Make Sld a row vector

  isvector(V) && length(V) == M && all(V>=0) || \
      error("V must be a vector with %d elements", M);
  V = V(:)'; # Make V a row vector

  if ( nargin == 5 )
    isscalar(Z) && Z>=0 || \
	error("Z must be nonnegative");
  else
    Z = 0;
  endif

  if ( N == 0 )
    U = R = Q = X = zeros(1,M);
  endif

  D = S .* V(1:M-1); # service demands
  Ri = Qi = zeros(M,N+1,N+1);
  DM = Xs = zeros(N+1,N+1); # system throughput

  ## Main MVA loop
  for n=1:N 
    for t=1:(N-n+1)
      if ( n==1 )
	DM(1+n,t) = Sld(t)*V(M);
      else
	DM(1+n,t) = Xs(n,t)/Xs(n,t+1)*DM(n,t);
      endif
      i=1:(M-1);
      Ri(i,1+n,t) = D(i).*(1+Qi(i,n,t))';
      Ri(M,1+n,t) = DM(1+n,t).*(1+Qi(M,n,t+1));
      Xs(1+n,t) = n/(Z+sum(Ri(:,1+n,t)));
      i=1:(M-1);
      Qi(i,1+n,t) = D(i) .* Xs(1+n,t) .* (1+Qi(i,n,t))';
      Qi(M,1+n,t) = DM(1+n,t).*Xs(1+n,t).*(1+Qi(M,n,t+1));
    endfor
  endfor
  X = Xs(1+N,1)*V;
  Q = Qi(:,1+N,1)';
  R = Ri(:,1+N,1)';
  U = [D DM(1+N,1)] .* X;
endfunction
%!test
%! N=5;
%! S = [1 0.3 0.8 0.9];
%! V = [1 1 1 1];
%! [U1 R1 Q1 X1] = qncmva( N, S(1:3), repmat(S(4),1,N), V );
%! [U2 R2 Q2 X2] = qnclosedsinglemva(N, S, V);
%! assert( U1, U2, 1e-5 );
%! assert( R1, R2, 1e-5 );
%! assert( Q1, Q2, 1e-5 );
%! assert( X1, X2, 1e-5 );

%!test
%! N=5;
%! S = [1 1 1 1 1; \
%!      1 1 1 1 1; \
%!      1 1 1 1 1; \
%!      1 1/2 1/3 1/4 1/5];
%! V = [1 1 1 1];
%! [U1 R1 Q1 X1] = qncmva( N, S(1:3,1), S(4,:), V );
%! [U2 R2 Q2 X2] = qnclosedsinglemvald(N, S, V);
%! assert( U1, U2, 1e-5 );
%! assert( R1, R2, 1e-5 );
%! assert( Q1, Q2, 1e-5 );
%! assert( X1, X2, 1e-5 );

