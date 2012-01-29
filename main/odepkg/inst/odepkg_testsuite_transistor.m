%# Copyright (C) 2007-2011, Thomas Treichl <treichl@users.sourceforge.net>
%# OdePkg - A package for solving ordinary differential equations and more
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
%# @deftypefn {Function File} {[@var{solution}] =} odepkg_testsuite_transistor (@var{@@solver}, @var{reltol})
%#
%# If this function is called with two input arguments and the first input argument @var{@@solver} is a function handle describing an OdePkg solver and the second input argument @var{reltol} is a double scalar describing the relative error tolerance then return the cell array @var{solution} with performance informations about the TRANSISTOR testsuite of differential algebraic equations after solving (DAE--test).
%#
%# Run examples with the command
%# @example
%# demo odepkg_testsuite_transistor
%# @end example
%# @end deftypefn
%#
%# @seealso{odepkg}

function vret = odepkg_testsuite_transistor (vhandle, vrtol)

  if (nargin ~= 2) %# Check number and types of all input arguments
    help  ('odepkg_testsuite_transistor');
    error ('OdePkg:InvalidArgument', ...
           'Number of input arguments must be exactly two');
  elseif (~isa (vhandle, 'function_handle') || ~isscalar (vrtol))
    print_usage;
  end

  vret{1} = vhandle; %# The handle for the solver that is used
  vret{2} = vrtol;   %# The value for the realtive tolerance
  vret{3} = vret{2}; %# The value for the absolute tolerance
  vret{4} = vret{2}; %# The value for the first time step
  %# Write a debug message on the screen, because this testsuite function
  %# may be called more than once from a loop over all solvers present
  fprintf (1, ['Testsuite TRANSISTOR, testing solver %7s with relative', ...
    ' tolerance %2.0e\n'], func2str (vret{1}), vrtol); fflush (1);

  %# Setting the integration algorithms option values
  vstart = 0.0;   %# The point of time when solving is started
  vstop  = 0.2;   %# The point of time when solving is stoped
  vinit  = odepkg_testsuite_transistorinit; %# The initial values
  vmass  = odepkg_testsuite_transistormass; %# The mass matrix

  vopt = odeset ('Refine', 0, 'RelTol', vret{2}, 'AbsTol', vret{3}, ...
    'InitialStep', vret{4}, 'Stats', 'on', 'NormControl', 'off', ...
    'Jacobian', @odepkg_testsuite_transistorjac, 'Mass', vmass, ...
    'MaxStep', vstop-vstart);

  %# Calculate the algorithm, start timer and do solving
  tic; vsol = feval (vhandle, @odepkg_testsuite_transistorfun, ...
    [vstart, vstop], vinit, vopt);
  vret{12} = toc;                    %# The value for the elapsed time
  vref = odepkg_testsuite_transistorref; %# Get the reference solution vector
  if (exist ('OCTAVE_VERSION') ~= 0)
    vlst = vsol.y(end,:);
  else
    vlst = vsol.y(:,end);
  end
  vret{5}  = odepkg_testsuite_calcmescd (vlst, vref, vret{3}, vret{2});
  vret{6}  = odepkg_testsuite_calcscd (vlst, vref, vret{3}, vret{2});
  vret{7}  = vsol.stats.nsteps + vsol.stats.nfailed; %# The value for all evals
  vret{8}  = vsol.stats.nsteps;   %# The value for success evals
  vret{9}  = vsol.stats.nfevals;  %# The value for fun calls
  vret{10} = vsol.stats.npds;     %# The value for partial derivations
  vret{11} = vsol.stats.ndecomps; %# The value for LU decompositions

%# Returns the results for the TRANSISTOR problem
function f = odepkg_testsuite_transistorfun (t, y, varargin)
  ub = 6; uf = 0.026; alpha = 0.99; beta = 1d-6;
  r0 = 1000; r1 = 9000; r2 = 9000; r3 = 9000;
  r4 = 9000; r5 = 9000; r6 = 9000; r7 = 9000;
  r8 = 9000; r9 = 9000;

  uet  = 0.1 * sin(200 * pi * t);
  fac1 = beta * (exp((y(2) - y(3)) / uf) - 1);
  fac2 = beta * (exp((y(5) - y(6)) / uf) - 1);

  f(1,1) = (y(1) - uet) / r0;
  f(2,1) = y(2) / r1 + (y(2) - ub) / r2 + (1 - alpha) * fac1;
  f(3,1) = y(3) / r3 - fac1;
  f(4,1) = (y(4) - ub) / r4 + alpha * fac1;
  f(5,1) = y(5) / r5 + (y(5) - ub) / r6 + (1 - alpha) * fac2;
  f(6,1) = y(6) / r7 - fac2;
  f(7,1) = (y(7) - ub) / r8 + alpha * fac2;
  f(8,1) = y(8) / r9;

%# Returns the INITIAL values for the TRANSISTOR problem
function vinit = odepkg_testsuite_transistorinit ()
  vinit = [0, 3, 3, 6, 3, 3, 6, 0];

%# Returns the JACOBIAN matrix for the TRANSISTOR problem
function dfdy = odepkg_testsuite_transistorjac (t, y, varargin)
  ub = 6; uf = 0.026; alpha = 0.99; beta = 1d-6;
  r0 = 1000; r1 = 9000; r2 = 9000; r3 = 9000;
  r4 = 9000; r5 = 9000; r6 = 9000; r7 = 9000;
  r8 = 9000; r9 = 9000;

  fac1p = beta * exp ((y(2) - y(3)) / uf) / uf;
  fac2p = beta * exp ((y(5) - y(6)) / uf) / uf;

  dfdy(1,1) =   1 / r0;
  dfdy(2,2) =   1 / r1 + 1 / r2 + (1 - alpha) * fac1p;
  dfdy(2,3) = - (1 - alpha) * fac1p;
  dfdy(3,2) = - fac1p;
  dfdy(3,3) =   1 / r3 + fac1p;
  dfdy(4,2) =   alpha * fac1p;
  dfdy(4,3) = - alpha * fac1p;
  dfdy(4,4) =   1 / r4;
  dfdy(5,5) =   1 / r5 + 1 / r6 + (1 - alpha) * fac2p;
  dfdy(5,6) = - (1 - alpha) * fac2p;
  dfdy(6,5) = - fac2p;
  dfdy(6,6) =   1 / r7 + fac2p;
  dfdy(7,5) =   alpha * fac2p;
  dfdy(7,6) = - alpha * fac2p;
  dfdy(7,7) =   1 / r8;
  dfdy(8,8) =   1 / r9;

%# Returns the MASS matrix for the TRANSISTOR problem
function mass = odepkg_testsuite_transistormass (t, y, varargin)
  mass =  [-1e-6,  1e-6,     0,     0,     0,     0,     0,      0; ...
            1e-6, -1e-6,     0,     0,     0,     0,     0,      0; ...
               0,     0, -2e-6,     0,     0,     0,     0,      0; ...
               0,     0,     0, -3e-6,  3e-6,     0,     0,      0; ...
               0,     0,     0,  3e-6, -3e-6,     0,     0,      0; ...
               0,     0,     0,     0,     0, -4e-6,     0,      0; ...
               0,     0,     0,     0,     0,     0, -5e-6,   5e-6; ...
               0,     0,     0,     0,     0,     0,  5e-6,  -5e-6];

%# Returns the REFERENCE values for the TRANSISTOR problem
function y = odepkg_testsuite_transistorref ()
  y(1,1) = -0.55621450122627e-2;
  y(2,1) =  0.30065224719030e+1;
  y(3,1) =  0.28499587886081e+1;
  y(4,1) =  0.29264225362062e+1;
  y(5,1) =  0.27046178650105e+1;
  y(6,1) =  0.27618377783931e+1;
  y(7,1) =  0.47709276316167e+1;
  y(8,1) =  0.12369958680915e+1;

%!demo
%! vsolver = {@odebda, @oders, @ode2r, @ode5r, @odesx};
%! for vcnt=1:length (vsolver)
%!   vtrans{vcnt,1} = odepkg_testsuite_transistor (vsolver{vcnt}, 1e-7);
%! end
%! vtrans

%# Local Variables: ***
%# mode: octave ***
%# End: ***
