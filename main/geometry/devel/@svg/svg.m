## Copyright (C) 2011 Carnë Draug <carandraug+dev@gmail.com>
## Copyright (c) 2011 Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, see <http://www.gnu.org/licenses/>.

## @deftypefn {Function File} {@var{obj} =} svg ()
## Create object @var{obj} of the svn class.
##
## @seealso{@svn/plot}
## @end deftypefn

function obj = svg

  if (nargin != 0)
    print_usage ;
  endif

  obj = struct;
  obj = class (obj, 'svg');

endfunction
