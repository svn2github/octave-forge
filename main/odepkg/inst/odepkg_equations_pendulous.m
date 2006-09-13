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
%# @deftypefn {Function} {@var{[ydot]} =} odepkg_equations_pendulous (@var{tvar}, @var{xvar})
%# Returns the states of the differential equations from a pendulum implementation, i.e. the motion of a simple pendulum with damping. The first state variable @var{ydot(1,1)} describes the angular position and the second state variable @var{ydot(2,1)} describes the velocity of the pendulum. The variables @var{xvar} and @var{ydot} are column vectors, the variable @var{tvar} is the actual time stamp. There is no error handling implemented in this function to achieve the highest processing speed.
%# @end deftypefn

function ydot = odepkg_equations_pendulous (tvar, xvar)
  m = 1;    %# The pendulum mass in kg
  g = 9.81; %# The gravity in m/s^2
  l = 1;    %# The pendulum length in m
  b = 0.7;  %# The damping factor in kgm^2/s

  %# A more complex implementation from Marc Compere in 2001 was
  %# ydot = [xvar(2,1); ...
  %#         1 / (1/3 * m * l^2) * (-b * xvar(2,1) - m * g * l/2 * sin (xvar(1,1)))];

  ydot(1,1) = xvar(2,1);
  ydot(2,1) = 1 / (1/3 * m * l^2) * (-b * xvar(2,1) - m * g * l/2 * sin (xvar(1,1)));

%!test [t,y] = ode45 (@odepkg_equations_pendulous, [0 5], [30*pi/180, 0]);

%!demo
%!
%! A = odeset ('RelTol', 1e-8);
%! [t,y] = ode45 (@odepkg_equations_pendulous, [0 5], [30*pi/180, 0], A);
%!
%! axis ([0 5]);
%! plot (t, y(:,1), '-or;position;', t, y(:,2), '-ob;velocity;');
%! % ---------------------------------------------------------------------
%! % The figure window shows the state variables y1 and y2 of the pendulum
%! % implementation, i.e. the angular position and the velocity. The math
%! % equation for this differential equation is 
%! %   m*l^2 * (d^2theta/dt^2) + b * (dtheta/dt) + m*g*l * sin (theta) = 0
%! % with m = 1 kg, g = 9.81 m/s^2, l = 1 m, b = 0.7 kgm^2/s. The angular 
%! % position reaches steady state at 0 rad caused by the gravity term 
%! % -m*g*l/2*sin(x(1)). Velocity reaches a steady state of zero because
%! % of the damping term, -b*x(2).

%# Local Variables: ***
%# mode: octave ***
%# End: ***
