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
%# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA

%# -*- texinfo -*-
%# @deftypefn {Function File} {[@var{solution}] =} odepkg_testsuite_robertson (@var{@@solver}, @var{reltol})
%#
%# If this function is called with two input arguments and the first input argument @var{@@solver} is a function handle describing an OdePkg solver and the second input argument @var{reltol} is a double scalar describing the relative error tolerance then return a cell array @var{solution} with performance informations about the modified ROBERTSON testsuite of differential algebraic equations after solving (DAE--test).
%#
%# Run examples with the command
%# @example
%# demo odepkg_testsuite_robertson
%# @end example
%# @end deftypefn
%#
%# @seealso{odepkg}

function vret = odepkg_testsuite_robertson (vhandle, vrtol)

  if (nargin ~= 2) %# Check number and types of all input arguments
    help  ('odepkg_testsuite_robertson');
    error ('Number of input arguments must be exactly two');
  elseif (~isa (vhandle, 'function_handle') || ~isscalar (vrtol))
    usage ('odepkg_testsuite_robertson (@solver, reltol)');
  end

  vret{1} = vhandle; %# The name for the solver that is used
  vret{2} = vrtol;   %# The value for the realtive tolerance
  vret{3} = vret{2} * 1e-2; %# The value for the absolute tolerance
  vret{4} = vret{2}; %# The value for the first time step
  %# Write a debug message on the screen, because this testsuite function
  %# may be called more than once from a loop over all solvers present
  fprintf (1, ['Testsuite ROBERTSON, testing solver %7s with relative', ...
    ' tolerance %2.0e\n'], func2str (vret{1}), vrtol); fflush (1);

  %# Setting the integration algorithms option values
  vstart = 0.0;   %# The point of time when solving is started
  vstop  = 1e11;   %# The point of time when solving is stoped
  vinit  = odepkg_testsuite_robertsoninit; %# The initial values
  vmass  = odepkg_testsuite_robertsonmass; %# The mass matrix

  vopt = odeset ('Refine', 0, 'RelTol', vret{2}, 'AbsTol', vret{3}, ...
    'InitialStep', vret{4}, 'Stats', 'on', 'NormControl', 'off', ...
    'Jacobian', @odepkg_testsuite_robertsonjac, 'Mass', vmass, ...
    'MaxStep', vstop-vstart);

  %# Calculate the algorithm, start timer and do solving
  tic; vsol = feval (vhandle, @odepkg_testsuite_robertsonfun, ...
    [vstart, vstop], vinit, vopt);
  vret{12} = toc;                    %# The value for the elapsed time
  vref = odepkg_testsuite_robertsonref; %# Get the reference solution vector
  if (max (size (vsol.y(end,:))) == max (size (vref))), vlst = vsol.y(end,:);
  elseif (max (size (vsol.y(:,end))) == max (size (vref))), vlst = vsol.y(:,end);
  end
  vret{5}  = odepkg_testsuite_calcmescd (vlst, vref, vret{3}, vret{2});
  vret{6}  = odepkg_testsuite_calcscd (vlst, vref, vret{3}, vret{2});
  vret{7}  = vsol.stats.success + vsol.stats.failed; %# The value for all evals
  vret{8}  = vsol.stats.success;  %# The value for success evals
  vret{9}  = vsol.stats.fevals;   %# The value for fun calls
  vret{10} = vsol.stats.partial;  %# The value for partial derivations
  vret{11} = vsol.stats.ludecom;  %# The value for LU decompositions

%# Returns the results for the for the modified ROBERTSON problem
function f = odepkg_testsuite_robertsonfun (t, y, varargin)
  f(1,1) = -0.04 * y(1) + 1e4 * y(2) * y(3);
  f(2,1) =  0.04 * y(1) - 1e4 * y(2) * y(3) - 3e7 * y(2)^2;
  f(3,1) =  y(1) + y(2) + y(3) - 1;

%# Returns the INITIAL values for the modified ROBERTSON problem
function vinit = odepkg_testsuite_robertsoninit ()
  vinit = [1, 0, 0];

%# Returns the JACOBIAN matrix for the modified ROBERTSON problem
function dfdy = odepkg_testsuite_robertsonjac (t, y, varargin)
  dfdy(1,1) = -0.04;
  dfdy(1,2) =  1e4 * y(3);
  dfdy(1,3) =  1e4 * y(2);
  dfdy(2,1) =  0.04;
  dfdy(2,2) = -1e4 * y(3) - 6e7 * y(2);
  dfdy(2,3) = -1e4 * y(2);
  dfdy(3,1) =  1;
  dfdy(3,2) =  1;
  dfdy(3,3) =  1;

%# Returns the MASS matrix for the modified ROBERTSON problem
function mass = odepkg_testsuite_robertsonmass (t, y, varargin)
  mass =  [1, 0, 0; 0, 1, 0; 0, 0, 0];

%# Returns the REFERENCE values for the modified ROBERTSON problem
function y = odepkg_testsuite_robertsonref ()
  y(1) =  0.20833401497012e-07;
  y(2) =  0.83333607703347e-13;
  y(3) =  0.99999997916650e+00;

%!demo
%! vsolver = {@ode23, @ode45, @ode54, @ode78, ...
%!   @odepkg_mexsolver_dopri5, @odepkg_mexsolver_dop853, ...
%!   @odepkg_mexsolver_odex, @odepkg_mexsolver_radau, ...
%!   @odepkg_mexsolver_radau5, @odepkg_mexsolver_rodas, ...
%!   @odepkg_mexsolver_seulex};
%! for vcnt=1:length (vsolver)
%!   vrober{vcnt,1} = odepkg_testsuite_robertson (vsolver{vcnt}, 1e-7);
%! end
%! vrober

%# Local Variables: ***
%# mode: octave ***
%# End: ***
