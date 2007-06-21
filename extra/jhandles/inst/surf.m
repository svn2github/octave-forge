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
## along with this program; if not, write to the Free Software
## Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
## 02110-1301  USA

function h = surf (x, y, z, varargin)

  newplot ();

  if (nargin == 1)
    z = x;
    if (ismatrix (z))
      [nr, nc] = size (z);
      x = 1:nc;
      y = (1:nr)';
    else
      error ("surf: argument must be a matrix");
    endif
  elseif (nargin >= 3)
    if (isvector (x) && isvector (y) && ismatrix (z))
      if (rows (z) == length (y) && columns (z) == length (x))
        x = x(:)';
        y = y(:);
		[x, y] = meshgrid (x, y);
      else
        msg = "surf: rows (z) must be the same as length (y) and";
        msg = sprintf ("%s\ncolumns (z) must be the same as length (x)", msg);
        error (msg);
      endif
    elseif (ismatrix (x) && ismatrix (y) && ismatrix (z))
      if (! (size_equal (x, y) && size_equal (x, z)))
        error ("surf: x, y, and z must have same dimensions");
      endif
    else
      error ("surf: x and y must be vectors and z must be a matrix");
    endif
  else
    print_usage ();
  endif

  ## make a default line object, and make it the current axes for the
  ## current figure.
  ca = gca ();

  if (! strcmp (get (ca, "nextplot"), "add"))
    set(ca, "view", [-37.5, 30], "box", "off", "xgrid", "on", "ygrid", "on", "zgrid", "on");
  endif

  j1 = java_convert_matrix (1);
  j2 = java_unsigned_conversion (1);

  unwind_protect
    ax_obj = __get_object__ (ca);
    surf_obj = java_new ("org.octave.graphics.SurfaceObject", ax_obj, x, y, z);
  unwind_protect_cleanup
    java_convert_matrix (j1);
    java_unsigned_conversion (j2);
  end_unwind_protect

  tmp = surf_obj.getHandle ();

  if (length (varargin) > 0)
    set (tmp, varargin{:});
  else
    __request_drawnow__;
  endif
  surf_obj.validate ();

  if (nargout > 0)
    h = tmp;
  endif

endfunction
