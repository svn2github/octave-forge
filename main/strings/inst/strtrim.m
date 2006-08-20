## Copyright (C) 1996 Kurt Hornik
##
## This file is part of Octave.
##
## Octave is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## Octave is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, write to the Free
## Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
## 02110-1301, USA.

## -*- texinfo -*-
## @deftypefn {Function File} {} strtrim (@var{s})
## Remove leading and trailing blanks and nulls from @var{s}.  If @var{s}
## is a matrix, @var{strtrim} trims each row to the length of longest
## string.  If @var{s} is a cell array, operate recursively on each
## element of the cell array.
## @end deftypefn

## strtrim is based on deblank

## Author: Kurt Hornik <Kurt.Hornik@wu-wien.ac.at>
## Adapted-By: jwe
## Adapted-By: Alexander Barth <abarth@marine.usf.edu>

function s = strtrim (s)

  if (nargin != 1)
    usage ("strtrim (s)");
  endif

  if (ischar (s))

    k = find (! isspace (s) & s != "\0");
    if (isempty (s) || isempty (k))
      s = "";
    else
      k = ceil(k / rows(s));
      s = s(:,min(k):max(k));
    endif

  elseif (iscell(s))

    for i = 1:numel (s)
      s{i} = strtrim (s{i});
    endfor

  else
    error ("strtrim: expecting string argument");
  endif

endfunction
