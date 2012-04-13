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
## @deftypefn {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}] =} qnclosedbsb (@var{N}, @var{D})
## @deftypefnx {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}] =} qnclosedbsb (@var{N}, @var{D}, @var{Z})
##
## @cindex bounds, balanced system
## @cindex closed network
##
## Compute Balanced System Bounds for single-class, closed Queueing Networks
## with @math{K} service centers.
##
## @strong{INPUTS}
##
## @table @var
##
## @item N
## number of requests in the system (scalar).
##
## @item D
## @code{@var{D}(k)} is the service demand at center @math{k};
## @code{@var{K}(k) @geq{} 0}.
##
## @item Z
## external delay (think time, scalar, @code{@var{Z} @geq{} 0}). If
## omitted, it is assumed to be zero.
##
## @end table
##
## @strong{OUTPUTS}
##
## @table @var
##
## @item Xl
## @itemx Xu
## Lower and upper bound on the system throughput.
##
## @item Rl
## @itemx Ru
## Lower and upper bound on the system response time.
##
## @end table
##
## @seealso{qnclosedab, qnclosedgb, qnclosedpb}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [Xl Xu Rl Ru] = qnclosedbsb( N, D, Z )
  if ( nargin < 2 || nargin > 3 )
    print_usage();
  endif
  ( isscalar(N) && N>0 ) || \
      error( "N must be a positive scalar" );
  ( isvector(D) && length(D)>0 && all(D>=0) ) || \
      error( "D must be a vector of nonnegative floats" );
  if ( nargin < 3 )
    Z = 0;
  else
    ( isscalar(Z) && Z>=0 ) || \
        error( "Z must be a nonnegative scalar" );
  endif

  D_max = max(D);
  D_tot = sum(D);
  D_ave = mean(D);
  Xl = N/(D_tot+Z+( (N-1)*D_max )/( 1+Z/(N*D_tot) ) );
  Xu = min( 1/D_max, N/( D_tot+Z+( (N-1)*D_ave )/(1+Z/D_tot) ) );
  Rl = max( N*D_max-Z, D_tot+( (N-1)*D_ave )/( 1+Z/D_tot) );
  Ru = D_tot + ( (N-1)*D_max )/( 1+Z/(N*D_tot) );
endfunction

%!test
%! fail("qnclosedbsb(1)");
%! fail("qnclosedbsb(1, [])", "vector");
%! fail("qnclosedbsb(-1,[1 1 1], [1 1 1])", "positive scalar");
%! fail("qnclosedbsb(1,[-1 0 0], [1 1 1])", "nonnegative");
%! fail("qnclosedbsb(1,[0 0 0],-1)", "nonnegative scalar");
