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
%# @deftypefn  {Function} ode5d (@var{@@fun, slot, init, [opt], [P1, P2, @dots{}]})
%# @deftypefnx {Function} {@var{sol} =} ode5d (@var{@@fun, slot, init, [opt], [P1, P2, @dots{}]})
%# @deftypefnx {Function} {@var{[t, y, [xe, ye, ie]]} =} ode5d (@var{@@fun, slot, init, [opt], [P1, P2, @dots{}]})
%#
%# If called with no return argument, plots the solutions over time in a figure window while solving the set of equations that are defined in a function and specified by the function handle @var{@@fun}. The second input argument @var{slot} must be the time slot, @var{init} must be the states initial values, @var{opt} can optionally be the options structure that is created with the command @command{odeset} and @var{[P1, P2, @dots{}]} can optionally be all arguments that have to be passed to the function @var{fun}. If an invalid input argument is detected then the function terminates with an error.
%#
%# If called with one return argument, returns the solution structure @var{sol} after solving the set of ordinary differential equations. The solution structure @var{sol} has the fields @var{x} for the steps chosen by the solver, @var{y} for the solver solutions, @var{solver} for the solver name and optionally the extended time stamp information @var{xe}, the extended solution information @var{ye} and the extended index information @var{ie} of the event function if an event property is set in the option argument @var{opt}. See the description for the input arguments before. If an invalid input argument is detected then the function terminates with an error.
%#
%# If called with more than one return argument, returns the time stamps @var{t}, the solution values @var{y} and optionally the extended time stamp information @var{xe}, the extended solution information @var{ye} and the extended index information @var{ie} of the event function if an event property is set in the option argument @var{opt}. See the description for the input arguments before. If an invalid input argument is detected then the function terminates with an error.
%#
%# Run
%# @example
%# demo ode5d
%# @end example
%# to see an example.
%# @end deftypefn
%#
%# @seealso{odepkg}

function [varargout] = ode5d (varargin)
  if (exist ('odepkg_mexsolver_dopri5') != 3)
    error ('Mex-function "odepkg_mexsolver_dopri5" is not installed');
  else
    if (nargout == 0)
      odepkg_mexsolver_dopri5 (varargin{:});
    elseif (nargout == 1)
      varargout{1} = odepkg_mexsolver_dopri5 (varargin{:});
    elseif (nargout == 2)
      [varargout{1}, varargout{2}] = odepkg_mexsolver_dopri5 (varargin{:});
    elseif (nargout == 5)
      [varargout{1}, varargout{2}, varargout{3}, varargout{4}, varargout{5}] = ...
        odepkg_mexsolver_dopri5 (varargin{:});
    end
  end

%# The following tests have been added to check the function's input arguments and output arguments
%#!test vsol = ode5d (@odepkg_equations_secondorderlag, [0 0.1], [0 0]);
%#!test [vx, vy] = ode5d (@odepkg_equations_secondorderlag, [0 0.1], [0 0]);
%#!test [vx, vy, va, vb, vc] = ode5d (@odepkg_equations_secondorderlag, [0 0.1], [0 0]);
%#test vsol = ode5d (@odepkg_equations_secondorderlag, linspace (0, 2.5, 52), [0 0]);
%#test [vx, vy] = ode5d (@odepkg_equations_secondorderlag, linspace (0, 2.5, 52), [0 0]);
%#test [vx, vy, va, vb, vc] = ode5d (@odepkg_equations_secondorderlag, linspace (0, 2.5, 52), [0 0]);
%#!test A = odeset ('MaxStep', 2.5/50, 'RelTol', 1e-1, 'AbsTol', 1e-2); 
%#!     vsol = ode5d (@odepkg_equations_secondorderlag, [0 2.5], [0 0], A);
%#!test A = odeset ('MaxStep', 2.5/50, 'RelTol', 1e-1, 'AbsTol', 1e-2); 
%#!     [vx, vy] = ode5d (@odepkg_equations_secondorderlag, [0 2.5], [0 0], A);
%#!test A = odeset ('MaxStep', 2.5/50, 'RelTol', 1e-1, 'AbsTol', 1e-2); 
%#!     [vx, vy, va, vb, vc] = ode5d (@odepkg_equations_secondorderlag, [0 2.5], [0 0], A);
%#!test A = odeset ('MaxStep', 2.5/50, 'RelTol', 1e-1, 'AbsTol', 1e-2); 
%#!     vsol = ode5d (@odepkg_equations_secondorderlag, [0 2.5], [0 0], A, 5, 2, 0.02, 0.1);
%#!test A = odeset ('MaxStep', 2.5/50, 'RelTol', 1e-1, 'AbsTol', 1e-2); 
%#!     [vx, vy] = ode5d (@odepkg_equations_secondorderlag, [0 2.5], [0 0], A, 5, 2, 0.02, 0.1);
%#!test A = odeset ('MaxStep', 2.5/50, 'RelTol', 1e-1, 'AbsTol', 1e-2); 
%#!     [vx, vy, va, vb, vc] = ode5d (@odepkg_equations_secondorderlag, [0 2.5], [0 0], A, 5, 2, 0.02, 0.1);

%!demo
%!
%! A = odeset ('RelTol', 1e-1, 'AbsTol', 1e-2);
%! [vx, vy] = ode5d (@odepkg_equations_secondorderlag, [0 2.5], [0 0], ...
%!    A, 5, 2, 0.02, 0.1);
%!
%! plot (vx, vy(:,1), '-ob;y, x2;', vx, vy(:,2), '-or;x1;', ...
%!    vx, ones(length(vx),1)*5, '-og;u;');
%!
%! % ---------------------------------------------------------------------
%! % The figure window shows the state variables x1, x2 as well as the 
%! % input signal u and the output signal y(=x2) of a second order lag 
%! % implementation (cf. the control theory). The function ode5d was
%! % called with an option argument A that has been set before with the
%! % command "odeset" and with further parameters "5, 2, 0.02, 0.1" that
%! % are passed to the set of ordinary differential equations.

%# Local Variables: ***
%# mode: octave ***
%# End: ***
