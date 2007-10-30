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
%# @deftypefn  {Function File} {[@var{}] =} odesx (@var{@@fun}, @var{slot}, @var{init}, [@var{opt}], [@var{par1}, @var{par2}, @dots{}])
%# @deftypefnx {Command} {[@var{sol}] =} odesx (@var{@@fun}, @var{slot}, @var{init}, [@var{opt}], [@var{par1}, @var{par2}, @dots{}])
%# @deftypefnx {Command} {[@var{t}, @var{y}, [@var{xe}, @var{ye}, @var{ie}]] =} odesx (@var{@@fun}, @var{slot}, @var{init}, [@var{opt}], [@var{par1}, @var{par2}, @dots{}])
%#
%# This function file can be used to solve a set of non--stiff ordinary differential equations (non--stiff ODEs) and non-stiff differential algebraic equations (non-stiff DAEs). This function file is a wrapper to @file{odepkg_mexsolver_seulex.c} that uses Hairer's and Wanner's Fortran solver @file{seulex.f}.
%#
%# If this function is called with no return argument then plot the solution over time in a figure window while solving the set of ODEs that are defined in a function and specified by the function handle @var{@@fun}. The second input argument @var{slot} is a double vector that defines the time slot, @var{init} is a double vector that defines the initial values of the states, @var{opt} can optionally be a structure array that keeps the options created with the command @command{odeset} and @var{par1}, @var{par2}, @dots{} can optionally be other input arguments of any type that have to be passed to the function defined by @var{@@fun}.
%#
%# If this function is called with one return argument then return the solution @var{sol} of type structure array after solving the set of ODEs. The solution @var{sol} has the fields @var{x} of type double column vector for the steps chosen by the solver, @var{y} of type double column vector for the solutions at each time step of @var{x}, @var{solver} of type string for the solver name and optionally the extended time stamp information @var{xe}, the extended solution information @var{ye} and the extended index information @var{ie} all of type double column vector that keep the informations of the event function if an event function handle is set in the option argument @var{opt}.
%#
%# If this function is called with more than one return argument then return the time stamps @var{t}, the solution values @var{y} and optionally the extended time stamp information @var{xe}, the extended solution information @var{ye} and the extended index information @var{ie} all of type double column vector.
%#
%# Run examples with the command
%# @example
%# demo odesx
%# @end example
%# @end deftypefn
%#
%# @seealso{odepkg}

function [varargout] = odesx (varargin)
  if (exist ('odepkg_mexsolver_seulex') != 3)
    error ('Mex-function "odepkg_mexsolver_seulex" is not installed');
  else
    [varargout{1:nargout}] = odepkg_mexsolver_seulex (varargin{:});
  end

%# The following tests have been added to check the function's input arguments 
%# and output arguments
%!test
%!  if (!strcmp (which ("odepkg_mexsolver_seulex"), ""))
%!    vsol = odesx (@odepkg_equations_vanderpol, [0 2], [2 0]);
%!  end 
%!test
%!  if (!strcmp (which ("odepkg_mexsolver_seulex"), ""))
%!    [vx, vy] = odesx (@odepkg_equations_vanderpol, [0 2], [2 0]);
%!  end
%!test
%!  if (!strcmp (which ("odepkg_mexsolver_seulex"), ""))
%!    [vx, vy, va, vb, vc] = odesx (@odepkg_equations_vanderpol, [0 2], [2 0]);
%!  end
%#
%# Removed the fixed step size tests because they won't work with this solver
%#
%!test
%!  if (!strcmp (which ("odepkg_mexsolver_seulex"), ""))
%!    A = odeset ('MaxStep', 0.1, 'RelTol', 1e-2, 'AbsTol', 1e-3);
%!    vsol = odesx (@odepkg_equations_vanderpol, [0 2], [2 0], A);
%!  end
%!test
%!  if (!strcmp (which ("odepkg_mexsolver_seulex"), ""))
%!    A = odeset ('MaxStep', 0.1, 'RelTol', 1e-2, 'AbsTol', 1e-3);
%!    [vx, vy] = odesx (@odepkg_equations_vanderpol, [0 2], [2 0], A);
%!  end
%!test
%!  if (!strcmp (which ("odepkg_mexsolver_seulex"), ""))
%!    A = odeset ('MaxStep', 0.1, 'RelTol', 1e-2, 'AbsTol', 1e-3);
%!    [vx, vy, va, vb, vc] = odesx (@odepkg_equations_vanderpol, [0 2], [2 0], A);
%!  end
%!test
%!  if (!strcmp (which ("odepkg_mexsolver_seulex"), ""))
%!    A = odeset ('MaxStep', 0.1, 'RelTol', 1e-2, 'AbsTol', 1e-3);
%!    vsol = odesx (@odepkg_equations_vanderpol, [0 2], [2 0], A, 1.2);
%!  end
%!test
%!  if (!strcmp (which ("odepkg_mexsolver_seulex"), ""))
%!    A = odeset ('MaxStep', 0.1, 'RelTol', 1e-2, 'AbsTol', 1e-3);
%!    [vx, vy] = odesx (@odepkg_equations_vanderpol, [0 2], [2 0], A, 1.2);
%!  end
%!test
%!  if (!strcmp (which ("odepkg_mexsolver_seulex"), ""))
%!    A = odeset ('MaxStep', 0.1, 'RelTol', 1e-2, 'AbsTol', 1e-3);
%!    [vx, vy, va, vb, vc] = odesx (@odepkg_equations_vanderpol, [0 2], [2 0], A, 1.2);
%!  end

%!demo
%!
%! A = odeset ('RelTol', 1e-1, 'AbsTol', 1e-2);
%! [vx, vy] = odesx (@odepkg_equations_secondorderlag, [0 2.5], [0 0], ...
%!    A, 5, 2, 0.02, 0.1);
%!
%! plot (vx, vy(:,1), '-ob;y, x2;', vx, vy(:,2), '-or;x1;', ...
%!    vx, ones(length(vx),1)*5, '-og;u;');
%!
%! % ---------------------------------------------------------------------
%! % The figure window shows the state variables x1, x2 as well as the 
%! % input signal u and the output signal y(=x2) of a second order lag 
%! % implementation (cf. the control theory). The function odesx was
%! % called with an option argument A that has been set before with the
%! % command "odeset" and with further parameters "5, 2, 0.02, 0.1" that
%! % are passed to the set of ordinary differential equations.

%# Local Variables: ***
%# mode: octave ***
%# End: ***
