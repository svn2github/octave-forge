## Copyright (C) 2009 Dmitry Kolesnikov
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
## @deftypefn {Function File} {[@var{U} @var{R} @var{Q} @var{X} @var{p0} @var{pK}] =} qnmmmk_alt (@var{lambda}, @var{mu}, @var{m}, @var{K} )
##
## @cindex @math{M/M/m/K} system
##
## Compute utilization, response time, average number of requests and
## throughput for a @math{M/M/m/K} finite capacity system. In a
## @math{M/M/m/K} queue there are @math{m \geq 1} service centers. At any
## moment, at most @math{K} requests can be in the system, @math{K
## \geq m}.
##
## @iftex
##
## The steady-state probability @math{\pi_k} that there are @math{k}
## jobs in the system, @math{0 \leq k \leq K} can be expressed as:
##
## @tex
## $$
## \pi_k = \cases{ \displaystyle{{\rho^k \over k!} \pi_0} & if $0 \leq k \leq m$;\cr
##                 \displaystyle{{\rho^m \over m!} \left( \rho \over m \right)^{k-m} \pi_0} & if $m < k \leq K$\cr}
## $$
## @end tex
##
## where @math{\rho = \lambda/\mu} is the offered load. The probability
## @math{\pi_0} that the system is empty can be computed by considering
## that all probabilities must sum to one: @math{\sum_{k=0}^K \pi_k = 1},
## which gives:
##
## @tex
## $$
## \pi_0 = \left[ \sum_{k=0}^m {\rho^k \over k!} + {\rho^m \over m!} \sum_{k=m+1}^K \left( {\rho \over m}\right)^{k-m} \right]^{-1}
## $$
## @end tex
##
## @end iftex
##
## @strong{INPUTS}
##
## @table @var
##
## @item lambda
##
## Arrival rate (jobs/@math{s}, @code{@var{lambda}>0}).
##
## @item mu
##
## Service rate (jobs/@math{s}, @code{@var{mu}>0}).
##
## @item m
##
## Number of servers (@code{@var{m}>=1}).
##
## @item k
##
## Maximum number of requests allowed in the system (@code{@var{k} >= @var{m}}).
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @var
##
## @item U
##
## Service center utilization
##
## @item R
##
## Service center response time
##
## @item Q
##
## Average number of requests in the system
##
## @item X
##
## Service center throughput
##
## @item p0
##
## Probability that there are no requests in the system.
##
## @item pK
##
## Probability that there are @math{K} requests in the system (i.e., 
## probability that the system is full).
##
## @end table
##
## @var{lambda}, @var{mu}, @var{m} and @var{K} can be vectors of the
## same size. In this case, the results will be vectors as well.
##
## @seealso{qnmm1,qnmminf,qnmmm}
##
## @end deftypefn

## Author: Dmitry Kolesnikov
function [U R Q X p0 pm pk] = qnmmmk_alt( lambda, mu, m, k)
  if ( nargin != 4 )
    print_usage();
  endif
  [err lambda mu m k] = common_size( lambda, mu, m, k );
  if ( err ) 
    error( "Parameters are not of common size" );
  endif

  ( isvector(lambda) && isvector(mu) && isvector(m) && isvector(k) ) || ...
      error( "lambda, mu, m, k must be vectors of the same size" );
  all( k>0 ) || ...
      error( "k must be strictly positive" );
  all( m>0 ) && all( m <= k ) || ...
      error( "m must be in the range 1:k" );
  all( lambda>0 ) && all( mu>0 ) || ...
      error( "lambda and mu must be >0" );
  
  rho = lambda ./ mu;
  i1 = 0:m; # range
  i2 = (m+1):k; # range
  p0 = 1 / ( sum( rho .^ i1 ./ factorial(i1) ) + rho^m/factorial(m)*sum( (rho/m).^(i2-m) ) );
  pm = p0 * (rho)^m / factorial(m);
  pk = p0 * rho^k / (factorial(m) * m^(k-m));
  Q = (sum( i1 .* rho .^ i1 ./ factorial(i1) ) + ...
       rho^m/factorial(m)*sum( i2.*((rho/m).^(i2-m)) ))*p0;
  X = lambda*(1-pk);
  U = X ./ (m .* mu );
  R = Q./X;

endfunction
%!test
%! lambda = 0.8;
%! mu = 0.85;
%! k = 5;
%! [U1 R1 Q1 X1 p01 pm pk1] = qnmmmk_alt( lambda, mu, 1, k );
%! [U2 R2 Q2 X2 p02 pk2] = qnmm1k( lambda, mu, k );
%! assert( [U1 R1 Q1 X1 p01 pk1], [U2 R2 Q2 X2 p02 pk2], 1e-5 );

%!test
%! lambda = 0.8;
%! mu = 0.85;
%! m = 3;
%! k = 5;
%! [U1 R1 Q1 X1 p01] = qnmmmk_alt( lambda, mu, m, k );
%! [U2 R2 Q2 X2 p02] = qnmmmk( lambda, mu, m, k );
%! assert( [U1 R1 Q1 X1 p01], [U2 R2 Q2 X2 p02], 1e-5 );
