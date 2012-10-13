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
## @deftypefn {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}] =} qnclosedmultibsb (@var{N}, @var{D})
## @deftypefnx {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}] =} qnclosedmultibsb (@var{N}, @var{D}, @var{Z})
##
## Not implemented yet
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [Xl Xu Rl Ru] = qnclosedmultibsb( N, D, Z )

  error("This function is not implemented yet");

  if ( nargin < 2 || nargin > 3 )
    print_usage();
  endif
  ( isvector(N) && all(N>0) ) || \
      error( "N must be a vector > 0" );
  N = N(:)'; # make N a row vector
  ( ismatrix(D) && rows(D) == length(N) && all(all(D>=0)) ) || \
      error( "wrong D size" );
  if ( nargin < 3 )
    Z = 0*N;
  else
    ( isvector(Z) && all(Z>=0) && length(Z) == length(N) ) || \
        error( "Z must be a vector >= 0" );
    Z = Z(:)';
  endif

  K = columns(D); # number of servers

  D_max = max(D,[],2)';
  D_min = min(D,[],2)';
  Xl = N ./ ((K+sum(N)-1) .* D_min);
  Xu = N ./ ((K+sum(N)-1) .* D_max);
endfunction

%!demo
%! D = [10 7 5 4; \
%!      5  2 4 6];
%! NN=20;
%! Xl = Xu = zeros(NN,2);
%! for n=1:NN
%!   N=[10,n];
%!   [a b] = qnclosedmultibsb(N,D);
%!   Xl(n,:) = a;
%!   Xu(n,:) = b;
%! endfor
%! subplot(2,1,1);
%! plot(1:NN,Xl(:,1),Xu(:,1));
%! subplot(2,1,2);
%! plot(1:NN,Xl(:,2),Xu(:,2));