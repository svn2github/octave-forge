## Copyright (C) 2009 Jaroslav Hajek
## Copyright (C) 2009 VZLU Prague, a.s., Czech Republic
##
## Author: Jaroslav Hajek <highegg@gmail.com>
## Several improvements thanks to: Travis Collier <travcollier@gmail.com>
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
## @deftypefn{Function File} [@var{o1}, @var{o2}, @dots{}] = pararrayfun (@var{nproc}, @var{fun}, @var{a1}, @var{a2}, @dots{})
## @deftypefnx{Function File} pararrayfun (nproc, fun, @dots{}, "UniformOutput", @var{val})
## @deftypefnx{Function File} pararrayfun (nproc, fun, @dots{}, "ErrorHandler", @var{errfunc})
## Evaluates a function for corresponding elements of an array. 
## Argument and options handling is analogical to @code{parcellfun}, except that
## arguments are arrays rather than cells. If cells occur as arguments, they are treated
## as arrays of singleton cells.
## @seealso{parcellfun, arrayfun}
## @end deftypefn

function varargout = pararrayfun (nproc, func, varargin)

  if (nargin < 3)
    print_usage ();
  endif

  nargs = length (varargin);

  recognized_opts = {"UniformOutput", "ErrorHandler", "VerboseLevel"};

  while (nargs >= 2)
    maybeopt = varargin{nargs-1};
    if (ischar (maybeopt) && any (strcmpi (maybeopt, recognized_opts)))
      nargs -= 2;
    else
      break;
    endif
  endwhile

  args = varargin(1:nargs);
  opts = varargin(nargs+1:end);

  args = cellfun (@num2cell, args, "UniformOutput", false,
  "ErrorHandler",  @arg_class_error);

  [varargout{1:nargout}] = parcellfun (nproc, func, args{:}, opts{:});

endfunction

function arg_class_error (S, X)
  error ("arrayfun: invalid argument of class %s", class (X))
endfunction

