## Copyright (C) 2009 VZLU Prague, a.s., Czech Republic
##
## Author: Jaroslav Hajek <highegg@gmail.com>
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
## along with this program; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn{Function File} {d =} dict (@var{keys}, @var{values})
## @deftypefnx{Function File} {d =} dict ()
## Creates a dictionary object with given keys and values. @var{keys}
## should be a cell vector of strings; @var{values} should be a cell vector
## with matching size. @var{values} can also be a singleton array, in
## which case it is expanded to the proper size; or omitted, in which case
## the default value of empty matrix is used.
## If neither @var{keys} nor @var{values} are supplied, an empty dictionary
## is constructed.
##
## A dictionary can be indexed either by a single string or cell array of
## strings, like this:
##
## @example
##   d = dict (keys, values);
##   d(str) # result is a single value
##   d(cellstr) # result is a cell array
## @end example
##
## In the first case, the stored value is returned directly; in the second case,
## a cell array is returned. The cell array returned inherits the shape of the index.
## 
## Similarly, indexed assignment works like this:
##
## @example
##   d = dict (keys, values);
##   d(str) = val; # store a single value
##   d(cellstr) = vals; # store a cell array
##   d(cellstr) = []; # delete a range of keys
## @end example
##
## Any keys that are not present in the dictionary are added. The values of
## existing keys are overwritten. In the second case, the lengths of index and
## rhs should match or rhs should be a singleton array, in which case it is
## broadcasted. 
##
## @end deftypefn
function d = dict (keys, values)

  if (nargin == 0)
    d = struct ("keys", {cell(0, 1)}, "values", {cell(0, 1)});
  elseif (nargin <= 2)
    if (iscellstr (keys) && isvector (keys))
      [d.keys, ind] = sort (keys(:));
    else
      error ("dict: keys must be a cell vector of strings");
    endif
    if (nargin == 1)
      d.values = cell (size (d.keys));
    elseif (iscell (values) && isvector (values))
      ## Hack: we use this weird shape to let indexed values always inherit the
      ## shape of the index. This would not work if we just used values(:).
      d.values = reshape (values (ind), 1, 1, length (values));
    else
      error ("dict: values must be a cell vector");
    endif
  else
    print_usage ();
  endif

  d = class (d, "dict");

endfunction

%!test
%! free = dict ();
%! free({"computing", "society"}) = {true};
%! assert (free("computing"), free("society"));
