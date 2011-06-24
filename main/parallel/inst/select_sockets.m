## Copyright (C) 2010 Olaf Till <olaf.till@uni-jena.de>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA

## -*- texinfo -*-
## @deftypefn {Function File} {[@var{n}, @var{idx}] =} select_sockets
## (@var{sockets}, @var{timeout}[, @var{nfds}])
##
## Calls Unix @code{select}.
##
## @var{sockets}: valid sockets matrix as returned by @code{connect}.
##
## @var{timeout}: seconds, negative for infinite.
##
## @var{nfds}: optional, default is Unix' FD_SETSIZE (platform
## specific). Passed to Unix @code{select} as the first argument --- see
## there.
##
## An error is returned if nfds or a watched filedescriptor plus one
## exceeds FD_SETSIZE.
##
## Return values are: @var{idx}: index vector to rows in @var{sockets}
## with pending input, readable with @code{recv}. @var{n}: number of
## rows in @var{sockets} with pending input.
## @end deftypefn

function [n, ridx] = select_sockets (varargin)

  if ((nargin = columns (varargin)) < 2 || nargin > 3)
    error ("two or three arguments required");
  endif

  if (! ismatrix (sockets = varargin{1}) || rows (sockets) < 1 || \
      columns (sockets) != 3)
    error ("no valid sockets matrix");
  endif

  [n, ridx] = \
      select (cat \
	      (2, {varargin{1}(:, 1)}, {[], []}, varargin(2:end)){:});

endfunction
