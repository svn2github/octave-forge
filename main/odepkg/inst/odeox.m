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
%# @deftypefn  {Function File} {[@var{}] =} odeox (@var{@@fun}, @var{slot}, @var{init}, [@var{opt}], [@var{par1}, @var{par2}, @dots{}])
%# @deftypefnx {Command} {[@var{sol}] =} odeox (@var{@@fun}, @var{slot}, @var{init}, [@var{opt}], [@var{par1}, @var{par2}, @dots{}])
%# @deftypefnx {Command} {[@var{t}, @var{y}, [@var{xe}, @var{ye}, @var{ie}]] =} odeox (@var{@@fun}, @var{slot}, @var{init}, [@var{opt}], [@var{par1}, @var{par2}, @dots{}])
%#
%# This function file can be used to solve a set of non--stiff ordinary differential equations (non--stiff ODEs) and non--stiff differential algebraic equations (non--stiff DAEs).
%#
%# @b{Note: The function files @file{odepkg_mexsolver_odex} and @file{odeox} will be removed when version 0.4.0 of OdePkg will be released. A similiar solver method does not exist in OdePkg but you can use @file{ode23, ode45, ode54} or @file{ode78} instead.}
%#
%# @end deftypefn
%# @seealso{odepkg}

function [varargout] = odeox (varargin)
  warning ('Solver odeox is deprecated and will be removed with OdePkg 0.4.0');
  if (exist ('odepkg_mexsolver_odex') != 3)
    error ('Mex-function "odepkg_mexsolver_odex" is not installed');
  else
    [varargout{1:nargout}] = odepkg_mexsolver_odex (varargin{:});
  end

%# The following tests have been added to check the function's input arguments 
%# and output arguments
%!test
%!  if (!strcmp (which ("odepkg_mexsolver_odex"), ""))
%!    vsol = odeox (@odepkg_equations_vanderpol, [0 2], [2 0]);
%!  end 
%!test
%!  if (!strcmp (which ("odepkg_mexsolver_odex"), ""))
%!    [vx, vy] = odeox (@odepkg_equations_vanderpol, [0 2], [2 0]);
%!  end
%!test
%!  if (!strcmp (which ("odepkg_mexsolver_odex"), ""))
%!    [vx, vy, va, vb, vc] = odeox (@odepkg_equations_vanderpol, [0 2], [2 0]);
%!  end
%#
%# Removed the fixed step size tests because they won't work with this solver
%#
%!test
%!  if (!strcmp (which ("odepkg_mexsolver_odex"), ""))
%!    A = odeset ('MaxStep', 0.1, 'RelTol', 1e-2, 'AbsTol', 1e-3);
%!    vsol = odeox (@odepkg_equations_vanderpol, [0 2], [2 0], A);
%!  end
%!test
%!  if (!strcmp (which ("odepkg_mexsolver_odex"), ""))
%!    A = odeset ('MaxStep', 0.1, 'RelTol', 1e-2, 'AbsTol', 1e-3);
%!    [vx, vy] = odeox (@odepkg_equations_vanderpol, [0 2], [2 0], A);
%!  end
%!test
%!  if (!strcmp (which ("odepkg_mexsolver_odex"), ""))
%!    A = odeset ('MaxStep', 0.1, 'RelTol', 1e-2, 'AbsTol', 1e-3);
%!    [vx, vy, va, vb, vc] = odeox (@odepkg_equations_vanderpol, [0 2], [2 0], A);
%!  end
%!test
%!  if (!strcmp (which ("odepkg_mexsolver_odex"), ""))
%!    A = odeset ('MaxStep', 0.1, 'RelTol', 1e-2, 'AbsTol', 1e-3);
%!    vsol = odeox (@odepkg_equations_vanderpol, [0 2], [2 0], A, 1.2);
%!  end
%!test
%!  if (!strcmp (which ("odepkg_mexsolver_odex"), ""))
%!    A = odeset ('MaxStep', 0.1, 'RelTol', 1e-2, 'AbsTol', 1e-3);
%!    [vx, vy] = odeox (@odepkg_equations_vanderpol, [0 2], [2 0], A, 1.2);
%!  end
%!test
%!  if (!strcmp (which ("odepkg_mexsolver_odex"), ""))
%!    A = odeset ('MaxStep', 0.1, 'RelTol', 1e-2, 'AbsTol', 1e-3);
%!    [vx, vy, va, vb, vc] = odeox (@odepkg_equations_vanderpol, [0 2], [2 0], A, 1.2);
%!  end

%!demo
%!
%! A = odeset ('RelTol', 1e-1, 'AbsTol', 1e-2);
%! [vx, vy] = odeox (@odepkg_equations_secondorderlag, [0 2.5], [0 0], ...
%!    A, 5, 2, 0.02, 0.1);
%!
%! plot (vx, vy(:,1), '-ob;y, x2;', vx, vy(:,2), '-or;x1;', ...
%!    vx, ones(length(vx),1)*5, '-og;u;');
%!
%! % ---------------------------------------------------------------------
%! % The figure window shows the state variables x1, x2 as well as the 
%! % input signal u and the output signal y(=x2) of a second order lag 
%! % implementation (cf. the control theory). The function odeox was
%! % called with an option argument A that has been set before with the
%! % command "odeset" and with further parameters "5, 2, 0.02, 0.1" that
%! % are passed to the set of ordinary differential equations.

%# Local Variables: ***
%# mode: octave ***
%# End: ***
