## Copyright (C) 2008 Bill Denney
##
## This software is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## This software is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this software; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {indices =} datefind (subset, superset, tol)
##
## Find any instances of the @code{subset} in the @code{superset} with
## the @code{tol}erance.  @code{tol} is 0 by default.
##
## @seealso{date, datenum}
## @end deftypefn

## Author: Bill Denney <bill@denney.ws>
## Created: 21 Jan 2008

function idx = datefind (subset, superset, tol)

  if nargin == 2
	tol = 0;
  end
  idx = [];
  for i = 1:numel (subset)
	newidx = find (superset(:) >= subset(i)-tol & superset(:) <= subset(i)+tol);
	idx = [idx;newidx(:)];
  end

endfunction

