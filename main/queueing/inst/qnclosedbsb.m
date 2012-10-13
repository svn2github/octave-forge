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
## @deftypefn {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}] =} qnclosedbsb (@var{N}, @dots{} )
##
## @cindex bounds, balanced system
## @cindex closed network
##
## Compute Balanced System Bounds for throughput and response
## time of closed networks with single or multiple classes of customers.
##
## This function dispatches the computation to @code{qnclosedsinglebsb}
## or @code{qnclosedmultibsb}.
##
## @seealso{qnclosedsinglebsb, qnclosedmultibsb}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [Xl Xu Rl Ru] = qnclosedbsb( N, varargin )
  if ( nargin < 1 )
    print_usage();
  endif
  if (isscalar(N))
    [Xl Xu Rl Ru] = qnclosedsinglebsb(N, varargin{:});
  else
    [Xl Xu Rl Ru] = qnclosedmultibsb(N, varargin{:});
  endif
endfunction

%!demo
%! S = [10 7 5 4; \
%!      5  2 4 6];
%! NN=20;
%! Xl = Xu = Xmva = zeros(NN,2);
%! for n=1:NN
%!   N=[n,10];
%!   [a b] = qnclosedbsb(N,S);
%!   [U R Q X] = qnclosedmultimva(N,S,ones(size(S)));
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