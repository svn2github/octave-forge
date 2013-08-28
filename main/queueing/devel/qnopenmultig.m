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
## @deftypefn {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}] =} qnopenmultig (@var{lambda}, @var{c2lambda}. @var{mu}, @var{c2mu}, @var{P})
##
## Approximate analysis of open, multiple-class networks with general
## arrival and service time distributions (@code{qnopenmultig} stands
## for "OPEN, MULTIclass, General"). Single server and multiple server
## nodes are supported. This function assumes a network with @math{K}
## service centers and @math{C} customer classes.
##
## @strong{INPUTS}
##
## @table @var
##
## @item lambda
## @code{@var{lambda}(c, k)} is the external
## arrival rate of class @math{c} customers at center @math{k}.
##
## @item c2lambda
## @code{@var{c2lambda}(c, k)} is the squared coefficient of variation of
## class @math{c} arrival rate at center @math{k}
##
## @item mu
## @code{@var{mu}(c,k)} is the mean service rate of class @math{c}
## customers on the service center @math{k} (@code{@var{S}(c,k)>0}).
##
## @item c2mu
## @code{@var{c2mu}(c,k)} is the squared Coefficient of variation of class
## @math{c} service rate at center @math{k}
##
## @item P
## @code{@var{P}(r,i,s,j)} is the probability that a class @math{r}
## request which completes service at center @math{i} is routed
## to center @math{j} as class @math{s} request. @strong{Class
## switching is not supported}: therefore, @math{P(r,i,s,j) = 0}
## if @math{r \neq s}.
##
## @item m
## @code{@var{m}(k)} is the number of servers at service center
## @math{k}.
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @var
##
## @item U
## @code{@var{U}(c,k)} is the
## class @math{c} utilization of center @math{k}.
##
## @item R
## @code{@var{R}(c,k)} is the class @math{c} response time at
## center @math{k}. The system response time for
## class @math{c} requests can be computed
## as @code{dot(@var{R}, @var{V}, 2)}.
##
## @item Q
## @code{@var{Q}(c,k)} is the average number of class @math{c} requests
## at center @math{k}. The average number of class @math{c} requests
## in the system @var{Qc} can be computed as @code{Qc = sum(@var{Q}, 2)}
##
## @item X
## @code{@var{X}(c,k)} is the class @math{c} throughput
## at center @math{k}.
##
## @end table
##
## @seealso{qnopen,qnopensingle,qnvisits}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/
function [U R Q X] = qnopenmultig( l0, c20, mu, c2, P, m )

  error("This function is not fully implemented yet");

  if ( nargin < 5 || nargin > 6 )
    print_usage();
  endif

  ismatrix(l0) || ...
      usage("lambda must be a matrix");
  
  C = rows(l0);
  K = columns(l0);

  size(c20) == size(l0) || ...
      usage("c20 must have the same size of lambda");

  size(mu) == size(l0) || ...
      usage("mu must have the same size of lambda");

  size(c2) == size(l0) || ...
      usage("c2 must have the same size of lambda");

  ismatrix(P) && ndims(P) == 4 && [C,K,C,K] == size(P) || ...
      usage("Wrong size of matrix P (I was expecting %dx%dx%dx%d)", C, K, C, K);

  if ( nargin < 6 )
    m = ones(1,K);
  else
    ( isvector( m ) && length(m) == K && all( m >= 1 ) ) || ...
        usage( "m must be >= 1" );
    m = m(:)'; # make m a row vector
  endif

  ## Class switching is not allowed. Therefore, to be compliant with the
  ## reference above (Bolch et al.), we drop one dimension from matrix P
  P_ijr = zeros(K,K,C);
  for r=1:C
    P_ijr(:,:,r) = P(r,:,r,:);
  endfor
#{
  for i=1:K
    for j=1:K
      for r=1:C
        P_ijr(i,j,r) = P(r,i,r,j);
      endfor
    endfor
  endfor
#}

  l = sum(sum(l0)) .* qnvisits(P,l0);

  c2A_ir = c2D_ir = zeros(K,C);
  c2A_i_old = c2A_i = c2B_i = c2D_i = zeros(1,K);
  c2_ijr = ones(K,K,C);

  ## the implementation that follows is based on Section 10.1.3 (p.
  ## 439--441) of Bolch et al. In order to be facilitate debugging, we
  ## make ourselves compliant with their notation. This means that class
  ## and server indexes need to be swapped, e.g., they use rho(i,r)
  ## instead of rho(r,i) to denote the class-r utilization on center i.

  lambda_ir = l';
  lambda0_ir = l0';
  c20_ir = c20';
  c2B_i = c2_ir = c2';
  mu_ir = mu';

  lambda_i = sum(lambda_ir,2); # lambda_i(i) is the total arrival rate at center i

  rho_ir = zeros(K,C); # rho_ir(i,r) is the class r utilization at center i
  for r=1:C # FIXME: parallelize this
    for i=1:K
      rho_ir(i,r) = lambda_ir(i,r) / ( m(i) * mu_ir(i,r) );
    endfor
  endfor

  rho_i = sum(rho_ir,2); # rho_i(i) is the utilization of center i

  mu_i = zeros(1,K); # mu_i(i) is the mean service rate at center i
  for i=1:K
    mu_i(i) = 1 / sum( rho_ir(i,:) ./ lambda_i(i) );
  endfor

  do 

    c2A_i_old = c2A_i;

    ## Decomposition of Whitt
    
    ## Merging
    for r=1:C
      for i=1:K
        c2A_ir(i,r) = 1 / lambda_ir(i,r) * ...
            (c20_ir(i,r)*lambda0_ir(i,r) + ...
             sum( c2_ijr(:,i,r) .* lambda_ir(:,r) .* P_ijr(:,i,r) ) );
      endfor
    endfor
    
    for i=1:K
      c2A_i(i) = 1 / lambda_i(i) * sum(c2A_ir(i,:) .* lambda_ir(i,:) );
    endfor
    
    ## Coeff of variation

    for i=1:K
      c2B_i(i) = -1 + sum( lambda_ir(i,:)/lambda_i(i) .* ...
                          ( mu_i(i) / (m(i) * mu_ir(i,:))).^2 .* ...
                          (c2_ir(i,:)+1) );
    endfor

    ## Flow (Pujolle)
    for i=1:K
      c2D_i(i) = 1 + (rho_i(i)^2 * (c2B_i(i) - 1) / sqrt(m(i))) + ...
          (1 - rho_i(i)^2)*(c2A_i(i) - 1);
#{
      c2D_i(i) = rho_i(i)^2 * (c2B_i(i)+1) +...
          (1-rho_i(i))*c2A_i(i) + ...
          rho_i(i)*(1-2*rho_i(i));
#}
    endfor

    ## Splitting
    for i=1:K
      for j=1:K
        for r=1:C
          c2_ijr(i,j,r) = 1 + P_ijr(i,j,r) * (c2D_i(i) - 1);
        endfor
      endfor
    endfor

  until ( norm(c2A_i - c2A_i_old, "inf") < 1e-3 );

endfunction

%!demo
%! C = 1; K = 4;
%! P=zeros(C,K,C,K);
%! P(1,1,1,2) = .5;
%! P(1,1,1,3) = .5;
%! P(1,3,1,1) = .6;
%! P(1,2,1,1) = P(1,4,1,1) = 1;
%! mu = [25 33.333 16.666 20];
%! c2B = [2 6 .5 .2];
%! c20 = [0 0 0 4];
%! lambda = [0 0 0 4];
%! qnwhitt(lambda, c20, mu, c2B, P );
