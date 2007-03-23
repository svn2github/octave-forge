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
%# @deftypefn {Function} odepkg ()
%# A more detailed help for the odepkg implementation will be added here soon.
%# @end deftypefn

%# Maintainer: Thomas Treichl
%# Created:    20060912
%# ChangeLog:  
%#    20070108, Thomas Treichl
%#       Completely changed the behaviour of this function.

%# File will be cleaned up in the future
function [] = odepkg (vstr)
  %# Check number and types of all input arguments
  if (nargin == 0 || nargin > 1)
    help ('odepkg');
    error ('Number of input arguments must be exactly one');
  elseif (ischar (vstr) == true)
    feval (str2func (vstr));
  elseif (isa (vstr, 'function_handle') == true)
    feval (vstr);
  else
    error ('Input argument must be a valid string or function handle');
  end %# Check number and types of all input arguments

function [] = odepkg_validate_mfiles ()

  %# Can do all tests that do not produce output, if functions have to be
  %# tested that do produce output then look below - they are called
  %# manually. From command line run something like this:
  %#   octave --quiet --eval "odepkg ('odepkg_validate_mfiles')"

  vfun = {'ode23', 'ode45', 'ode54', 'ode78', ...
          'ode5d', 'ode8d', 'odeox', ...
          'ode2r', 'ode5r', 'oders', 'odesx', ...
          'odeget', 'odeset', ...
          'odepkg_structure_check', ... %# 'odepkg_event_handle', ...
          'odeplot', 'odephas2', 'odephas3', 'odeprint', ...
          'odepkg_equations_lorenz', 'odepkg_equations_pendulous', ...
          'odepkg_equations_roessler', 'odepkg_equations_secondorderlag', ...
          'odepkg_equations_vanderpol', ...
          'odepkg_testsuite_calcscd', 'odepkg_testsuite_calcmescd'};

  for vcnt=1:length(vfun)
    printf ('Testing function %s ... ', vfun{vcnt});
    test (vfun{vcnt}, 'quiet'); fflush (1);
  end

  printf ('Testing function odepkg_testsuite_chemakzo ... ');
  odepkg_testsuite_chemakzo (@odepkg_mexsolver_radau,  10^-04);
  printf ('Testing function odepkg_testsuite_chemakzo ... ');
  odepkg_testsuite_chemakzo (@odepkg_mexsolver_seulex, 10^-04);

function [] = odepkg_performance_mathires ()
  vfun = {@ode113, @ode23, @ode45, ...
          @ode15s, @ode23s, @ode23t, @ode23tb};
  for vcnt=1:length(vfun)
    vsol{vcnt, 1} = odepkg_testsuite_hires (vfun{vcnt}, 1e-7);
  end
  odepkg_testsuite_write (vsol);

function [] = odepkg_performance_octavehires ()
  vfun = {@ode23, @ode45, @ode54, @ode78, @odepkg_mexsolver_odex, ...
          @odepkg_mexsolver_dopri5, @odepkg_mexsolver_dop853, ...
          @odepkg_mexsolver_radau, @odepkg_mexsolver_radau5, ...
          @odepkg_mexsolver_seulex, @odepkg_mexsolver_rodas};
  for vcnt=1:length(vfun)
    vsol{vcnt, 1} = odepkg_testsuite_hires (vfun{vcnt}, 1e-7);
  end
  odepkg_testsuite_write (vsol);

function [] = odepkg_performance_matchemakzo ()
  vfun = {@ode23, @ode45, ...
          @ode15s, @ode23s, @ode23t, @ode23tb};
  for vcnt=1:length(vfun)
    vsol{vcnt, 1} = odepkg_testsuite_chemakzo (vfun{vcnt}, 1e-7);
  end
  odepkg_testsuite_write (vsol);

function [] = odepkg_performance_octavechemakzo ()
  vfun = {@ode23, @ode45, @ode54, @ode78, @odepkg_mexsolver_odex, ...
          @odepkg_mexsolver_dopri5, @odepkg_mexsolver_dop853, ...
          @odepkg_mexsolver_radau, @odepkg_mexsolver_radau5, ...
          @odepkg_mexsolver_seulex, @odepkg_mexsolver_rodas};
  for vcnt=1:length(vfun)
    vsol{vcnt, 1} = odepkg_testsuite_chemakzo (vfun{vcnt}, 1e-7);
  end
  odepkg_testsuite_write (vsol);

function [] = odepkg_testsuite_write (vsol)

  fprintf (1, ['-----------------------------------------------------------------------------------------\n']);
  fprintf (1, [' Solver  RelTol  AbsTol   Init   Mescd    Scd  Steps  Accept  FEval  JEval  LUdec    Time\n']);
  fprintf (1, ['-----------------------------------------------------------------------------------------\n']);

  [vlin, vcol] = size (vsol);
  for vcntlin = 1:vlin
    if (isempty (vsol{vcntlin}{9})), vsol{vcntlin}{9} = 0; end
    %# if (vcntlin > 1) %# Delete solver name if it is the same as before
    %#   if (strcmp (func2str (vsol{vcntlin}{1}), func2str (vsol{vcntlin-1}{1})))
    %#     vsol{vcntlin}{1} = ' ';
    %#   end
    %# end
    fprintf (1, ['%7s  %6.0g  %6.0g  %6.0g  %5.2f  %5.2f  %5.0d  %6.0d  %5.0d  %5.0d  %5.0d  %6.3f\n'], ...
             func2str (vsol{vcntlin}{1}), vsol{vcntlin}{2:12});
  end
  fprintf (1, ['-----------------------------------------------------------------------------------------\n']);

function [] = demos ()

%  test ('ode78', 'verbose'); clear ('all');
%  test ('ode54', 'verbose'); clear ('all');
%  test ('ode45', 'verbose'); clear ('all');
%  test ('ode23', 'verbose'); clear ('all');

  demo ('odeget.m');
  demo ('odeset.m');
  demo ('odepkg_structure_check.m'); clear ('all');
  demo ('odepkg_event_handle.m', 'verbose'); clear ('all');

  demo('odeplot.m', 'verbose'); clear ('all');
  demo('odephas2.m', 'verbose'); clear ('all');
  demo('odephas3.m', 'verbose'); clear ('all');
  demo('odeprint.m'); clear ('all');

  demo ('odepkg_equations_lorenz'); clear ('all');
  demo ('odepkg_equations_pendulous'); clear ('all');
  demo ('odepkg_equations_roessler'); clear ('all');
  demo ('odepkg_equations_secondorderlag'); clear ('all');
  demo ('odepkg_equations_vanderpol'); clear ('all');


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

%# Local Variables: ***
%# mode: octave ***
%# End: ***
