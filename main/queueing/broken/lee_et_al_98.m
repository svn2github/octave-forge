## Copyright (C) 2007, 2008, 2009, 2010, 2011, 2012 Moreno Marzolla
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
## @deftypefn {Function File} {@var{P} =} lee_et_al_98 ( @var{mu}, @var{mu0}, @var{C}, @var{r}, @var{blocking_type} )
##
## @strong{WARNING: this implementation is not working yet}
##
## Implementation of the numerical algorithm for approximate solution of
## single-class queueing networks with blocking. The algorithm is
## described in [1]. This is the implementation of Algorithm 1, p. 192
## from the paper above, and can be used for cyclic networks.
##
## @strong{INPUTS}
##
## @table @var
##
## @item mu
##
## @code{@var{mu}(i)} is the service rate at service center @math{i}.
## This function aborts if @code{@var{mu}(i) <= 0} for some @math{i}.
##
## @item mu0
##
## @code{@var{mu0}(i)} is the external arrival rate on service center
## @math{i}. If @code{@var{mu0}(i) <= 0} there is no external arrival on
## service center @math{i}.
##
## @item C
##
## @code{@var{C}(i)} is the capacity of service center @math{i}. The
## buffer size of service center @math{i} is @code{@var{C}(i)-1}. This
## function aborts if @code{@var{C}(i) < 1} for some @math{i}.
##
## @item r
##
## @code{@var{r}(i,j)} is the routing probability from service center
## @math{i} to service center @math{j}, that is, the probability that a
## job which completed execution on service center @math{i} is routed to
## service center @math{j}. If @math{\sum_{j} r(i,j) < 1} for some
## @math{i}, then the exit probability of jobs from service center
## @math{i} is @math{( 1 - \sum_{j} r(i,j) )}; this is the probability
## that a job leaves the system after completing service at service
## center @math{i}.
##
## @item blocking_type
##
## if @code{@var{blocking_type}(j)==0}, then Blocking-after-service
## (BAS) is assumed for service center @code{@var{S_u1}(j)}; if
## @code{@var{blocking_type}(j)!=0}, then Repetitive-service blocking is
## assumed for service center @code{@var{S_u1}(j)}. Note that
## Repetitive-service blocking can only be applied to saturated service
## centers (that is, @code{@var{blocking_type}(j)} can be set != 0 only
## if @code{@var{mu0}(j) > 0}).
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @var
##
## @item P
##
## @code{@var{P}(i,n)} is the steady state probability that there are
## @math{n-1} jobs on service center @math{i}.
##
## @end table
##
## @strong{ISSUES}
##
## This implementation makes heavy use of global variables. The reason
## is that there are are many structures which must be passed along to
## different functions. To avoid cluttering the function definitions
## with lot of extra parameters, we make use of global variables.
##
## This implementation makes heavy use of multidimensional arrays.
## Unfortunately, index of octave arrays always start from 1. This is an
## issue, as in many cases (e.g., @var{P_b}), one of the indexes is
## supposed to start from 0. Thus, pay extra attention about the range
## of indexes.
##
## The algorithm by Lee et al. [1] makes heavy use of summations. While
## in octave it is relatively easy to sum the elements of an array (or
## of a matrix), it is not so easy to make nested summations, especially
## if these summations cannot be reduced to matrix/vector
## multiplications. In this implementation, there are many places in
## which nested loops are used. This is inefficient and makes the code
## difficult to read, but again, my understanding is that there is no
## better way to do that.
##
## This implementation is NOT optimized for speed. DO NOT perform speed
## benchmark on this implementation!
##
## @strong{REFERENCES}
##
## @noindent [1] H.S. Lee, A. Bouhchouch, Y. Dallery and Y. Frein,
## @cite{Performance evaluation of open queueing networks with arbitrary
## configuration and finite buffers}, Annals of Operations Research
## 79(1998), 181-206
##
## @noindent [2] Hyo-Seong Lee; Stephen M. Pollock, @cite{Approximation
## Analysis of Open Acyclic Exponential Queueing Networks with
## Blocking}, Operations Research, Vol. 38, No. 6. (Nov. - Dec., 1990),
## pp. 1123-1134.
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla@cs.unibo.it>
## Web: http://www.moreno.marzolla.name/
## Created: 2007-11-20

global mu;      # mu(1,j) j=1..M is the service rate at S_j
global C;       # C(1,j) j=1..M is the capacity of buffer B_j
global r;       # r(i,j) i=1..M, j=1..M is the routing probability from S_i to S_j
global C_max;   # Scalar representing the maximum value of C()
global N_max;   # Scalar representing the maximum value of N()
global mu_u;    # mu_u(i,j) i=1..N(j), j=1..M is the upstream service rate of S_u i(j)
global P_b;     # P_b(i,n+1,j) is the probability that at service completion instant, the server S_ui(j) sees n other servers being blocked by S_d(j), n=0..N_j-1
global P_s;     # P_s(j) is the probability that S_d(j) is starved at the service completion instant, j=1..M
global P;       # P(n+1,j) is the steady state probability that T(j) is in state n, n=0,..C_j+N_j
global b_u;     # bu_u(i,n+1,j) is the probability that n servers are blocked by S_d(j), including S_ui(j), n=1..N_j
global mu_d;    # mu_d(j) is the service rate of S_d(j), j=1..M
global mu0;     # mu0(j) is the external arrival rate to service center S_j, j=1..M. If S_j has no external arrival, then mu0(j) = 0
global blocking_type; # array of integer: blocking_type(j) == 0 iff the blocking type of S_u1(j) is BAS, blocking_type(j) != 0 for repetitive-service blocking

## Exported constants
global epsilon = 1e-5; # Maximum allowed error on throughput
global iter_count_max = 100; # Maximum number of iterations

function result = lee_et_al_98( mu_, mu0_, C_, r_, blocking_type_ )

  error( "*** The lee_et_al_98() function is currently BROKEN. Please do not use it ***" );

  global mu; 
  global C; 
  global r; 
  global C_max;
  global N_max;
  global mu_u; 
  global P_b;
  global P_s;
  global P;
  global b_u;
  global mu_d;
  global mu0;
  global blocking_type; 

  if ( nargin != 5 )
    print_usage();
  endif
      
  M = size(mu_, 2); ## Number of service centers
  size(C_) == [1,M] || error( "lee_et_al_98() - parameter C must be a (1xM) vector" );
  size(r_) == [M,M] || error( "lee_et_al_98() - parameter r must be a (MxM) matrix" );
  size(mu0_) == [1,M] || error( "lee_et_al_98() - parameter mu0 must be a (1,M) vector" );
  all( C_ > 0 ) || error( "lee_et_al_98() - parameter C must contain elements >0 only" );
  all( mu_ > 0 ) || error( "lee_et_al_98() - parameter mu must contain elements >0 only" );
  size(blocking_type_) == [1,M] || error( "lee_et_al_98() - parameter blocking_type bust be a (1,M) vector" );

  blocking_type = blocking_type_;
  mu = [mu_ mu0_];
  mu0 = mu0_;
  C = C_;
  r = r_;

  ## Some constants
  global epsilon;
  global iter_count_max;

  ## Some variables
  C_max = max(C); # Maximum buffer size
  N_max = M+1; # M service centers plus one (optional) external source
  mu_d = mu_;
  P_b = zeros( N_max, N_max, M ); ## WARNING: the second index should start from 0, not 1!!
  P_s = zeros( M );
  P = zeros( C_max+N_max+1, M ); ## WARNING: the first index should start from 0m not 1!!
  b_u = zeros( M, N_max+1, M ); ## WARNING: the second index should start from 0, not 1!!

  mu_u = zeros( N_max, M );
  for j = 1:M
    for i = 1:N(j)
      k = f(i,j);
      if ( is_saturated(i,j) ) 
        mu_u(i,j) = mu(k);
      else
        mu_u(i,j) = mu(k) * r(k,j);
      endif
    endfor
  endfor
  ## End initialization step

  ## Iteration step
  iter_count = 1;

  do

    old_mu_u = mu_u;  
    old_mu_d = mu_d;
    
    for j=1:M # Begin iteration step

      P(1:C(j)+N(j)+1,j) = compute_P(j)';
      assert( sum(P(:,j)), 1, 1e-4 );

      ##
      ## 1 Calculate mu_d(j) using (5)
      ##
      mu_d( j ) = compute_mu_d( j );
      
      ##
      ## 2 Calculate P_s(j) using (3)    
      ##
      P_s( j ) = compute_P_s( j );
      
      ##
      ## 3 Calculate P_b i(n:j) using (4) for n=0:N_j-1, i=1:N_j
      ##
      for i=1:N(j)
        for n=1:N(j)
          b_u(i,n+1,j) = compute_b_u(i,n,j);
        endfor
      endfor
      for i=1:N(j)
        for n=0:N(j)-1
          P_b(i,n+1,j) = compute_P_b( i, n, j );
        endfor
        ##assert( sum(P_b(i,:,j)), 1, 1e-4 );
      endfor
      
      ##
      ## 4 Calculate mu_u(i,k) using (7) for all k \in D_j where f(i,k)=j
      ##
      for k=D(j)
        i = f_inverse_i(j,k);
        assert(f(i,k)==j);
        mu_u(i,k) = compute_mu_u(i,k);
      endfor    

    endfor # End iteration step
    
    err1 = abs( old_mu_d - mu_d );
    err2 = abs( old_mu_u - mu_u );
    iter_count++;
    
  until ( ( (err1 < epsilon) && (err2 < epsilon) ) 
         || (iter_count > iter_count_max) );

  ## fprintf("Converged in %d iterations\n", iter_count );

  ## Safety check: check that eq. (8) from [1] is satisfied
  for j=1:M
    for i=1:N(j)
      k = f(i,j);
      if ( k<=M )
        assert( compute_X_u(i,j), compute_X_d(k) * r(k,j), 1e-4 );
      endif
    endfor
  endfor
  ## End safety check

  ## Reshape the result, so that result(i,n) is P_i(n+1), the
  ## steady-state probability that (n+1) customers are in service center
  ## S_i, n=1..C(j)+1
  result = zeros( M, C_max+1 );
  for j=1:M
    ## P_j = compute_P(j);
    result(j,[1:C(j)]) = P([1:C(j)],j)';
    result(j,C(j)+1) = sum( P([C(j)+1:C(j)+N(j)+1],j) );
  endfor

endfunction
%!test
%! source("lee_et_al_98.m"); # This is used to check internal functions

##############################################################################
## Usage: result = lee_et_al_98_acyclic( mu, mu0, C, r, blocking_type )
##
## This is Algorithm 2, p. 193 [1], and can be used for acyclic networks
## only. The parameters have the exact same meaning as in function
## lee_et_al_98().
# function result = lee_et_al_98_acyclic( mu_, mu0_, C_, r_, blocking_type_ )

#   global mu;    # mu(1,j) j=1..M is the service rate at S_j
#   global C;     # C(1,j) j=1..M is the capacity of buffer B_j
#   global r;     # r(i,j) i=1..M, j=1..M is the routing probability from S_i to S_j
#   global C_max;
#   global N_max;
#   global mu_u;  # mu_u(i,j) i=1..N(j), j=1..M is the upstream service rate of S_u i(j)
#   global P_b;
#   global P_s;
#   global P;
#   global b_u;
#   global mu_d;
#   global mu0;
#   global blocking_type;

#   blocking_type = blocking_type_;

#   M = size(mu_, 2); ## Number of service centers
#   size(C_) == [1,M] || error( "lee_et_al_98() - parameter C must be a (1xM) vector" );
#   size(r_) == [M,M] || error( "lee_et_al_98() - parameter r must be a (MxM) matrix" );
#   size(mu0_) == [1,M] || error( "lee_et_al_98() - parameter mu0 must be a (1,M) vector" );
#   all( C_ > 0 ) || error( "lee_et_al_98() - parameter C must contain elements >0 only" );
#   all( mu_ > 0 ) || error( "lee_et_al_98() - parameter mu must contain elements >0 only" );

#   mu = [mu_ mu0_];
#   mu0 = mu0_;
#   C = C_;
#   r = r_;

#   ## Some constants
#   global epsilon;
#   global iter_count_max;

#   ## Some constants
#   C_max = max(C); # Maximum buffer size
#   N_max = M+1;
#   mu_d = mu_;
#   P_b = zeros( M, N_max, M ); ## WARNING: the second index should start from 0, not 1!!
#   P = zeros( C_max+N_max+1,M ); ## WARNING: the first index should start from 0m not 1!!
#   mu_u = zeros( N_max, M );
#   P_s = zeros( M );
#   b_u = zeros( M, N_max+1, M ); ## WARNING: the second index should start from 0, not 1!!

#   for j = 1:M
#     for i = 1:N(j)
#       k=f(i,j);
#       if ( is_saturated(i,j) )
#         mu_u(i,j) = mu(k);
#       else
#         mu_u(i,j) = mu(k) * r(k,j);
#       endif
#     endfor
#   endfor

#   ## End initialization step

#   ## Iteration step
#   iter_count = 1;

#   do

#     old_mu_u = mu_u;
#     old_mu_d = mu_d;
    
#     ##  
#     ## Step 1
#     ##
#     for j=1:M      

#       P(1:C(j)+N(j)+1,j) = compute_P(j)';

#       ##
#       ## 1.1 Calculate P_s(j) using (3)    
#       ##
#       P_s( j ) = compute_P_s( j );
      
#       ##
#       ## 1.2 Calculate mu_u(i,k) using (7) for all k \in D_j where f(i,k)=j
#       ##
#       for k=D(j)
#         i = f_inverse_i(j,k);
#         mu_u(i,k) = compute_mu_u(i,k);
#       endfor    
#     endfor
    
#     ## 
#     ## Step 2
#     ##
#     for j=M:-1:1      

#       ##P(1:C(j)+N(j)+1,j) = compute_P(j)';       

#       ##
#       ## 2.1 Calculate mu_d(j) using (5)
#       ##
#       mu_d(j) = compute_mu_d(j);
      
#       ##
#       ## 2.2 Calculate P_b i(n:j) using (4) for n=0:N_j-1, i=1:N_j
#       ##
#       for i=1:N(j)        
#         for n=1:N(j)
#           b_u(i,n+1,j) = compute_b_u(i,n,j);
#         endfor
#       endfor
#       for i=1:N(j)
#         for n=0:N(j)-1
#           P_b(i,n+1,j) = compute_P_b( i, n, j );
#         endfor
#       endfor      
#     endfor
    
#     err1 = abs( old_mu_d - mu_d );
#     err2 = abs( old_mu_u - mu_u );
#     iter_count++;
    
#   until ( ( (err1 < epsilon) && (err2 < epsilon) ) || (iter_count > iter_count_max) );

#   fprintf("Converged in %d iterations\n", iter_count );

#   result = zeros( M, C_max+1 );
#   for j=1:M
#     ## P_j = compute_P(j);   
#     result(j,[1:C(j)]) = P([1:C(j)],j)';
#     result(j,C(j)+1) = sum( P([C(j)+1:C(j)+N(j)+1],j ) );
#   endfor
  
# endfunction


##############################################################################
## usage: result = f( i, j )
##
## f(i,j) is the (scalar) index of the ith upstream server directly linked to
## buffer B_j. This function is defined on p. 186 of [1]. Valid ranges
## for the parameters are j=1..M, i=1..N(j). This function aborts on
## parameters out of range.
function result = f( i, j )
  global r; # not modified
  ( i>=1 && i <= N(j) ) || error( "f() i-index out of bound" );
  ( j>=1 && j <= size(r,1)) || error( "f() j-index out of bound" );
  result = U(j)(i);
endfunction
%!test
%! global r mu0;
%! r = [0 1 1 0; 0 0 1 1; 0 0 0 1; 1 0 0 0];
%! mu0 = [1 0 1 0];
%! assert( f(1,3), 7 );
%! assert( f(2,3), 1 );
%! assert( f(3,3), 2 );


##############################################################################
## Usage: result = is_saturated( i,j )
##
## Returns 1 iff S_u i(j) is a saturated server (i.e., if S_u i(j)
## denotes an external arrival).
function result = is_saturated(i,j)
  global r mu0;
  M = size(r,2);
  if ( f(i,j) > M )
    assert( mu0(f(i,j)-M) > 0 );
    assert( i == 1 );
    result = 1;
  else
    result = 0;
  endif
endfunction
%!test
%! global r mu0;
%! r = [0 1 1 0; 0 0 1 1; 0 0 0 1; 1 0 0 0];
%! mu0 = [1 0 1 0];
%! assert( is_saturated(1,3), 1 );
%! assert( is_saturated(1,1), 1 );
%! assert( is_saturated(2,3), 0 );
%! assert( is_saturated(3,3), 0 );


##############################################################################
## usage: result = f_inverse_i( k, j )
##
## Returns the (scalar) index i such that f(i,j) = k. That is, returns the
## "position" of server S_k in the list of upstream servers of S_j.
## Valid ranges for the parameters are k=1..M, j=1..M. This function
## aborts on parameters out of range. It also aborts if no index i
## exists such that f(i,j) = k.
function result = f_inverse_i( k, j )
  global r; # never modified
  ( j>=1 && j<=size(r,1) ) || error( "f_inverse_i() - j parameter out of range" );
  result = find( U(j) == k );
  ( !isempty(result) ) || error( "f_inverse_i() - could not find inverse" );
  ( f(result,j) == k ) || error( "f_inverse_i() - wrong result" );
endfunction
%!test
%! global r mu0;
%! r = [0 1 1 0; 0 0 1 1; 0 0 0 1; 1 0 0 0];
%! mu0 = [1 0 1 0];
%! assert( f_inverse_i(7,3), 1 );
%! assert( f_inverse_i(1,3), 2 );
%! assert( f_inverse_i(2,3), 3 );


##############################################################################
## usage: result = omega( n, j )
##
## Computes the scalar value \Omega_n(j), as defined on [1] p. 188. This
## function examines the global variable blocking_type to determine
## which variant of \Omega_n should be computed, and returns the
## appropriate result.
function result = omega( n, j )
  if ( get_blocking_type(j) == 0 )
    result = omega_BAS( n, j );
  else
    result = omega_RSB( n, j );
  endif
endfunction


##############################################################################
## usage: result = omega_prime( n, i, j )
##
## Computes the scalar value \Omega^i_n(j), as defined on [1] p. 189.
## This function examines the global variable blocking_type to determine
## which variant of \Omega^i_n should be computed, and returns the
## appropriate result.
function result = omega_prime( n, i, j )
  if ( get_blocking_type(j) == 0 )
    result = omega_prime_BAS( n, i, j );
  else
    result = omega_prime_RSB( n, i, j );
  endif
endfunction


##############################################################################
## usage: omega_BAS( n, j )
##
## Computes \Omega_n according to the upper part of Fig. 5, p. 188 on
## [1]. This function implements the Blocking-After-Service version of
## \Omega_n. Valid ranges for the parameter are n=0..N(j), j=1..M. This
## function aborts on parameters out of range. Note that \Omega_0 is
## defined to be 1, according to [2], p. 1125
function result = omega_BAS( n, j )
  global mu_u;

  ( n>=0 && n<=N(j) ) || error( "omega_BAS() n parameter is invalid" );
  ( j>=1 && j<=size(mu_u,2) ) || error( "omega_BAS() j parameter is invalid" );

  if ( n == 0 )
    result = 1;
  else
    combs = nchoosek( [1:N(j)], n );
    el = mu_u( :, j )'; # Gets the array of elements of the j-th column
    result = sum( prod( el( combs ), 2 ) );
  endif
endfunction
%!test
%! global mu_u r mu mu0;
%! M=3;
%! mu_u = 10*rand(M); # to amplify errors
%! r = ones(M);
%! mu = zeros(1,2*M);
%! mu0 = zeros(1,M);
%! expected_result = mu_u(1,2)*mu_u(2,2) + mu_u(1,2)*mu_u(3,2) + mu_u(2,2)*mu_u(3,2);
%! assert(omega_BAS(2,2), expected_result);
%! assert(omega_BAS(0,2),1);


##############################################################################
## usage: result = omega_prime_BAS( n, i, j )
##
## Computes \Omega^i_n for BAS blocking, according to [1], p. 189.
function result = omega_prime_BAS( n, i, j )
  global mu_u; # not modified

  ( i>0 && i<=N(j) ) || error( "omega_prime_BAS() i-index out of range" );
  ( j>0 && j<=size(mu_u,2) ) || error( "omega_prime_BAS() j-index out of range" );
  ( n>=0 && n<N(j) ) || error( "omega_prime_BAS() n-index out of range" );

  if ( n == 0 )
    result = 1;
  else
    combs = nchoosek( [ 1:i-1 , i+1:N(j)], n );
    el = mu_u( :, j )'; # Gets the array of elements of the j-th column
    result = sum( prod( el( combs ), 2 ) );
  endif
endfunction
%!test
%! global mu_u r mu mu0;
%! mu_u = 10*rand(3); # to aplify errors
%! mu = zeros(1,6);
%! mu0 = zeros(1,3);
%! r = ones(3);
%! M = 3;
%! assert(omega_prime_BAS(2,2,2), prod(mu_u([1,3],2)) );
%! assert(omega_prime_BAS(2,1,2), prod(mu_u([2,3],2)) );
%! assert( omega_prime_BAS(0,1,1), 1 );

%!test
%! global mu_u r mu mu0;
%! M=4;
%! mu_u = rand(M);
%! mu = zeros(1,2*M);
%! mu0 = zeros(1,M);
%! r = ones(M);
%! assert( omega_prime_BAS(3,1,3), prod([ mu_u(2,3) mu_u(3,3) mu_u(4,3) ]) );


##############################################################################
## Usage: result = omega_RSB( n, j )
##
## Computes \Omega_n for Repetitive-Service blocking, according to [1],
## fig. 6 p. 188.
function result = omega_RSB( n, j )
  global mu_u;

  ( n>=0 && n<=N(j) ) || error( "omega_RSB() n parameter is invalid" );
  ( j>0 && j<=size(mu_u,2) ) || error( "omega_RSB() j parameter is invalid" );

  if ( n == 0 || n == N(j) ) ## FIEME???
    result = 1;
  else
    combs = nchoosek( [2:N(j)], n );
    el = (mu_u( :, j )'); # Gets the array of elements of the j-th column
    result = sum( prod( el( combs ), 2 ) );
  endif
endfunction
%!test
%! global mu_u r mu mu0;
%! M=4;
%! mu_u = rand(M);
%! mu = zeros(1,2*M);
%! mu0 = zeros(1,M);
%! r = ones(M);
%! tmp = mu_u(:,2)';
%! expected_result = sum( prod( tmp( [ 2 3; 2 4; 3 4 ] ), 2 ) );
%! assert(omega_RSB(2,2), expected_result);
%! assert(omega_RSB(0,2), 1);


##############################################################################
## Usage: result = omega_prima_RSB( n, i, j )
##
## Computes \Omega^i_n for Repetitive-Service blocking, according to
## [1], p. 189. Note the following assumption: we assume that
## omega_prime_RSB( i, B(j)-1, j ) == 1, even if the value of
## omega_prime_RSB for this special case is not considered in [1].
function result = omega_prime_RSB( n, i, j )
  global mu_u;

  ( i>0 && i<=N(j) ) || error( "omega_prime_RSB() i-index out of range" );
  ( j>0 && j<=size(mu_u,2) ) || error( "omega_prime_RSB() j-index out of range" );
  ( n>=0 && n<N(j) ) || error( "omega_prime_RSB() n-index out of range" );

  if ( n == 0 || n == N(j)-1 ) ## FIXME???
    result = 1;
  else
    combs = nchoosek( [ 2:i-1 , i+1:N(j)], n );
    el = (mu_u( :, j )'); # Gets the array of elements of the j-th column
    result = sum( prod( el( combs ), 2 ) );
  endif
endfunction
%!test
%! global mu_u r mu mu0;
%! M=4;
%! mu_u = rand(M);
%! mu = zeros(1,2*M);
%! mu0 = zeros(1,M);
%! r = ones(M);
%! tmp = mu_u(:,2)';
%! expected_result = mu_u(2,2)*mu_u(3,2) +  mu_u(2,2)*mu_u(4,2) + mu_u(3,2)*mu_u(4,2);
%! assert(omega_prime_RSB(2,1,2), expected_result);
%! assert(omega_prime_RSB(2,2,2), mu_u(3,2)*mu_u(4,2) );
%! assert(omega_prime_RSB(2,3,2), mu_u(2,2)*mu_u(4,2) );
%! assert(omega_prime_RSB(0,1,2), 1);

##############################################################################
## Usage: compute_mu_u(i,j)
##
## Uses eq (7) from [1] to compute \mu_u i (j), i=1..M, j=1..M. The
## result is a scalar value. WARNING: eq (7) is porbably wrong, as it is
## different from the one used in Lemma 1, p. 191 [1]. Here we use
## 1/mu_d(k) instead of 1/mu(k).
function result = compute_mu_u( i, j )
  global mu P_s r P_b mu_d mu_u;

  k = f(i,j);
  assert( k<=size(r,1) );
  mu_star_k = sum( mu_u([1:N(k)],k) );

#   result = r(k,j)/(P_s(k)/mu_star_k + 1/mu(k) -
#                    r(k,j)*
#                    sum( P_b(i,[1:N(j)],j) .* [1:N(j)]) / mu_d(j));

  ## FIXME! Equation (7) is probably wrong. Check Lemma 1 p. 191
  result = r(k,j)/(P_s(k)/mu_star_k + 1/mu_d(k) - r(k,j)*sum( P_b(i,[1:N(j)],j) .* [1:N(j)])/mu_d(j));
endfunction


##############################################################################
## Usage: result = compute_mu_d(j)
##
## Uses eq. (5) from [1] to compute \mu_d (j), j=1..M. The result is a
## scalar value. WARNING: Eq (5) is probably wrong: here we use sum(
## P_b(k,[1:N(m)],m) .* [1:N(m)] ) instead of sum( P_b(k,[1:N(j)],m) .*
## [1:N(j)] ).
function result = compute_mu_d( j )
  global mu_d P_b mu r;

  ( j>0 && j <= size(r,1)) || error( "compute_mu_d() - j index out of bound" );

  s = 0;
  for m=D(j)
    k = f_inverse_i(j,m);
    ## s += r(j,m) * sum( P_b(k,[1:N(j)],m) .* [1:N(j)] ) / mu_d(m);

    ## FIXME: Cambiato in accordo alla tesi di Bovino
    s += r(j,m) * sum( P_b(k,[1:N(m)],m) .* [1:N(m)] ) / mu_d(m);
  endfor
  result = 1/( 1/mu(j) + s );
  ## If j is an exit server, then result must be equal to mu(j)
  if ( size( D(j), 2 ) == 0 )
    assert( result, mu(j) );
  endif
endfunction


##############################################################################
## Usage: result = compute_P_s(j)
##
## Uses eq. (3) from [1] to compute P_s(j), j=1..M. P_s(j) is the
## probability that S_d(j) is starved (i.e., is empty) at the service
## completion instant.
function result = compute_P_s( j )
  global r P;
  #P = compute_P(j);
  M = size(r,2);
  (j>=1 && j<=M) || error( "compute_P_s() - j index out of bound" );
  result = P(2,j) / ( 1 - P(1,j) );
endfunction


##############################################################################
## Usage: result = compute_P(j)
##
## Computes P(n:j) by solving the appropriate birth-death process. This
## function returns a (1 x C(j)+N(j)+1 ) vector, where result(i) ==
## P(i+1,j), i = 1..C(j)+N(j)+1
function result = compute_P( j )
  global C;
  if ( get_blocking_type(j) == 0 )
    result = compute_P_BAS(j);
  else
    result = compute_P_RSB(j);
  endif
  ## Check that successive marginal probabilities for nonblocking
  ## states are equal each other. This is stated in [2], p. 1126
  if ( C(j) >= 3 )
    for i=0:C(j)-2
      assert( result(i+2)/result(i+1), result(i+3)/result(i+2), 1e-4 );
    endfor
  endif
endfunction


##############################################################################
## Usage: result = compute_P_BAS(j)
##
## Compute P(n,j) for each n=0..C(j)+N(j) by solving the birth-death
## process. Returns a (1 x 1+C(j)+N(j)) vector
function result = compute_P_BAS( j )
  global mu_u mu_d C;
  assert( get_blocking_type(j) == 0 );

  ## Defines the transition probability matrix for the MC
  mu_star_j = sum( mu_u([1:N(j)],j) );
  assert( mu_star_j, sum( mu_u(:,j) ) );  

  ## computes the steady-state probability
  birth = zeros( 1, C(j)+N(j) );
  death = mu_d(j) * ones( 1, C(j)+N(j) );
  birth(1,[1:C(j)] ) = mu_star_j;
  for i=1:N(j)
    birth( 1, C(j)+i ) = i*omega_BAS(i,j)/omega_BAS(i-1,j);
  endfor
  result = ctmc_bd_solve( birth, death );
endfunction


##############################################################################
## Usage: result = compute_P_RSB( j )
##
## Same as compute_P, for Repetitive-service blocking
function result = compute_P_RSB( j )
  global mu_u mu_d C;
  assert( get_blocking_type(j) != 0 );

  ## Defines the transition probability matrix for the MC
  mu_star_j = sum( mu_u([1:N(j)],j) );
  assert( mu_star_j, sum( mu_u(:,j) ) );  
  
  ## computes the steady-state probability
  birth = zeros( 1, C(j)+N(j)-1 );
  death = mu_d(j) * ones( 1, C(j)+N(j)-1 );
  birth(1,[1:C(j)] ) = mu_star_j;
  for i=1:N(j)-1
    birth( 1, C(j)+i ) = i*omega_RSB(i,j)/omega_RSB(i-1,j);
  endfor
  result = [ ctmc_bd_solve( birth, death ) 0 ];
endfunction


##############################################################################
## Usage: result = compute_P_b( i, n, j )
##
## Compute P_b i(n:j) using (4), where n=0..N(j)-1, i=1..N(j), j=1..M
## The result is a scalar value.
function result = compute_P_b( i,n,j )
  global b_u C P;

  ( n >= 0 && n < N(j) ) || error( "compute_P_b() - n index out of bound" );
  ( i >= 1 && i <= N(j) ) || error( "compute_P_b() - i index out of bound" );
  ##  P = compute_P(j);
  M = size(C,2);

  result = ( P(C(j)+n+1,j) - b_u(i,n+1,j) ) / ( 1 - sum( b_u( i, [2:(N(j)+1)], j ) ) );
  ## FIXME: the next seems necessary
#   if ( get_blocking_type(j) == 1 &&  n == N(j)-1 )
#     assert( result, 0 );
#   endif
endfunction


##############################################################################
## Usage: result = compute_b_u(i,n,j)
##
## Compute b_u i(n:j) using (1), i=1..M, n=0..N(j), j=1..M. The result
## is a single scalar element. According to [2], we let b_u i(0:j) = 0.
function result = compute_b_u(i,n,j)
  global mu_u C P;
  M = size( C,2 );
  ( i>0 && i<=M ) || error( "compute_b_u() - i index out of bound" );
  ( j>0 && j<=M ) || error( "compute_b_u() - j index out of bound" );
  ( n >= 0 && n <= N(j) ) || error( "compute_b_u() - n index out of bound" );
  if ( n == 0 )
    result = 0;
  else
    ## P = compute_P( j );
    result = mu_u(i,j) * omega_prime( n-1,i,j ) / omega(n,j) * P(C(j)+n+1,j);
  endif
  if ( get_blocking_type(j) == 1 && n == N(j) )
    assert( result, 0 );
  endif
endfunction


##############################################################################
## Usage: result = U( i )
##
## Returns a vector of the i-th element in the set U, that is, returns
## the index of the upstream servers for S_i, i=1..M
##
## @param r the MxM routing matrix
##
## @param mu0 the vector of external arrivals
function result = U( i )
  global r mu0;
  M = size(r,2);
  ( i>0 && i<=M ) || error( "U() - i index out of bound" );
  result = find( r(:,i) > 0 )';
  if ( mu0( i ) > 0 )
    result = [ M+i result ];
  endif
endfunction
%!test
%! global r mu0;
%! r = [0 1 1 0; 0 0 1 1; 0 0 0 1; 1 0 0 0];
%! mu0 = [1 0 1 0];
%! assert( U(1), [5 4] );
%! assert( U(3), [7 1 2] );


##############################################################################
## Usage: result = D( i )
##
## Given the routing matrix r, computes the downstream index set D_i.
## D_i is defined as the set of indexes of downstream servers directly
## connected with S_i.
function result = D( i )
  global r;
  ( i>0 && i<=size(r,1) ) || error( "D() - i index out of bound" );
  result = find( r(i,:) > 0 );
endfunction
%!test
%! global r;
%! r = [0 1 1 0; 0 0 1 1; 0 0 0 1; 1 0 0 0];
%! assert( D(2), [3 4] );


##############################################################################
## Usage: result = N( i )
##
## Returns a scalar representing the number of upstream servers of S_i,
## that is, returns the number of elements in U(i); i=1..M
function result = N( i )
  global r;
  ( (i>0) && (i<=size(r,1)) ) || error( "N() - i index out of bound" );
  result = size( U(i), 2 );
endfunction
%!test
%! global r mu0;
%! r = [0 1 1 0; 0 0 1 1; 0 0 0 1; 1 0 0 0];
%! mu0 = [1 0 1 0];
%! assert( N(1), 2 );
%! assert( N(3), 3 );


##############################################################################
## Usage: result = get_blocking_type( j )
##
## Returns the blocking type for server S_u1(j); result == 0 means BAS,
## result == 1 means RSB.
function result = get_blocking_type( j )
  global r mu0 blocking_type;
  M = size(r,2);
  ## If blocking_type(j) != 0 and mu0(j) > 0, then result == 1
  ## (Repetitive-Service Blocking). Otherwise, result == 0 (BAS)
  ( j >= 1 && j <= size(mu0,2) ) || error( "get_blocking_type() - j \
      parameter out of bounds" );
  if ( f(1,j) <= M )
    result = 0; # non-saturated servers are always BAS
    return
  endif
  k = f(1,j) - M;
  assert( mu0(k) > 0 );
  if ( blocking_type(k) != 0 )
    result = 1; # repetitive-service blocking
  else
    result = 0; # BAS
  endif
endfunction
%!test
%! global r mu0 blocking_type;
%! r = [0 1 1 0; 0 0 1 1; 0 0 0 1; 1 0 0 0];
%! mu0 = [1 0 1 0];
%! blocking_type = [1 0 1 0];
%! assert( get_blocking_type(1), 1 );
%! assert( get_blocking_type(2), 0 );
%! assert( get_blocking_type(3), 1 );
%! assert( get_blocking_type(4), 0 );

# %!test
# %! r = [0 0.35 0.35; 0 0 0.65; 0 0 0];
# %! C = [ 2 2 3 ];
# %! mu = [ 2 1.5 1 ];
# %! mu0 = [ 1.2 0.3 0.2 ];
# %! P1 = lee_et_al_98( mu, mu0, C, r, [ 1 1 1 ] );
# %! P2 = lee_et_al_98_acyclic( mu, mu0, C, r, [ 1 1 1 ] );
# %! assert( P1, P2, 1e-4 );


##############################################################################
## Usage: compute_X_u(i,j)
##
## Computes X_ui(j) using eq. (10) from Lee et al. [1]
function result = compute_X_u(i,j)
  global P_b mu_d mu_u;
  result = 1/( 1/mu_u(i,j) + 1/mu_d(j) * dot( P_b(i,[1:N(j)],j), [1:N(j)] ) );
endfunction


##############################################################################
## Usage: compute_X_d(k)
##
## Computes X_d(k) using eq. (9) from Lee et al. [1]
function result = compute_X_d(k)
  global P_s mu_d mu_u;
  mu_star_k = sum(mu_u([1:N(k)],k));
  result = 1/( 1/mu_d(k) + P_s(k)/mu_star_k );
endfunction


##############################################################################
## Usage: print_header()
##
## Prints the header used for the demo results
function print_header()
  printf("%10s\t%5s\t%5s %5s\t%5s %5s %4s\n", \
         "Param", "Exact", "This", "Err%", "Paper", "Err%", "Res" );
endfunction


##############################################################################
## Usage: compare( param, simulation, result, paper)
##
## This is a function used in the demos
##
## @param param The string representing the parameter name
##
## @param simulation The simulation result shown in the paper
## 
## @param result The result computed by this implementation
##
## @param paper The result copmputed by the algorithm shown in the paper
function compare( param, simulation, result, paper )
  
  err_res = ( result - simulation ) / simulation * 100;
  err_pap = ( paper - simulation ) / simulation * 100;
  tolerance = 1e-3;

  if ( abs( result - paper ) < tolerance )
    test_result = "PASS";
  else
    test_result = "FAIL";
  endif
  printf("%10s\t%5.3f\t%5.3f %5.1f\t%5.3f %5.1f %4s\n", param, simulation, result, err_res, paper, err_pap, test_result );

endfunction

##############################################################################
### 
### Start "real" tests 
###

%!demo
%! disp("Table V, p. 1130 Lee & Pollock [2]");
%! r = [ 0 0.4 0.4; \
%!       0 0   0.7; \
%!       0 0   0    ];
%! C = [ 20 2 2 ];
%! mu = [ 2 2 2 ];
%! mu0 = [ 1.5 0 0 ];
%! result = lee_et_al_98( mu, mu0, C, r, [ 1 0 0 ] );
%! assert( get_blocking_type(1), 1 );
%! assert( get_blocking_type(2), 0 );
%! assert( get_blocking_type(3), 0 );
%! assert( f(1,1), 4 );
%! assert( f(1,2), 1 );
%! assert( f(1,3), 1 );
%! assert( f(2,3), 2 );
%! print_header();
%! compare( "P_1(0)", 0.1560, result(1,1), 0.1516 );
%! compare( "P_1(1)", 0.1297, result(1,2), 0.1287 );
%! compare( "P_1(2)", 0.1085, result(1,3), 0.1091 );
%! compare( "P_1(3)", 0.0914, result(1,4), 0.0926 );
%! compare( "P_1(4)", 0.0772, result(1,5), 0.0786 );
%! compare( "P_1(5)", 0.0654, result(1,6), 0.0666 );
%! compare( "P_2(0)", 0.6557, result(2,1), 0.6473 );
%! compare( "P_2(1)", 0.2349, result(2,2), 0.2357 );
%! compare( "P_2(2)", 0.1094, result(2,3), 0.1170 );
%! compare( "P_3(0)", 0.4901, result(3,1), 0.4900 );
%! compare( "P_3(1)", 0.2667, result(3,2), 0.2662 );
%! compare( "P_3(2)", 0.2431, result(3,3), 0.2438 );

%!demo
%! disp("Table IV, p. 1130 Lee & Pollock [2]");
%! r = [ 0 0.4 0.4; \
%!       0 0   0.5; \
%!       0 0   0 ];
%! C = [ 1 1 1 ];
%! mu = [ 1 1 1 ];
%! mu0 = [ 3.0 0 0 ];
%! result = lee_et_al_98( mu, mu0, C, r, [ 1 0 0 ] );
%! print_header();
%! compare( "P_1(0)", 0.2154, result(1,1), 0.2092 );
%! compare( "P_1(1)", 0.7846, result(1,2), 0.7909 );
%! compare( "P_2(0)", 0.7051, result(2,1), 0.6968 );
%! compare( "P_2(1)", 0.2949, result(2,2), 0.3032 );
%! compare( "P_3(0)", 0.6123, result(3,1), 0.6235 );
%! compare( "P_3(1)", 0.3877, result(3,2), 0.3765 );

%!demo
%! disp("Table X first group, p 1132 Lee & Pollock [2]");
%! r = [0 0.35 0.35; \
%!      0 0    0.65; \
%!      0 0    0 ];
%! C = [ 5 4 3 ];
%! mu = [ 1 1 1 ];
%! mu0 = [ 2 0.2 0.1 ];
%! result = lee_et_al_98( mu, mu0, C, r, [ 1 1 1 ] )
%! print_header();
%! compare( "P_1(5)", 0.558, result(1,6), 0.558 );
%! compare( "P_2(4)", 0.074, result(2,5), 0.074 );
%! compare( "P_3(3)", 0.279, result(3,4), 0.282 );

%!demo
%! disp("Table X, second group, p. 1132 Lee & Pollock [2]");
%! r = [0 0.35 0.35; \
%!      0 0    0.65; \
%!      0 0    0 ];
%! C = [ 2 2 3 ];
%! mu = [ 2 1.5 1 ];
%! mu0 = [ 1.2 0.3 0.2 ];
%! result = lee_et_al_98( mu, mu0, C, r, [ 1 1 1 ] )
%! print_header();
%! compare( "P_1(2)", 0.269, result(1,3), 0.272 );
%! compare( "P_2(2)", 0.193, result(2,3), 0.206 );
%! compare( "P_3(3)", 0.374, result(3,4), 0.391 );

%!demo
%! disp("Table 1 first group, p. 195 Lee & al. [1]");
%! r = [0   1   0; \
%!      0   0   1; \
%!      0.1 0   0  ];
%! C = [ 2 2 2 ];
%! mu = [ 1 1 1 ];
%! mu0 = [ 1 0 0 ];
%! result = lee_et_al_98( mu, mu0, C, r, [ 1 0 0 ] )
%! print_header();
%! compare( "P_1(0)", 0.206, result(1,1), 0.210 );
%! compare( "P_1(2)", 0.458, result(1,3), 0.483 );
%! compare( "P_2(0)", 0.265, result(2,1), 0.287 );
%! compare( "P_2(2)", 0.450, result(2,3), 0.452 );
%! compare( "P_3(0)", 0.376, result(3,1), 0.389 );
%! compare( "P_3(2)", 0.334, result(3,3), 0.335 );

%!demo
%! disp("Table 1, second group, p. 195 Lee & al. [1]");
%! r = [0   1   0; \
%!      0   0   1; \
%!      0.1 0   0  ];
%! C = [ 1 1 1 ];
%! mu = [ 1.5 1.5 1.5 ];
%! mu0 = [ 1 0 0 ];
%! result = lee_et_al_98( mu, mu0, C, r, [ 1 0 0 ] )
%! print_header();
%! compare( "P_1(0)", 0.510, result(1,1), 0.478 );
%! compare( "P_1(1)", 0.490, result(1,2), 0.522 );
%! compare( "P_2(0)", 0.526, result(2,1), 0.532 );
%! compare( "P_2(1)", 0.474, result(2,2), 0.468 );
%! compare( "P_3(0)", 0.610, result(3,1), 0.620 );
%! compare( "P_3(1)", 0.390, result(3,2), 0.380 );

%!demo
%! disp("Table 2, first group, p. 196 Lee & al. [1]");
%! r = [0   0.2 0.2 0.3;   \
%!      0   0   0.6 0.3; \
%!      0   0   0   0.8; \
%!      0.1 0   0   0    ];
%! C = [ 1 1 1 1 ];
%! mu = [ 1 0.5 0.5 1 ];
%! mu0 = [ 1 0.2 0.2 0 ];
%! result = lee_et_al_98( mu, mu0, C, r, [ 1 1 1 0 ] )
%! print_header();
%! compare( "P_1(0)", 0.364, result(1,1), 0.338 );
%! compare( "P_1(1)", 0.636, result(1,2), 0.662 );
%! compare( "P_2(0)", 0.490, result(2,1), 0.477 );
%! compare( "P_2(1)", 0.510, result(2,2), 0.523 );
%! compare( "P_3(0)", 0.389, result(3,1), 0.394 );
%! compare( "P_3(1)", 0.611, result(3,2), 0.606 );
%! compare( "P_4(0)", 0.589, result(4,1), 0.589 );
%! compare( "P_4(1)", 0.411, result(4,2), 0.411 );

%!demo
%! disp("Table 3, left column, p. 197 Lee & al. [1]");
%! r = [0   0.3 0   0   0.3 0   0   0.4;   \
%!      0   0   1   0   0   0   0   0; \
%!      0   0   0   1   0   0   0   0; \
%!      0   0.1 0   0   0   0   0   0.9; \
%!      0   0   0   0   0   1   0   0; \
%!      0   0   0   0   0   0   1   0; \
%!      0   0   0   0   0.1 0   0   0.9; \
%!      0   0   0   0   0   0   0   0 ];
%! C = [ 2 2 2 2 2 2 2 2 ];
%! mu = [ 1.5 1 1 1 1 1 1 1.5 ];
%! mu0 = [ 1 0.2 0 0 0.2 0 0 0 ];
%! result = lee_et_al_98( mu, mu0, C, r, [ 0 0 0 0 0 0 0 0] )
%! global mu_d;
%! assert( mu_d(8), mu(8) );
%! print_header();
%! compare( "P_1(0)", 0.220, result(1,1), 0.221 );
%! compare( "P_1(2)", 0.547, result(1,3), 0.539 );
%! compare( "P_2(0)", 0.434, result(2,1), 0.426 );
%! compare( "P_2(2)", 0.306, result(2,3), 0.309 );
%! compare( "P_3(0)", 0.415, result(3,1), 0.406 );
%! compare( "P_3(2)", 0.315, result(3,3), 0.318 );
%! compare( "P_4(0)", 0.377, result(4,1), 0.373 );
%! compare( "P_4(2)", 0.348, result(4,3), 0.352 );
%! compare( "P_5(0)", 0.434, result(5,1), 0.426 );
%! compare( "P_5(2)", 0.305, result(5,3), 0.309 );
%! compare( "P_6(0)", 0.416, result(6,1), 0.406 );
%! compare( "P_6(2)", 0.315, result(6,3), 0.318 );
%! compare( "P_7(0)", 0.376, result(7,1), 0.373 );
%! compare( "P_7(2)", 0.363, result(7,3), 0.352 );
%! compare( "P_8(0)", 0.280, result(8,1), 0.274 );
%! compare( "P_8(2)", 0.492, result(8,3), 0.492 );

##############################################################################
##
## This is the first bunch of tests. Here we compare the result from the
## Lee et al. algorithm with those obtained from the (exact) MVA for
## open, single class networks. Assuming that there is enough buffer
## space in the original network, the result from Lee et al and MVA
## should be almost exactly the same.

%!test
%! #printf("Simple tandem network with enough buffer space");
%! r = [ 0 1 0; \
%!       0 0 1; \
%!       0.1 0 0];
%! C = 20 * ones(1,3);
%! mu=[ 2 2 2 ];
%! mu0=[ 1 0 0 ];
%! result = lee_et_al_98( mu, mu0, C, r, [1 0 0] );
%! Q_lee = zeros(1,3);
%! [U R Q_mva] = qnopen( 1, 1 ./ mu, qnvisits(r, mu0) );
%! for i=1:3
%!   Q_lee(i) = dot( result(i,:), [0:C(i)] );
%!   #printf("Q(%d) Lee=%5.3f MVA=%5.3f\n", i, Q_lee(i), Q_mva(i) );
%!   assert( Q_lee(i), Q_mva(i), 1e-4 );
%! endfor

%!test
%! #printf("Table 2, third group, p. 196 Lee & al. [1], enough buffer space");
%! r = [0   0.2 0.2 0.3;   \
%!      0   0   0.6 0.3; \
%!      0   0   0   0.8; \
%!      0.1 0   0   0    ];
%! C = 20*ones(1,4);
%! mu = [ 2 1 1 2 ];
%! mu0 = [ 1 0.2 0.2 0 ];
%! result = lee_et_al_98( mu, mu0, C, r, [ 1 1 1 0 ] );
%! Q_lee = zeros(1,4);
%! [U R Q_mva] = qnopen( 1, 1 ./ mu, qnvisits(r, mu0 ) );
%! for i=1:4
%!   Q_lee(i) = dot( result(i,:), [0:C(i)] );
%!   #printf("Q(%d) Lee=%5.3f MVA=%5.3f\n", i, Q_lee(i), Q_mva(i) );
%!   assert( Q_lee(i), Q_mva(i), 1e-2 );
%! endfor

%!test
%! #printf("Table 3, right column, p. 197 Lee & al. [1], enough buffer space");
%! r = [0   0.3 0   0   0.3 0   0   0.4;   \
%!      0   0   1   0   0   0   0   0; \
%!      0   0   0   1   0   0   0   0; \
%!      0   0.1 0   0   0   0   0   0.9; \
%!      0   0   0   0   0   1   0   0; \
%!      0   0   0   0   0   0   1   0; \
%!      0   0   0   0   0.1 0   0   0.9; \
%!      0   0   0   0   0   0   0   0 ];
%! C = 20*ones(1,8);
%! mu = [ 2 1.5 1.5 1.5 1.5 1.5 1.5 2 ];
%! mu0 = [ 1 0.2 0 0 0.2 0 0 0 ];
%! result = lee_et_al_98( mu, mu0, C, r, [0 0 0 0 0 0 0 0] );
%! Q_lee = zeros(1,8);
%! [U R Q_mva] = qnopen( 1, 1./ mu, qnvisits(r, mu0) );
%! for i=1:8
%!   Q_lee(i) = dot( result(i,:), [0:C(i)] );
%!   #printf("Q(%d) Lee=%5.3f MVA=%5.3f\n", i, Q_lee(i), Q_mva(i) );
%!   assert( Q_lee(i), Q_mva(i), 1e-2 );
%! endfor


