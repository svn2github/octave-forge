%# Copyright (C) 2007, Thomas Treichl <treichl@users.sourceforge.net>
%# OdePkg - Package for solving ordinary differential equations with octave
%#
%# This program is free software; you can redistribute it and/or modify
%# it under the terms of the GNU General Public License as published by
%# the Free Software Foundation; either version 2 of the License, or
%# (at your option) any later version.
%#
%# This program is distributed in the hope that it will be useful,
%# but WITHOUT ANY WARRANTY; without even the implied warranty of
%# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%# GNU General Public License for more details.
%#
%# You should have received a copy of the GNU General Public License
%# along with this program; if not, write to the Free Software
%# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA

%# -*- texinfo -*-
%# @deftypefn {Function File} {[@var{res}] =} odepkg_equations_ilorenz (@var{t}, @var{y}, var{yd})
%#
%# Return three residuals of the implicit ordinary differential equations (IDEs) from the "Lorenz attractor" implementation, cf. @url{http://en.wikipedia.org/wiki/Lorenz_equation} for further details. The output argument @var{res} is a column vector and contains the residuals, @var{y} is a column vector that contains the integration results from the previous integration step, @var{yd} is a column vector that contains the derivatives of the last integration step and @var{t} is a scalar value with the actual time stamp. There is no error handling implemented in this function to achieve the highest performance available.
%#
%# Run examples with the command
%# @example
%# demo odepkg_equations_ilorenz
%# @end example
%# @end deftypefn
%#
%# @seealso{odepkg}

function res = odepkg_equations_ilorenz (t, y, yd)
  %# No Jacobian needed
  %# y0 = [3 15 1]'
  %# yd0 = [120 81 42.333333]'
  %# odebdi (@odepkg_equations_ilorenz, [0, 25], [3 15 1]', [120 81 42.333333]')
  res = [10 * (y(2) - y(1)) - yd(1);
	 y(1) * (28 - y(3)) - yd(2);
	 y(1) * y(2) - 8/3 * y(3) - yd(3)];

%!test
%!  if (!strcmp (which ("odebdi"), ""))
%!    warning ("off", "OdePkg:InvalidOption");
%!    A = odeset ('InitialStep', 1e-3, 'MaxStep', 1e-1);
%!    [vt, vy] = odebdi (@odepkg_equations_ilorenz, [0 25], 
%!                       [3 15 1], [120 81 42.333333], A);
%!    warning ("on", "OdePkg:InvalidOption");
%!  endif

%!demo
%!
%! A = odeset ('InitialStep', 1e-3, 'MaxStep', 1e-1);
%! [t, y] = odebdi (@odepkg_equations_ilorenz, [0 25], 
%!                  [3 15 1], [120 81 42.333333], A);
%!
%! subplot (2, 2, 1); grid ('on'); plot (t, y(:,1), '-b;f_x(t);', ...
%!    t, y(:,2), '-g;f_y(t);', t, y(:,3), '-r;f_z(t);');
%! subplot (2, 2, 2); grid ('on'); plot (y(:,1), y(:,2), '-b;f_{xyz}(x, y);');
%! subplot (2, 2, 3); grid ('on'); plot (y(:,2), y(:,3), '-b;f_{xyz}(y, z);');
%! subplot (2, 2, 4); grid ('on'); plot3 (y(:,1), y(:,2), y(:,3), ...
%!    '-b;f_{xyz}(x, y, z);');
%!
%! % -------------------------------------------------------------------------
%! % The upper left subfigure shows the three results of the integration over
%! % time. The upper right subfigure shows the force f in a two dimensional 
%! % (x,y) plane as well as the lower left subfigure shows the force in the
%! % (y,z) plane. The three dimensional force is plotted in the lower right
%! % subfigure.

%# Local Variables: ***
%# mode: octave ***
%# End: ***
