%# Copyright (C) 2006-2008, Thomas Treichl <treichl@users.sourceforge.net>
%# OdePkg - A package for solving differential equations with GNU Octave
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
%# along with this program; If not, see <http://www.gnu.org/licenses/>.

%# -*- texinfo -*-
%# @deftypefn {Function File} {[@var{ydot}] =} odepkg_equations_roessler (@var{t}, @var{y})
%#
%# Return the three derivatives of the non--stiff ordinary differential equations (non--stiff ODEs) from the Roessler attractor implementation, cf. @url{http://en.wikipedia.org/wiki/R%C3%B6ssler_attractor} for further details. The output argument @var{ydot} is a column vector and contains the derivatives, the input argument @var{y} also is a column vector that contains the integration results from the previous integration step and @var{t} is a double scalar that keeps the actual time stamp. There is no error handling implemented in this function to achieve the highest performance available.
%#
%# Run examples with the command
%# @example
%# demo odepkg_equations_roessler
%# @end example
%# @end deftypefn
%#
%# @seealso{odepkg}

function y = odepkg_equations_roessler (t, x)
  y = [- ( x(2) + x(3) );
       x(1) + 0.2 * x(2);
       0.2 + x(1) * x(3) - 5.7 * x(3)];

%!test 
%!  warning ("off", "OdePkg:InvalidOption");
%!  A = odeset ('MaxStep', 1e-1);
%!  [t, y] = ode78 (@odepkg_equations_roessler, [0 70], [0.1 0.3 0.1], A);

%!demo
%!
%! A = odeset ('MaxStep', 1e-1);
%! [t, y] = ode78 (@odepkg_equations_roessler, [0 70], [0.1 0.3 0.1], A);
%!
%! subplot (2, 2, 1); grid ('on'); plot (t, y(:,1), '-b;f_x(t);', ...
%!    t, y(:,2), '-g;f_y(t);', t, y(:,3), '-r;f_z(t);');
%! subplot (2, 2, 2); grid ('on'); plot (y(:,1), y(:,2), '-b;f_{xyz}(x, y);');
%! subplot (2, 2, 3); grid ('on'); plot (y(:,2), y(:,3), '-b;f_{xyz}(y, z);');
%! subplot (2, 2, 4); grid ('on'); plot3 (y(:,1), y(:,2), y(:,3), ...
%!    '-b;f_{xyz}(x, y, z);');
%!
%! % ----------------------------------------------------------------------------
%! % The upper left subfigure shows the three results of the integration over
%! % time. The upper right subfigure shows the force f in a two dimensional (x,y)
%! % plane as well as the lower left subfigure shows the force in the (y,z)
%! % plane. The three dimensional force is plotted in the lower right subfigure.

%# Local Variables: ***
%# mode: octave ***
%# End: ***
