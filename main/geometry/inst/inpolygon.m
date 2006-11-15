## Copyright (C) 2006 Frederick (Rick) A Niles, Søren Hauberg
##
## This file is intended for use with Octave.
##
## This file can be redistriubted under the terms of the GNU General
## Public License.

## -*- texinfo -*-
##
## @deftypefn {Function File} {[@var{IN}, @var{ON}] = } inpolygon (@var{X}, @var{Y}, @var{xv}, @var{xy})
##
## For a polygon defined by (@var{xv},@var{yv}) points, determine if the
## points (X,Y) are inside or outside the polygon.  @var{X}, @var{Y},
## @var{IN} must all have the same dimensions. The optional output "ON"
## will give point on the polygon. 
##
## @end deftypefn

## Author: Frederick (Rick) A Niles <niles@rickniles.com>
## Created: 14 November 2006

## Vectorized by Søren Hauberg <soren@hauberg.org>

## The method for determining if a point is in in a polygon is based on
## the algorithm shown on
## http://local.wasp.uwa.edu.au/~pbourke/geometry/insidepoly/ and is
## credited to Randolph Franklin.

function [IN ON] = inpolygon (X, Y, xv, yv)

  if (length (xv) != length (xv))
    error ("inpolygon: polygon lengths not equal between x and y")
  endif

  if ( length (X) != length (Y) )
    error ("inpolygon: input points lengths not equal between x and y");
  endif

  IN = zeros (size(X), "logical");
  ON = zeros (size(X), "logical");

  npol = length(xv);

  for i = 1:npol
    j = mod(i, npol)+1;
    idx = ( ( ((yv(i) <= Y) & (Y < yv(j))) | ((yv(j) <= Y) & (Y < yv(i))) ) &
              (X * (yv(j) - yv(i)) + xv(i)) < (xv(j) - xv(i)) * (Y - yv(i)) );
    IN(idx) = !IN(idx);
  endfor
  if (nargout == 2)
    for i=1:npol-1
      idx = ( (xv(i+1)-xv(i))*(Y-yv(i)) == (yv(i+1) - yv(i)) * (X-xv(i)));
      ON(idx) = true;
    endfor
  endif

endfunction



