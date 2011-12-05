## Copyright (C) 2000 Kai Habel <kai.habel@gmx.de>
## Copyright (C) 2011 Carnë Draug <carandraug+dev@gmail.com>
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
## along with this program; If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} @var{bool} = isgray (@var{img})
## Return true if @var{img} is a grayscale image.
##
## A variable is considereed to be a gray scale image if it is 2-dimensional,
## non-sparse matrix, and:
## @itemize @bullet
## @item is of class double and all values are in the range [0, 1];
## @item is of class uint8 or uint16.
## @end itemize
##
## Note that grayscale time-series image have 4 dimensions (NxMx1xtime) but
## isgray will still return false.
##
## @seealso{isbw, isind, isrgb}
## @end deftypefn

function bool = isgray (img)

  if (nargin != 1)
    print_usage ();
  endif

  bool = false;
  if (ismatrix (img) && ndims (img) == 2 && !issparse (img) && !isempty (img))
    switch (class (img))
      case "double"
        ## to speed this up, we can look at a sample of the image first
        bool = is_gray_double (img(1:ceil (rows (img) /100), 1:ceil (columns (img) /100)));
        if (bool)
          ## sample was true, we better make sure it's real
          bool = is_gray_double (img);
        endif
      case {"uint8", "uint16"}
        bool = true;
    endswitch
  endif

endfunction

function bool = is_gray_double (img)
  bool = all ((img(:) >= 0 & img(:) <= 1) | isnan (img(:)));
endfunction
