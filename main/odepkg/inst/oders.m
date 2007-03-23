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
%# @deftypefn  {Function} oders (@var{@@fun, slot, init, [opt], [P1, P2, @dots{}]})
%# @deftypefnx {Function} {@var{sol} =} oders (@var{@@fun, slot, init, [opt], [P1, P2, @dots{}]})
%# @deftypefnx {Function} {@var{[t, y, [xe, ye, ie]]} =} oders (@var{@@fun, slot, init, [opt], [P1, P2, @dots{}]})
%#
%# If called with no return argument, plots the solutions over time in a figure window while solving the set of equations that are defined in a function and specified by the function handle @var{@@fun}. The second input argument @var{slot} must be the time slot, @var{init} must be the states initial values, @var{opt} can optionally be the options structure that is created with the command @command{odeset} and @var{[P1, P2, @dots{}]} can optionally be all arguments that have to be passed to the function @var{fun}. If an invalid input argument is detected then the function terminates with an error.
%#
%# If called with one return argument, returns the solution structure @var{sol} after solving the set of ordinary differential equations. The solution structure @var{sol} has the fields @var{x} for the steps chosen by the solver, @var{y} for the solver solutions, @var{solver} for the solver name and optionally the extended time stamp information @var{xe}, the extended solution information @var{ye} and the extended index information @var{ie} of the event function if an event property is set in the option argument @var{opt}. See the description for the input arguments before. If an invalid input argument is detected then the function terminates with an error.
%#
%# If called with more than one return argument, returns the time stamps @var{t}, the solution values @var{y} and optionally the extended time stamp information @var{xe}, the extended solution information @var{ye} and the extended index information @var{ie} of the event function if an event property is set in the option argument @var{opt}. See the description for the input arguments before. If an invalid input argument is detected then the function terminates with an error.
%#
%# Run
%# @example
%# demo oders
%# @end example
%# to see an example.
%# @end deftypefn
%#
%# @seealso{odepkg}

function [varargout] = oders (varargin)
  if (exist ('odepkg_mexsolver_rodas') != 3)
    error ('Mex-function "odepkg_mexsolver_rodas" is not installed');
  else
    [varargout{1:nargout}] = odepkg_mexsolver_rodas (varargin{:});
    end
  end

%# The following tests have been added to check the function's input arguments 
%# and output arguments
%!test
%!  if (!strcmp (which ("odepkg_mexsolver_rodas"), ""))
%!    vsol = oders (@odepkg_equations_vanderpol, [0 2], [2 0]);
%!  end 
%!test
%!  if (!strcmp (which ("odepkg_mexsolver_rodas"), ""))
%!    [vx, vy] = oders (@odepkg_equations_vanderpol, [0 2], [2 0]);
%!  end
%!test
%!  if (!strcmp (which ("odepkg_mexsolver_rodas"), ""))
%!    [vx, vy, va, vb, vc] = oders (@odepkg_equations_vanderpol, [0 2], [2 0]);
%!  end
%#
%# Removed the fixed step size tests because they won't work with this solver
%#
%!test
%!  if (!strcmp (which ("odepkg_mexsolver_rodas"), ""))
%!    A = odeset ('MaxStep', 0.1, 'RelTol', 1e-2, 'AbsTol', 1e-3);
%!    vsol = oders (@odepkg_equations_vanderpol, [0 2], [2 0], A);
%!  end
%!test
%!  if (!strcmp (which ("odepkg_mexsolver_rodas"), ""))
%!    A = odeset ('MaxStep', 0.1, 'RelTol', 1e-2, 'AbsTol', 1e-3);
%!    [vx, vy] = oders (@odepkg_equations_vanderpol, [0 2], [2 0], A);
%!  end
%!test
%!  if (!strcmp (which ("odepkg_mexsolver_rodas"), ""))
%!    A = odeset ('MaxStep', 0.1, 'RelTol', 1e-2, 'AbsTol', 1e-3);
%!    [vx, vy, va, vb, vc] = oders (@odepkg_equations_vanderpol, [0 2], [2 0], A);
%!  end
%!test
%!  if (!strcmp (which ("odepkg_mexsolver_rodas"), ""))
%!    A = odeset ('MaxStep', 0.1, 'RelTol', 1e-2, 'AbsTol', 1e-3);
%!    vsol = oders (@odepkg_equations_vanderpol, [0 2], [2 0], A, 1.2);
%!  end
%!test
%!  if (!strcmp (which ("odepkg_mexsolver_rodas"), ""))
%!    A = odeset ('MaxStep', 0.1, 'RelTol', 1e-2, 'AbsTol', 1e-3);
%!    [vx, vy] = oders (@odepkg_equations_vanderpol, [0 2], [2 0], A, 1.2);
%!  end
%!test
%!  if (!strcmp (which ("odepkg_mexsolver_rodas"), ""))
%!    A = odeset ('MaxStep', 0.1, 'RelTol', 1e-2, 'AbsTol', 1e-3);
%!    [vx, vy, va, vb, vc] = oders (@odepkg_equations_vanderpol, [0 2], [2 0], A, 1.2);
%!  end

%!demo
%!
%! A = odeset ('RelTol', 1e-1, 'AbsTol', 1e-2);
%! [vx, vy] = oders (@odepkg_equations_secondorderlag, [0 2.5], [0 0], ...
%!    A, 5, 2, 0.02, 0.1);
%!
%! plot (vx, vy(:,1), '-ob;y, x2;', vx, vy(:,2), '-or;x1;', ...
%!    vx, ones(length(vx),1)*5, '-og;u;');
%!
%! % ---------------------------------------------------------------------
%! % The figure window shows the state variables x1, x2 as well as the 
%! % input signal u and the output signal y(=x2) of a second order lag 
%! % implementation (cf. the control theory). The function oders was
%! % called with an option argument A that has been set before with the
%! % command "odeset" and with further parameters "5, 2, 0.02, 0.1" that
%! % are passed to the set of ordinary differential equations.

%# Local Variables: ***
%# mode: octave ***
%# End: ***
