## Copyright (C) 2009-2012 Martin Helm <martin@mhelm.de>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File}{[@var{cdata}] =} calc_shading (@var{amb}, @var{dif}, @var{spec}, @var{shine}, @var{colors}, @var{normals}, @var{lvec}, @var{vvec})
## 
##
## If called with one output argument returns 
## calculated color data for use with the patch function.
##
## @var{amb}, @var{dif}, @var{spec}, @var{shine} are the ambient, diffuse, 
## specular and specular exponent properties for the lighting.
##
## @var{colors} can be a one or three column matrix with the same length
## as the @var{normals} matrix of normal vectors.
##
## Alternatively a scalar or a RGB row vector can also be used for @var{colors}.
## The object has then a single color.
##
## @var{lvec}: The light direction
##
## @var{vvec}: The view direction
##
## Type
## @example
## @group
## demo calc_shading
## @end group
## @end example
## to see how it works.
##
## Without using fltk it will also work but is very slow.
##
## @seealso{isocolors, isonormals}
##
## @end deftypefn

## Author: Martin Helm <martin@mhelm.de>
## Created: 2009-12-24
## Credits: Kai Habel for his diffuse, specular and surfl functions

function [ cdat ] = calc_shading (amb, dif, spec, shine, \
                                 colors, normals, lvec, vvec)

  lvec /= norm (lvec); # normalize light vector
  vvec /= norm (vvec); # normalize view vector
  ## normalize the normal vectors
  normals = normals ./ repmat (sqrt (sumsq (normals, 2)), [1, 3]);
  
  ## if we have a single color, expand it
  if rows (colors) == 1
    colors = repmat (colors, [rows(normals), 1]);
  endif

  ## calculate the lighting

  if columns (colors) == 1
    ## if we have scalar colors do it the simple way
    lfactor = amb * ones (rows (normals), 1) \
        + dif * diffuse (normals(:, 1), normals(:, 2), normals(:, 3), lvec) \
        + spec * specular (normals(:, 1), normals(:, 2), normals(:, 3), \
                           lvec, vvec, shine);
    cdat = colors .* lfactor;
  else # we have rgb colors
    ## ambient and diffuse like in the scalar case
    lfactor = amb * ones (rows (normals), 1) \
        + dif * diffuse (normals(:, 1), normals(:, 2), normals(:, 3), lvec);
    lfactor = repmat (lfactor, [1, columns(colors)]);

    ## we use a white specular light for a better effect
    lf_spec = spec * specular (normals(:, 1), normals(:, 2), normals(:, 3), \
                               lvec, vvec, shine); 
    lf_spec = repmat (lf_spec, [1, columns(colors)]);

    cdat = colors .* lfactor .+ lf_spec;
  endif

endfunction

%!demo
%! graphics_toolkit fltk
%! clf
%! fun = @(x, y, z) cos(x) .+ cos(y) .+ cos(z);
%! points = linspace (-pi, pi, 51);
%! [x, y, z] = meshgrid (points);
%! f = fun (x, y, z);
%! [F, v] = isosurface (x, y, z, f, 1.1); 
%! vn = isonormals (x, y, z, f, v);
%! cdat = calc_shading (0.3, 0.4, 0.8, 15.0, [1.0 .0 .0], vn, [-1.0; -0.5; -.8], [-.5; 1.5; -.1]);
%! p = patch ("Faces", F, "Vertices", v, "FaceVertexCData", cdat, "FaceColor", "interp", "EdgeColor", "none"); 
%! view(30,30) 
%! grid on;
%! title(['Demo shading in red, Contour Value = ',num2str(1.1)]);
%! xlabel('X');ylabel('Y');zlabel('Z');
%! axis ([-pi, pi, -pi, pi, -pi, pi]);

%!demo
%! clf
%! fun = @(x, y, z) cos(x) .+ cos(y) .+ cos(z);
%! points = linspace (-pi, pi, 51);
%! [x, y, z] = meshgrid (points);
%! f = fun (x, y, z);
%! [F, v] = isosurface (x, y, z, f, 1.1); 
%! vn = isonormals (x, y, z, f, v);
%! c = isocolors (x, y, z, rand(size(x)),  rand(size(x)), rand(size(x)), v);
%! cdat = calc_shading (0.5, 0.4, 0.8, 10.0, c, vn, [-1.0; -0.5; -.8], [-.5; 1.5; -.1]);
%! p = patch ("Faces", F, "Vertices", v, "FaceVertexCData", cdat, "FaceColor", "interp", "EdgeColor", "none"); 
%! view(45,30) 
%! grid on;
%! title(['Demo shading, random colored, Contour Value = ',num2str(1.1)]);
%! xlabel('X');ylabel('Y');zlabel('Z');
%! axis ([-pi, pi, -pi, pi, -pi, pi]);
