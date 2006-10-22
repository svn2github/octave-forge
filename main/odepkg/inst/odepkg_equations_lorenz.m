%# Copyright (C) 2006, Thomas Treichl <treichl@users.sourceforge.net>
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
%# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

%# -*- texinfo -*-
%# @deftypefn {Function} {@var{[y]} =} odepkg_equations_lorenz (@var{t}, @var{x})
%# Returns the states of the ordinary differential equations from the Lorenz equation implementation, ie. the force to a conductor caused by movement in a magnetic field, cf. @url{http://en.wikipedia.org/wiki/Lorenz_equation} for further details. The variable @var{x} has the values for the state variables, @var{y} has the results after each integration step. Both variables are column vectors, the variable @var{t} is the actual time stamp. There is no error handling implemented in this function to achieve the highest performance.
%#
%# Run
%# @example
%# demo odepkg_equations_lorenz
%# @end example
%# to see an example.
%# @end deftypefn
%#
%# @seealso{odepkg}

%#
%# - TODO - REWORK THE HELP TEXT ABOVE BECAUSE IT MAY NOT BE CORRECT -

function y = odepkg_equations_lorenz (t, x)
  y = [10 * (x(2) - x(1));
       x(1) * (28 - x(3));
       x(1) * x(2) - 8/3 * x(3)];

%!test A = odeset ('InitialStep', 1e-3, 'MaxStep', 1e-1);
%!     [t,y] = ode78 (@odepkg_equations_lorenz, [0 25], [3 15 1], A);

%!demo
%!
%! A = odeset ('InitialStep', 1e-3, 'MaxStep', 1e-1); 
%! [t, y] = ode78 (@odepkg_equations_lorenz, [0 25], [3 15 1], A);
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
