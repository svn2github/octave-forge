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
## @deftypefn {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}] =} qnclosedbsb (@var{N}, @var{D})
## @deftypefnx {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}] =} qnclosedbsb (@var{N}, @var{D}, @var{Z})
##
## @cindex bounds, balanced system
## @cindex closed network
##
## This function computes Balanced System Bounds for throughput and response
## time of closed, single class queueing networks. Multiclass networks
## might be supported in the future.
##
## This function dispatches the computation to @code{qnclosedsinglebsb}.
##
## @seealso{qnclosedsinglebsb}
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [Xl Xu Rl Ru] = qnclosedbsb( N, varargin )
  if ( nargin < 2 || nargin > 5 )
    print_usage();
  endif

  if (isscalar(N))
    [Xl Xu Rl Ru] = qnclosedsinglebsb(N, varargin{:});
  else
    [Xl Xu Rl Ru] = qnclosedmultibsb(N, varargin{:});
  endif
endfunction
