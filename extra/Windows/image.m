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
## length of the colormap.  If @var{zoom} is omitted, the image will be
## scaled to fit within 600x350 (to a max of 4).
##
## It first tries to use @code{display} from @code{ImageMagick} then
## @code{xv} and then @code{xloadimage}.
##
## The axis values corresponding to the matrix elements are specified in
## @var{x} and @var{y}. At present they are ignored.
## @end deftypefn
## @seealso{imshow, imagesc, and colormap}

## Author: Tony Richardson <arichard@stark.cc.oh.us>
## Created: July 1994
## Adapted-By: jwe
## Modifications for MSwindows by aadler, 2002

function image (x, y, A, zoom)
  if (nargin == 0)
    ## Load Bobbie Jo Richardson (Born 3/16/94)
    A = loadimage ("default.img");
    zoom = [];
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
    zoom = min ([350/rows(A), 600/columns(A), 4]);
    if (zoom >= 1)
      zoom = floor (zoom);
    else
      zoom = 1 / ceil (1/zoom);
    endif
  endif
  bmp_name = [tmpnam () , ".bmp"];

  map = colormap();
  [m2,n2]=size(map);
  # A is index into colourmap - remove 1 for C indexing
  bmpwrite(A-1, map, bmp_name );

  # we use the explorer to display the image here
  # the advantage is that it can scale the image size
  # using the html code
  htm_name = [tmpnam() , ".htm"];

  fid= fopen( htm_name, "w");
  if fid == -1
     error( ["Can't open ", htm_name," for writing"] );
  end
  fprintf(fid,"<HTML><BODY><IMG HEIGHT='%d' WIDTH='%d' SRC='%s'></BODY></HTML>",
              rows(A)*zoom, columns(A)*zoom, bmp_name );
  fclose ( fid );

  # cleanup is a pain here, because explorer doen't return
  # any useful error codes , and "forks" itself into
  # the background, so you don't know when its finished

  system( ['( explorer file:///' , htm_name , ...
           ' ; sleep 5 ; rm ', bmp_name, ' ', htm_name, ' ) &' ] );
  
endfunction
