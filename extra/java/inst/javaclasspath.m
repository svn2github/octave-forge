## Copyright (C) 2007 Michael Goffioul
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function file} {@var{P} =} javaclasspath
##
## Returns the dynamic class path of the Java virtual machine in
## the form of a cell array of strings. If no output variable is
## given, the result is simply printed on the standard output.
##
## @end deftypefn
## @seealso{javaaddpath}

function varargout = javaclasspath

  c_path = java_invoke ("org.octave.ClassHelper", "getClassPath");
  path_list = split (c_path, ';');

  switch nargout
  case 0
    if (! isempty (path_list))
      disp(path_list);
    endif
  case 1
    varargout{1} = cellstr (path_list);
  endswitch

endfunction
