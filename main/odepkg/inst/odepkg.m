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
%# @deftypefn {Function} odepkg ()
%# A more detailed help for the odepkg implementation will be added here soon.
%# @end deftypefn

%# Some tests from me
%# @unnumberedsubsec ode2f
%# @command{ode2f} integrates a system of ordinary differential equations using a 2nd order Runge-Kutta formulae called Ralston's method. This choice of 2nd order coefficients provides a minimum bound on truncation error. For more information see Ralston & Rabinowitz (1978) or Numerical Methods for Engineers, 2nd Ed., Chappra & Cannle, McGraw-Hill, 1985. 2nd-order accurate RK methods have a local error estimate of O(h^3). @command{ode2f} requires two function evaluations per integration step.

%# Maintainer: Thomas Treichl
%# Created: 20060912
%# ChangeLog:

%# File will be cleaned up in the future
function [] = odepkg (varargin)
%# File will be cleaned up in the future
  if (ischar (varargin{1}) == true)
    %# Hidden functions of developer are called
    switch (varargin{1})
      case 'odepkg_package_check'
        odepkg_package_check;
    endswitch

  else %# if (ischar (varargin{1}) ~= true)
    help ('odepkg');
    return;
  end

%# The call of this function may take a while and will open a lot of
%# figures that have to be checked.
function [] = odepkg_package_check ()

  test ('ode23', 'verbose'); clear ('all');
  test ('ode45', 'verbose'); clear ('all');
  test ('ode54', 'verbose'); clear ('all');
  test ('ode78', 'verbose'); clear ('all');

  test ('odeget.m', 'verbose'); clear ('all');
  test ('odeset.m', 'verbose'); clear ('all');
  test ('odepkg_structure_check.m', 'verbose'); clear ('all');

  test('odeplot.m', 'verbose'); clear ('all');
  test('odephas2.m', 'verbose'); clear ('all');
  test('odephas3.m', 'verbose'); clear ('all');
  test('odeprint.m', 'verbose'); clear ('all');

  test ('odepkg_equations_lorenz', 'verbose'); clear ('all');
  test ('odepkg_equations_pendulous', 'verbose'); clear ('all');
  test ('odepkg_equations_secondorderlag', 'verbose'); clear ('all');
  test ('odepkg_equations_vanderpol', 'verbose'); clear ('all');

%# File will be cleaned up in the future
function [] = odepkg_vs_lsode ()

  %# The options of today's lsode are displayed
  AbsTol = lsode_options ("absolute tolerance")
  RelTol = lsode_options ("relative tolerance")
  Solver = lsode_options ("integration method") # "adams", "non-stiff", "bdf", "stiff"
  InitStep = lsode_options ("initial step size")
  MaxOrder = lsode_options ("maximum order")
  MaxStepSize = lsode_options ("maximum step size")
  MinStepSize = lsode_options ("minimum step size")
  StepLimit = lsode_options ("step limit")

%#  lsode_options ("integration method", "non-stiff");
%#  [a, b, c] = lsode (@vanderpol, [2 0], [0 20])

  %# Solve octave's example from the documentation
  x0 = [4; 1.1; 4]; t = linspace (0, 500, 100);
  [a, b, c] = lsode (@lsode_example_dococtave, x0, t);
  c, plot (t, a, '-o');

  t = [0, ...
       (logspace (-1, log10(303), 150)), ...
       (logspace (log10(304), log10(500), 150))];
  [a, b, c] = lsode (@lsode_example_dococtave, x0, t);
  c, plot (t, a, '-o');

%#  size (a)
%#  t = [0, (logspace (-1, log10(303), 150)), (logspace (log10(304), log10(500), 150))];

endfunction
%# File will be cleaned up in the future
function vydot = lsode_example_vanderpol (vy, vt)
  mu = 100;
  vydot = [vy(2); mu * (1 - vy(1)^2) * vy(2) - vy(1)];
endfunction

function vydot = odepkg_example_vanderpol (vt, vy)
  mu = 100;
  vydot = [vy(2); mu * (1 - vy(1)^2) * vy(2) - vy(1)];
endfunction

function xdot = lsode_example_dococtave (x, t)
  xdot = zeros (3,1);
  xdot(1) = 77.27 * (x(2) - x(1)*x(2) + x(1) - 8.375e-06*x(1)^2);
  xdot(2) = (x(3) - x(1)*x(2) - x(2)) / 77.27;
  xdot(3) = 0.161*(x(1) - x(3));
endfunction

function xdot = odepkg_example_dococtave (t, x)
  xdot = zeros (3,1);
  xdot(1) = 77.27 * (x(2) - x(1)*x(2) + x(1) - 8.375e-06*x(1)^2);
  xdot(2) = (x(3) - x(1)*x(2) - x(2)) / 77.27;
  xdot(3) = 0.161*(x(1) - x(3));
endfunction

%# Local Variables: ***
%# mode: octave ***
%# End: ***