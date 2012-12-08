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
## @deftypefn {Function File} {[@var{err} @var{N} @var{S} @var{V} @var{m} @var{Z}] = } qncmchkparam( N, S, ... )
##
## Validate input parameters for closed, multiclass network.
## @var{err} is the empty string on success, or a suitable error message
## string on failure.
##
## @end deftypefn

## Author: Moreno Marzolla <marzolla(at)cs.unibo.it>
## Web: http://www.moreno.marzolla.name/

function [err N S V m Z] = qncmchkparam( varargin )
  
  err = "";

  assert( nargin >= 2 );

  N = varargin{1};

  S = varargin{2};

  [V m Z] = deal(0);

  if ( !isvector(N) || length(N)==0 )
    err = "N must be a nonempty vector";
    return;
  endif

  if ( any(N<0) )
    err = "N must contain nonnegative values";
    return;
  endif

  N = N(:)';

  C = length(N); ## Number of classes

  if ( !ismatrix(S) || rows(S) != C )
    err = sprintf("S must be a matrix with %d rows",C);
    return;
  endif

  if ( any(S(:)<0) )
    err = "S must contain nonnegative values";
    return;
  endif

  K = columns(S);

  if ( nargin < 3 )
    V = ones(size(S));
  else
    V = varargin{3};
    if ( !ismatrix(V) || rows(V) != C || columns(V) != K )
      err = sprintf("V must be a %d x %d matrix", C, K );
      return;
    endif

    if ( any(V(:)<0) )
      err = "V must contain nonnegative values";
      return;
    endif
  endif

  if ( nargin < 4 ) 
    m = ones(1,K);
  else
    m = varargin{4};
    if (!isvector(m) || length(m) != K ) 
      err = sprintf("m must be a vector with %d elements", K );
      return;
    endif
    m = m(:)';
  endif

  if ( nargin < 5 )
    Z = zeros(1,C);
  else
    Z = varargin{5};
    if (!isvector(Z) || length(Z) != C)
      err = sprintf("Z must be a vector with %d elements", C);
      return;
    endif
    if ( any(Z<0) )
      err = "Z must contain nonnegative values";
      return;
    endif
    Z = Z(:)';
  endif
endfunction
