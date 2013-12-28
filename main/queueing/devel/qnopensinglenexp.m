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
## @deftypefn {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}] =} qnopensinglenexp (@var{lambda}, @var{S}, @var{V}) 
## @deftypefnx {Function File} {[@var{U}, @var{R}, @var{Q}, @var{X}] =} qnopensingle (@var{lambda}, @var{S}, @var{V}, @var{m})
##
## Approximate analysis of open queueing networks
## with general arrival and service time distributions.
##
## @strong{INPUTS}
##
## @table @var
##
## @item lambda
## @code¬@var{lambda}(i,r)} is the external arrival rate of class-@math{r}
## requests at service center @math{i}.
##
## @item P
## @code{@var{P}(i,j,r)} is the probability that a class-@math{r}
## request moves to center @math{j} after completing service at center
## @math{i}.
##
## @item mu
## mu(i,r) service rate of class-r jobs at center i
##
## @item m
## m(i) is the number of servers at center i
##
## @end table
##
## Reference: Bolch et al., p. 439-444.
##
## @end deftypefn

## Author: Moreno Marzolla <moreno.marzolla(at)unibo.it>
## Web: http://www.moreno.marzolla.name/

##
## WORK IN PROGRESS: DO NOT USE!!
##
function qnopensinglenexp( l0, c20ir, P, mu, m, c2ir )

  error("This function is work in progress. Do not use it yet");

  N = size(l0,1); # number of service centers
  R = size(l0,2); # number of classes
  lir = zeros(N, R); # arrival rate to node i of class r
  for r=1:R # FIXME: avoid loop
    lir(:,r) = l0(:,r) \ ( eye(N) - P(:,:,r) );
  endfor
  lijr = zeros(N, N, R); # arrival rate from node i to node j of class r
  for i=1:N # FIXME: avoid loop
    for j=1:N
      for r=1:R
	lijr(i,j,r) = lir(i,t)*P(i,j,r);
      endfor
    endfor
  endfor
  li = sum(lir,2); # arrival rate to node i
  roir = zeros(N,R); # utilization of node i due to customers of class r
  for i=1:N
    for r=1:R
      roir(i,r) = lir(i,r) / (m(i)*mu(i,r));
    endfor
  endfor
  roi = sum(roir,2); # utilization of node i
  mui = zeros(1,N); # mean service rate of node i
  for i=1:N
    mui(i) = 1 / ( sum( lir(i,:) ./ li(i) ./ (m(i) .* muir(i,:)) ) );
  endfor
  c2Bi = zeros(1,N); # squared coefficient of variation of service time of node i
  for i=1:N
    c2Bi(i) = -1 + sum( lir(i,:) ./ li(i) .* (mu(i) ./ (m(i) .* mu(i,:)).^2 .* c2ir(i,:) + 1 ) );
  endfor
  c2ijr = ones(N, N, R);
  c2Air = zeros(N,R);
  c2Ai = c2Di = zeros(1,N);
  while 1==1
    ## merging
    c2Air(i,:) = 1./lir(i,:) .* sum( c2ijr(j,i,:));
    ## flow
  endwhile
		      
endfunction
