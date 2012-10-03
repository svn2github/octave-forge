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
## @deftypefn {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}] =} qnclosedsinglecmva (@var{N}, @var{S}, @var{V})
## @deftypefnx {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}] =} qnclosedsinglecmva (@var{N}, @var{S}, @var{V}, @var{m})
## @deftypefnx {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}] =} qnclosedsinglecmva (@var{N}, @var{S}, @var{V}, @var{m}, @var{Z})
##
## @cindex Conditional Mean Value Analysys (CMVA)
## @cindex closed network, single class
## @cindex normalization constant
##
## Analyze closed, single-class networks with the Conditional MVA (CMVA) algorithm.
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
## @code{@var{S}(k)} is the mean service time on server @math{k}
## (@code{@var{S}(k)>0}).
##
## @item V
## @code{@var{V}(k)} is the average number of visits to service center
## @math{k} (@code{@var{V}(k) @geq{} 0}).
##
## @item Z
## External delay for customers (@code{@var{Z} @geq{} 0}). Default is 0.
##
## @item m
## @code{@var{m}(k)} is the number of servers at center @math{k}
## (if @var{m} is a scalar, all centers have that number of servers). If
## @code{@var{m}(k) < 1}, center @math{k} is a delay center (IS);
## otherwise it is a regular queueing center (FCFS, LCFS-PR or PS) with
## @code{@var{m}(k)} servers. Default is @code{@var{m}(k) = 1} for all
## @math{k} (each service center has a single server).
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @var
##
## @item U
## If @math{k} is a FCFS, LCFS-PR or PS node (@code{@var{m}(k) == 1}),
## then @code{@var{U}(k)} is the utilization of center @math{k}. If
## @math{k} is an IS node (@code{@var{m}(k) < 1}), then
## @code{@var{U}(k)} is the @emph{traffic intensity} defined as
## @code{@var{X}(k)*@var{S}(k)}.
##
## @item R
## @code{@var{R}(k)} is the response time at center @math{k}.
## The @emph{Residence Time} at center @math{k} is
## @code{@var{R}(k) * @var{V}(k)}.
## The system response time @var{Rsys}
## can be computed either as @code{@var{Rsys} = @var{N}/@var{Xsys} - Z}
## or as @code{@var{Rsys} = dot(@var{R},@var{V})}
##
## @item Q
## @code{@var{Q}(k)} is the average number of requests at center
## @math{k}. The number of requests in the system can be computed
## either as @code{sum(@var{Q})}, or using the formula
## @code{@var{N}-@var{Xsys}*@var{Z}}.
##
## @item X
## @code{@var{X}(k)} is the throughput of center @math{k}. The
## system throughput @var{Xsys} can be computed as
## @code{@var{Xsys} = @var{X}(1) / @var{V}(1)}
##
## @end table
##
## @seealso{qnclosedsinglemva}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [U R Q X] = qnclosedsinglecmva( N, S, V, m, Z )

  ## This is a numerically stable implementation of the MVA algorithm,
  ## based on G. Casale, A note on stable flow-equivalent aggregation in
  ## closed networks. Queueing Syst. Theory Appl., 60:193–-202, December
  ## 2008, http://dx.doi.org/10.1007/s11134-008-9093-6

  ## This implementation extends the paper above to consider a single
  ## class closed network with an arbitrary number of multiple-server
  ## nodes, delay stations and single-server nodes (plus an external
  ## delay); the paper only considers a single load-dependent server and
  ## a single delay center.

  ## Note also that this implementation uses service rates instead of
  ## service demands, as in the paper. Equations have been modified
  ## accordingly.

  # warning("This function may produce incorrect results. Use at your own risk");

  if ( nargin < 3 || nargin > 5 ) 
    print_usage();
  endif

  isscalar(N) && N >= 0 || \
      error( "N must be >= 0" );
  isvector(S) || \
      error( "S must be a vector" );
  S = S(:)'; # make S a row vector

  isvector(V) || \
      error( "V must be a vector" );
  V = V(:)'; # make V a row vector

  K = length(S); # Number of servers

  if ( nargin < 4 ) 
    m = ones(1,K);
  else
    isvector(m) || \
	error( "m must be a vector" );
    m = m(:)'; # make m a row vector
  endif

  [err S V m] = common_size(S, V, m);
  (err == 0) || \
      error( "S, V and m are of incompatible size" );
  all(S>=0) || \
      error( "S must be a vector >= 0" );
  all(V>=0) || \
      error( "V must be a vector >= 0" );

  if ( nargin < 5 )
    Z = 0;
  else
    (isscalar(Z) && Z >= 0) || \
        error( "Z must be >= 0" );
  endif

  U = R = Q = X = zeros( 1, K );
  if ( N == 0 ) # Trivial case of empty population: just return all zeros
    return;
  endif

  ## System throughput
  ## Xs_n(t) := X(N,t)
  ## Sx_nm1(t) := X(N-1,t)
  Xs_n = Xs_nm1 = zeros(1,N);

  ## Queue lengths
  ## Qn(i,t) := Q_i(n,t)
  ## Qnm1(i,t) := Q_i(n-1,t)
  Qn = Qnm1 = zeros(K,N+1);

  ## Response times
  ## Rn(i,t) := R_i(n,t)
  Rn = zeros(K,N);

  i_single = find( m==1 );
  i_multi = find( m>1 );
  i_delay = find( m<1 );

  ## Service times (note that the reference paper uses service demands)
  ## Sn(i,t) ~ D_i(n,t)
  ## Snm1(i,t) ~ D_i(n-1,t)
  Sn = Snm1 = zeros(K,N+1);
  ## Initialize service times (NOTE: beware of simgular dimensions!)
  Sn(i_single,:) = Snm1(i_single,:) = repmat(S(1,i_single)',1,N+1);
  Sn(i_delay,:) = Snm1(i_delay,:) = repmat(S(1,i_delay)',1,N+1);

  ## Main CMVA loop
  for n=1:N 
    for t=1:(N-n+1)

      ## Compute service demands
      if ( n>=2 )
	Sn(i_multi,t) = Xs_nm1(t)./Xs_nm1(t+1).*Snm1(i_multi,t);
      else
	Sn(i_multi,t) = S(1,i_multi)./min(m(1,i_multi),t);
      endif

      ## Compute response times
      Rn(i_single,t) = Sn(i_single,t) .* (1 + Qnm1(i_single,t)); 
      Rn(i_multi,t) = Sn(i_multi,t) .* (1 + Qnm1(i_multi,t+1));
      Rn(i_delay,t) = Sn(i_delay,t);

      ## Compute system throughput
      Xs_n = n ./ ( Z + V * Rn );

      ## Update queue lenghts
      Qn(i_single,t) = Sn(i_single,t).*V(1,i_single)'.*Xs_n(t).*(1+Qnm1(i_single,t));
      Qn(i_delay,t) = Sn(i_delay,t).*Xs_n(t);
      Qn(i_multi,t) = Sn(i_multi,t).*V(1,i_multi)'.*Xs_n(t).*(1+Qnm1(i_multi,t+1));

      ## prepare for next iteration
      Qnm1 = Qn;
      Snm1 = Sn;
      Xs_nm1 = Xs_n;
    endfor
  endfor
  X = Xs_n(1)*V; # Service centers throughput
  Q = Qn(:,1)';
  R = Rn(:,1)';
  U(i_single) = X(i_single) .* S(i_single);
  U(i_delay) = X(i_delay) .* S(i_delay);
  U(i_multi) = X(i_multi) .* S(i_multi) ./ m(i_multi);
endfunction

%!test
%! fail( "qnclosedsinglecmva()", "Invalid" );
%! fail( "qnclosedsinglecmva( 10, [1 2], [1 2 3] )", "S, V and m" );
%! fail( "qnclosedsinglecmva( 10, [-1 1], [1 1] )", ">= 0" );

## Check if networks with only one type of server are handled correctly
%!test
%! qnclosedsinglecmva(1,1,1,1);
%! qnclosedsinglecmva(1,1,1,-1);
%! qnclosedsinglecmva(1,1,1,2);
%! qnclosedsinglecmva(1,[1 1],[1 1],[-1 -1]);
%! qnclosedsinglecmva(1,[1 1],[1 1],[1 1]);
%! qnclosedsinglecmva(1,[1 1],[1 1],[2 2]);

## Check degenerate case of N==0 (LI case)
%!test
%! N = 0;
%! S = [1 2 3 4];
%! V = [1 1 1 4];
%! [U R Q X] = qnclosedsinglecmva(N, S, V);
%! assert( U, 0*S );
%! assert( R, 0*S );
%! assert( Q, 0*S );
%! assert( X, 0*S );

## Check degenerate case of N==0 (LD case)
%!test
%! N = 0;
%! S = [1 2 3 4];
%! V = [1 1 1 4];
%! m = [2 3 4 5];
%! [U R Q X] = qnclosedsinglecmva(N, S, V, m);
%! assert( U, 0*S );
%! assert( R, 0*S );
%! assert( Q, 0*S );
%! assert( X, 0*S );

%!test
%! # Exsample 3.42 p. 577 Jain
%! S = [ 0.125 0.3 0.2 ]';
%! V = [ 16 10 5 ];
%! N = 20;
%! m = ones(1,3)';
%! Z = 4;
%! [U R Q X] = qnclosedsinglecmva(N,S,V,m,Z);
%! assert( R, [ .373 4.854 .300 ], 1e-3 );
%! assert( Q, [ 1.991 16.177 0.500 ], 1e-3 );
%! assert( all( U>=0 ) );
%! assert( all( U<=1 ) );

%!test
%! # Exsample 3.42 p. 577 Jain
%! S = [ 0.125 0.3 0.2 ];
%! V = [ 16 10 5 ];
%! N = 20;
%! m = ones(1,3);
%! Z = 4;
%! [U R Q X] = qnclosedsinglecmva(N,S,V,m,Z);
%! assert( R, [ .373 4.854 .300 ], 1e-3 );
%! assert( Q, [ 1.991 16.177 0.500 ], 1e-3 );
%! assert( all( U>=0 ) );
%! assert( all( U<=1 ) );

%!test
%! # Example 8.4 p. 333 Bolch et al.
%! S = [ .5 .6 .8 1 ];
%! N = 3;
%! m = [2 1 1 -1];
%! V = [ 1 .5 .5 1 ];
%! [U R Q X] = qnclosedsinglecmva(N,S,V,m);
%! assert( Q, [ 0.624 0.473 0.686 1.217 ], 1e-3 );
%! assert( X, [ 1.218 0.609 0.609 1.218 ], 1e-3 );
%! assert( all(U >= 0 ) );
%! assert( all(U( m>0 ) <= 1 ) );

%!test
%! # Example 8.3 p. 331 Bolch et al.
%! # This is a single-class network, which however nothing else than
%! # a special case of multiclass network
%! S = [ 0.02 0.2 0.4 0.6 ];
%! K = 6;
%! V = [ 1 0.4 0.2 0.1 ];
%! [U R Q X] = qnclosedsinglecmva(K, S, V);
%! assert( U, [ 0.198 0.794 0.794 0.595 ], 1e-3 );
%! assert( R, [ 0.025 0.570 1.140 1.244 ], 1e-3 );
%! assert( Q, [ 0.244 2.261 2.261 1.234 ], 1e-3 );
%! assert( X, [ 9.920 3.968 1.984 0.992 ], 1e-3 );

%!test
%! # Check bound analysis
%! N = 10; # max population
%! for n=1:N
%!   S = [1 0.8 1.2 0.5];
%!   V = [1 2 2 1];
%!   [U R Q X] = qnclosedsinglecmva(n, S, V);
%!   Xs = X(1)/V(1);
%!   Rs = dot(R,V);
%!   # Compare with balanced system bounds
%!   [Xlbsb Xubsb Rlbsb Rubsb] = qnclosedbsb( n, S .* V );
%!   assert( Xlbsb<=Xs );
%!   assert( Xubsb>=Xs );
%!   assert( Rlbsb<=Rs );
%!   assert( Rubsb>=Rs );
%!   # Compare with asymptotic bounds
%!   [Xlab Xuab Rlab Ruab] = qnclosedab( n, S .* V );
%!   assert( Xlab<=Xs );
%!   assert( Xuab>=Xs );
%!   assert( Rlab<=Rs );
%!   assert( Ruab>=Rs );
%! endfor

## Example from Schwetman (figure 7, page 9 of
## http://docs.lib.purdue.edu/cgi/viewcontent.cgi?article=1258&context=cstech
## "Testing network-of-queues software, technical report CSD-TR 330,
## Purdue University). Note that the results for that network (table 9
## of the reference above) seems to be wrong. The "correct" results
## below have been computed using the multiclass MVA implementation of
## JMT (http://jmt.sourceforge.net/)
%!test
%! V = [ 1.00 0.45 0.50 0.00; \
%!       1.00 0.00 0.50 0.49 ];
%! N = [3 2];
%! S = [0.01 0.09 0.10 0.08; \
%!      0.05 0.09 0.10 0.08];
%! [U R Q X] = qnclosedmultimva(N, S, V);
%! assert( U, [ 0.1215 0.4921 0.6075 0.0000; \
%!              0.3433 0.0000 0.3433 0.2691 ], 1e-4 );
%! assert( Q, [ 0.2131 0.7539 2.0328 0.0000; \
%!              0.5011 0.0000 1.1839 0.3149 ], 1e-4 );
%! assert( R.*V, [0.0175 0.0620 0.1672 0.0000; \
%!                0.0729 0.0000 0.1724 0.0458 ], 1e-4 );
%! assert( X, [12.1517 5.4682 6.0758 0.0000; \
%!              6.8669 0.0000 3.4334 3.3648 ], 1e-4 );

%!demo
%! S = [ 0.125 0.3 0.2 ];
%! V = [ 16 10 5 ];
%! N = 20;
%! m = ones(1,3);
%! Z = 4;
%! [U R Q X] = qnclosedsinglecmva(N,S,V,m,Z);
%! X_s = X(1)/V(1); # System throughput
%! R_s = dot(R,V); # System response time
%! printf("\t    Util      Qlen     RespT      Tput\n");
%! printf("\t--------  --------  --------  --------\n");
%! for k=1:length(S)
%!   printf("Dev%d\t%8.4f  %8.4f  %8.4f  %8.4f\n", k, U(k), Q(k), R(k), X(k) );
%! endfor
%! printf("\nSystem\t          %8.4f  %8.4f  %8.4f\n\n", N-X_s*Z, R_s, X_s );

%!demo
%! maxN = 90; # Max population size
%! Rmva = Rcmva = zeros(1,maxN); # Results
%! S = 4;
%! Z = 10;
%! m = 8;
%! for N=1:maxN
%!   # Use MVA
%!   [U R] = qnclosedsinglemva(N,S,1,m,Z);
%!   Rmva(N) = R(1);
%!   # USe CMVA
%!   [U R] = qnclosedsinglecmva(N,S,1,m,Z);
%!   Rcmva(N) = R(1);
%! endfor
%! plot(1:maxN, Rmva, ";Resp. Time (MVA);", \
%!      1:maxN, Rcmva, ";Resp. Time (CMVA);");

