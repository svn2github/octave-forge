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

%# Maintainer: Thomas Treichl
%# Created: 20060912
%# ChangeLog:

%# File will be cleaned up in the future
function [] = odepkg (varargin)

  %# Check number and types of all input arguments
  if (nargin == 0 || nargin >= 2)
    help ('odepkg');
    error ('Number of input arguments must be exactly one');

   elseif (ischar (varargin{1}) == true)

    %# Hidden developer functions are called if any valid string is
    %# given as an input argument.
    switch (varargin{1})
      case 'odepkg_package_check'
        odepkg_package_check;
      case 'odepkg_versus_lsode'
        odepkg_versus_lsode;
      case 'odepkg_tolerances_check'
        odepkg_tolerances_check;
      case 'odepkg_outputselection_check'
        odepkg_outputselection_check;
    end

  else
    error ('The one and only input argument must be a valid string');

  end %# Check number and types of all input arguments

%# The call of this function may take a while and will open a lot of
%# figures that have to be checked.
function [] = odepkg_package_check ()

  test ('ode78', 'verbose'); clear ('all');
  test ('ode54', 'verbose'); clear ('all');
  test ('ode45', 'verbose'); clear ('all');
  test ('ode23', 'verbose'); clear ('all');

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

  %# This part of the function is used to check the solver functions
  %# with the options RelTol and AbsTol (AbsTol as scalars and vectors).
  %# Also the option value Stats == 'on' is checked with this function
  %# calls.
function [] = odepkg_tolerances_check ()
  figure; subplot (2,2,1); hold ('on');
  A = odeset ('RelTol', 1e-6, 'AbsTol', 1e-2, 'Stats', 'on');
  [x, y] = ode78 (@odepkg_equations_vanderpol, [0 30], [2 0], A, 1); plot (x, y, '-b');
  A = odeset ('RelTol', 1e-6, 'AbsTol', [1e-2; 1e-3], 'Stats', 'on');
  [x, y] = ode78 (@odepkg_equations_vanderpol, [0 30], [2 0], A, 1); plot (x, y, '-g');
  A = odeset ('RelTol', 1e-5, 'AbsTol', 1e-2, 'NormControl', 'on', 'Stats', 'on');
  [x, y] = ode78 (@odepkg_equations_vanderpol, [0 30], [2 0], A, 1); plot (x, y, '-r');
  A = odeset ('RelTol', 1e-5, 'AbsTol', [1e-2; 1e-3], 'NormControl', 'on', 'Stats', 'on');
  [x, y] = ode78 (@odepkg_equations_vanderpol, [0 30], [2 0], A, 1); plot (x, y, '-c');
  grid ('on'); hold ('off');

  subplot (2,2,2); hold ('on');
  A = odeset ('RelTol', 1e-6, 'AbsTol', 1e-2, 'Stats', 'on');
  [x, y] = ode54 (@odepkg_equations_vanderpol, [0 30], [2 0], A, 1); plot (x, y, '-b');
  A = odeset ('RelTol', 1e-6, 'AbsTol', [1e-2; 1e-3], 'Stats', 'on');
  [x, y] = ode54 (@odepkg_equations_vanderpol, [0 30], [2 0], A, 1); plot (x, y, '-g');
  A = odeset ('RelTol', 1e-5, 'AbsTol', 1e-2, 'NormControl', 'on', 'Stats', 'on');
  [x, y] = ode54 (@odepkg_equations_vanderpol, [0 30], [2 0], A, 1); plot (x, y, '-r');
  A = odeset ('RelTol', 1e-5, 'AbsTol', [1e-2; 1e-3], 'NormControl', 'on', 'Stats', 'on');
  [x, y] = ode54 (@odepkg_equations_vanderpol, [0 30], [2 0], A, 1); plot (x, y, '-c');
  grid ('on'); hold ('off');

  subplot (2,2,3); hold ('on');
  A = odeset ('RelTol', 1e-6, 'AbsTol', 1e-2, 'Stats', 'on');
  [x, y] = ode45 (@odepkg_equations_vanderpol, [0 30], [2 0], A, 1); plot (x, y, '-b');
  A = odeset ('RelTol', 1e-6, 'AbsTol', [1e-2; 1e-3], 'Stats', 'on');
  [x, y] = ode45 (@odepkg_equations_vanderpol, [0 30], [2 0], A, 1); plot (x, y, '-g');
  A = odeset ('RelTol', 1e-5, 'AbsTol', 1e-2, 'NormControl', 'on', 'Stats', 'on');
  [x, y] = ode45 (@odepkg_equations_vanderpol, [0 30], [2 0], A, 1); plot (x, y, '-r');
  A = odeset ('RelTol', 1e-5, 'AbsTol', [1e-2; 1e-3], 'NormControl', 'on', 'Stats', 'on');
  [x, y] = ode45 (@odepkg_equations_vanderpol, [0 30], [2 0], A, 1); plot (x, y, '-c');
  grid ('on'); hold ('off');

  subplot (2,2,4); hold ('on');
  A = odeset ('RelTol', 1e-6, 'AbsTol', 1e-2, 'Stats', 'on');
  [x, y] = ode23 (@odepkg_equations_vanderpol, [0 30], [2 0], A, 1); plot (x, y, '-b');
  A = odeset ('RelTol', 1e-6, 'AbsTol', [1e-2; 1e-3], 'Stats', 'on');
  [x, y] = ode23 (@odepkg_equations_vanderpol, [0 30], [2 0], A, 1); plot (x, y, '-g');
  A = odeset ('RelTol', 1e-5, 'AbsTol', 1e-2, 'NormControl', 'on', 'Stats', 'on');
  [x, y] = ode23 (@odepkg_equations_vanderpol, [0 30], [2 0], A, 1); plot (x, y, '-r');
  A = odeset ('RelTol', 1e-5, 'AbsTol', [1e-2; 1e-3], 'NormControl', 'on', 'Stats', 'on');
  [x, y] = ode23 (@odepkg_equations_vanderpol, [0 30], [2 0], A, 1); plot (x, y, '-c');
  grid ('on'); hold ('off');

%# This function is used to check the ode78 function with option
%# OutputSel. The other solvers should have the same behavior.
function [] = odepkg_outputselection_check ()
  A = odeset ('InitialStep', 1e-3, 'MaxStep', 1e-1, 'OutputSel', 1);
  [x, y] = ode78 (@odepkg_equations_lorenz, [0 25], [3 15 1], A);
  subplot(2, 2, 1); plot (x, y, '-b');
  A = odeset ('InitialStep', 1e-3, 'MaxStep', 1e-1, 'OutputSel', 2);
  [x, y] = ode78 (@odepkg_equations_lorenz, [0 25], [3 15 1], A);
  subplot(2, 2, 2); plot (x, y, '-g');
  A = odeset ('InitialStep', 1e-3, 'MaxStep', 1e-1, 'OutputSel', 3);
  [x, y] = ode78 (@odepkg_equations_lorenz, [0 25], [3 15 1], A);
  subplot(2, 2, 3); plot (x, y, '-r');
  A = odeset ('InitialStep', 1e-3, 'MaxStep', 1e-1, 'OutputSel', [1 2 3]);
  [x, y] = ode78 (@odepkg_equations_lorenz, [0 25], [3 15 1], A);
  subplot(2, 2, 4); plot (x, y);

%#[vx, vy, va, vb, vc] = ode78 (@odepkg_equations_secondorderlag, linspace (0, 2.5, 26), [0 0]);
%#[vx, vy, va, vb, vc] = ode78 (@odepkg_equations_secondorderlag, linspace (0, 2.5, 25), [0 0]);
%#[vx, vy, va, vb, vc] = ode78 (@odepkg_equations_secondorderlag, linspace (0, 2.5, 22), [0 0]);
%#[vx, vy, va, vb, vc] = ode78 (@odepkg_equations_secondorderlag, linspace (0, 2.5, 26), [0 0]);
%#[vx, vy, va, vb, vc] = ode78 (@odepkg_equations_secondorderlag, linspace (0, 2.5, 30), [0 0]);
%#[vx, vy, va, vb, vc] = ode78 (@odepkg_equations_secondorderlag, linspace (0, 2.5, 13), [0 0]);
%#[vx, vy, va, vb, vc] = ode78 (@odepkg_equations_secondorderlag, logspace (-1, 0, 13), [0 0]);
%#[vx, vy, va, vb, vc] = ode23 (@odepkg_equations_secondorderlag, logspace (-1, 0, 31), [0 0]);

%# File will be cleaned up in the future
function [] = odepkg_versus_lsode ()

  %# The options of octave's lsode are displayed
  AbsTol = lsode_options ('absolute tolerance')
  RelTol = lsode_options ('relative tolerance')
  Solver = lsode_options ('integration method') %# "adams", "non-stiff", "bdf", "stiff"
  InitStep = lsode_options ('initial step size')
  MaxOrder = lsode_options ('maximum order')
  MaxStepSize = lsode_options ('maximum step size')
  MinStepSize = lsode_options ('minimum step size')
  StepLimit = lsode_options ('step limit') %# default value is 100000

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

function xdot = odepkg_example_stiffnonnegative (x, t)
  epsilon = 1e-2;
  xdot = ((1 - x) * t - t^2) / epsilon;
endfunction

%!function y = f(x)
%! y = 3 * x;
%!test 
%!  d = f(3) * 3

%% test/octave.test/error/error-2.m
%!function g () 
%! error ("foo\n");
%!function f () 
%! g 
%!error <foo> f ();

%!shared A
%!demo A
%!  function y=f(x)
%!    y=x;
%!  endfunction
%!  f(3)
%!demo A

%# Diese demo kann dann mit dem Befehl
%#   [A, B] = example ('odepkg', 1);
%# extrahiert werden und mit dem Aufruf
%#   eval (A);
%# ausgeführt werden
%#   Baue eventuell eine neue demo.m function

%# Local Variables: ***
%# mode: octave ***
%# End: ***