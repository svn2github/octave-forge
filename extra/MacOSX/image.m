## Copyright (C) 1996, 1997 John W. Eaton
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
## Software Foundation, 59 Temple Place - Suite 330, Boston, MA
## 02111-1307, USA.

## -*- texinfo -*-
## @deftypefn {Function File} {} image (@var{x}, @var{zoom})
## @deftypefnx {Function File} {} image (@var{x}, @var{y}, @var{A}, @var{zoom})
## Display a matrix as a color image.  The elements of @var{x} are indices
## into the current colormap and should have values between 1 and the
## length of the colormap.  
## 
## The axis values corresponding to the matrix elements are specified in
## @var{x} and @var{y}. At present they are ignored.
##
## The @var{zoom} option is ignored on Mac OS X.
##
## The image is displayed by the application set as the default for
## opening .bmp files (defaults to Preview.app).  
## @end deftypefn
## @seealso{imshow, imagesc, and colormap}

## Author: Tony Richardson <arichard@stark.cc.oh.us>
## Created: July 1994
## Adapted-By: jwe
## Mac OS X adaptation by J. Koski 6/24/04

function image (x, y, A, zoom)

  if (nargin == 0)
    ## Load Bobbie Jo Richardson (Born 3/16/94)
    A = loadimage ("default.img");
    zoom = 2;
  elseif (nargin == 1)
    A = x;
    zoom = [];
    x = y = [];
  elseif (nargin == 2)
    A = x;
    zoom = y;
    x = y = [];
  elseif (nargin == 3)
    zoom = [];
  elseif (nargin > 4)
    usage ("image (matrix, zoom) or image (x, y, matrix, zoom)");
  endif

  if isempty(zoom)
    ## Find an integer scale factor which sets the image to
    ## approximately the size of the screen.
    ## N.B. This parameter is discarded on OS X. 
    zoom = min ([350/rows(A), 600/columns(A), 4]);
    if (zoom >= 1)
      zoom = floor (zoom);
    else
      zoom = 1 / ceil (1/zoom);
    endif
  endif

  ## Mac OS X - write .bmp file to Preview.app 
  temp_name = tmpnam();
  bmp_name = [temp_name, '.bmp'];
  colors = colormap();
  bmpwrite(A, colors, bmp_name); 
  mark_for_deletion(bmp_name);
  system(['open ', bmp_name]);

endfunction
