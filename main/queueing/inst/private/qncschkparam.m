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
## @deftypefn {Function File} {[@var{err} @var{N} @var{S} @var{V} @var{m} @var{Z}] = } qncchkparam( N, S, ... )
##
## Validate input parameters for closed, single class networks.
## @var{err} is the empty string on success, or a suitable error message
## string on failure.
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [err N S V m Z] = qncschkparam( varargin )
  
  err = "";

  assert( nargin >= 2 );

  N = varargin{1};

  S = varargin{2};

  [V m Z] = deal(0);

  if ( !isscalar(N) || N<0 )
    err = "N must be a nonnegative scalar";  
    return;
  endif

  if ( !isvector(S) || length(S)<=0 )
    err = "S must be a nonempty vector";
    return;
  endif

  if ( any(S<0) )
    err = "S must contain nonnegative values";
    return;
  endif

  S = S(:)';
  if ( nargin < 3 )
    V = ones(size(S));
  else
    V = varargin{3};

    if ( ! isvector(V) )
      err =  "V must be a vector";
      return;
    endif
    if ( any(V<0) )
      err =  "V must contain nonnegative values";
      return;
    endif
    V = V(:)';
  endif

  if ( nargin < 4 ) 
    m = ones(size(S));
  else
    m = varargin{4};

    if ( ! isvector(m) )
      err = "m must be a vector";
      return;
    endif
    m = m(:)';
  endif

  [er S V m] = common_size(S, V, m);
  if (er != 0 )
    err = "S, V and m are of incompatible size";
    return;
  endif

  if ( nargin < 5 )
    Z = 0;
  else
    Z = varargin{5};

    if ! ( isscalar(Z) && Z >= 0 )
      err = "Z must be a nonnegative scalar";
      return;
    endif
  endif
endfunction
