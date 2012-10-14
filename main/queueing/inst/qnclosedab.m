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
## @deftypefn {Function File} {[@var{Xl}, @var{Xu}, @var{Rl}, @var{Ru}] =} qnclosedab (@var{N}, @dots{})
##
## @cindex bounds, asymptotic
## @cindex closed network
##
## This function computes Asymptotic Bounds for throughput and response
## time of closed, single or multiclass queueing networks. Single server
## and delay centers are allowed. Multiple server nodes are not
## supported.
##
## This function dispatches the computation to @code{qnclosedsingleab}
## or @code{qnclosedmultiab}.
##
## @itemize
##
## @item If @var{N} is a scalar, the network is assumed to have a single
## class of requests and control is passed to @code{qnclosedsingleab}.
##
## @item If @var{N} is a vector, the network is assumed to have multiple
## classes of requests, and control is passed to @code{qnclosedmultiab}.
##
## @end itemize
##
## @seealso{qnclosedsingleab, qnclosedmultiab}.
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [Xl Xu Rl Ru] = qnclosedab( N, varargin )
  if ( nargin < 1 )
    print_usage();
  endif

  if (isscalar(N))
    [Xl Xu Rl Ru] = qnclosedsingleab(N, varargin{:});
  else
    [Xl Xu Rl Ru] = qnclosedmultiab(N, varargin{:});
  endif
endfunction

