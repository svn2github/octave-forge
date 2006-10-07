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
%# TODO
%# @end deftypefn
%# 
%# @seealso{odepkg}

function y = odepkg_equations_roessler (t, x)
  y = [- ( x(2) + x(3) );
       x(1) + 0.2 * x(2);
       0.2 + x(1) * x(3) - 5.7 * x(3)];

%!test A = odeset ('MaxStep', 1e-1);
%!     [t, y] = ode78 (@odepkg_equations_roessler, [0 70], [0.1 0.3 0.1], A);

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
%! % -------------------------------------------------------------------------
%! % TODO

%# Local Variables: ***
%# mode: octave ***
%# End: ***