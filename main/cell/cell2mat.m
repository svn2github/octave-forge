## Copyright (C) 2005 Laurent Mazet
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
## along with this program; if not, write to the Free Software
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

## -*- texinfo -*-
## @deftypefn {Function File} {@var{m} = } cell2mat (@var{c})
##
## Converts the cell @var{c} into a matrix. @var{c} cannot mix string
## with numerical or logical data. The number of columns of @var{m} is
## determined by the sum of all columns of the first row and the number
## of rows is ajusted by the total number of elements.
##
## @end deftypefn
##@c @seealso{}

## 2005-01-13
##   initial release

function [m] = cell2mat(c)

  ## check argument
  if nargin != 1
    error("cell2mat: you must supply one arguments\n");
  endif
  if !iscell(c)
    error("cell2mat: c has to be a cell\n");
  endif
  
  ## number of elements
  nb = numel(c);

  ## some trivial cases
  if nb == 0
    m = [];
    return
  elseif nb == 1
    if isnumeric(c{1}) || ischar(c{1}) || islogical(c{1})
      m = c{1};
    elseif iscell(c{1})
      m = cell2mat(c{1})
    else
      error("cell2mat: type %s is not handled properly\n", typeinfo(c{1}));
    endif
    return
  endif

  ## n dimensions case
  for k=ndims(c):-1:2,
    sz = size (c);
    sz (end) = 1;
    c1 = cell (sz);
    for i=1:prod(sz),
      c1{i} = cat (k, c{i:prod(sz):end});
    endfor
    c = c1;
  endfor
  m = cat(1, c1{:});

endfunction

## Tests
%!shared C, D, E, F
%! C = {[1], [2 3 4]; [5; 9], [6 7 8; 10 11 12]};
%! D = C; D(:,:,2) = C;
%! E = [1 2 3 4; 5 6 7 8; 9 10 11 12];
%! F = E; F(:,:,2) = E;
%!assert (cell2mat(C), E);
%!test
%! if [1e6,1e4,1]*str2num(split(version,'.')) > 2010064
%!   assert (cell2mat(D), F);  % crashes octave 2.1.64
%! endif

## Demos
%!demo
%! C = {[1], [2 3 4]; [5; 9], [6 7 8; 10 11 12]};
%! cell2mat(C)

## Local Variables: ***
## mode: Octave ***
## End: ***
