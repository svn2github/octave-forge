%# Copyright (C) 2006-2007, Thomas Treichl <treichl@users.sourceforge.net>
%# OdePkg - A package for solving differential equations with GNU Octave
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
%# @deftypefn  {Function File} {[@var{}] =} ode5d (@var{@@fun}, @var{slot}, @var{init}, [@var{opt}], [@var{par1}, @var{par2}, @dots{}])
%# @deftypefnx {Command} {[@var{sol}] =} ode5d (@var{@@fun}, @var{slot}, @var{init}, [@var{opt}], [@var{par1}, @var{par2}, @dots{}])
%# @deftypefnx {Command} {[@var{t}, @var{y}, [@var{xe}, @var{ye}, @var{ie}]] =} ode5d (@var{@@fun}, @var{slot}, @var{init}, [@var{opt}], [@var{par1}, @var{par2}, @dots{}])
%#
%# This function file can be used to solve a set of non--stiff ordinary differential equations (non--stiff ODEs) or non--stiff differential algebraic equations (non--stiff DAEs) with the well known explicit Runge--Kutta method of order (5,4).
%#
%# @b{Note: The function files @file{odepkg_mexsolver_dopri5} and @file{ode5d} will be removed when version 0.4.0 of OdePkg will be released. A similiar solver method is @file{ode54}, please use the @file{ode54} solver instead.}
%#
%# @end deftypefn
%# @seealso{odepkg}

function [varargout] = ode5d (varargin)
  warning ('Solver ode5d is deprecated and will be removed with OdePkg 0.4.0');
  warning ('Use the very similiar solver ode54 instead.');
  if (exist ('odepkg_mexsolver_dopri5') != 3)
    error ('Mex-function "odepkg_mexsolver_dopri5" is not installed');
  else
    [varargout{1:nargout}] = odepkg_mexsolver_dopri5 (varargin{:});
    end
  end

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
