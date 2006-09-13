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
%# @deftypefn  {Function} odepkg_equations_vanderpol ()
%# Displays the help text of the function and exits with an error.
%#
%# @deftypefnx {Function} {@var{ydot} =} odepkg_equations_vanderpol (@var{tvar}, @var{yvar})
%# Returns the states of the "Van Der Pol Equation" example that depend on the input argument @var{yvar}. The variable @var{yvar} must be a valid column vector. Optionally the "Second Order Lag" can be parametrized by the variables @var{vu} as the input signal, @var{vK} as the amplification, @var{vT1} as the smaller time constant and @var{vT2} as the greater time constant. Use "type odepkg_equations_secondorderlag" to see the source code of this "Linear Time-Invariant" (LTI) system. If an invalid input argument is given then the function terminates with an error.Use "type odepkg_equations_vanderpol" to see the source code of this differential equation.
%#
%# Run
%# @example
%# demo odepkg_equations_vanderpol
%# @end example
%# to see an example.
%# @end deftypefn
%#
%# @seealso{odepkg}

%# Maintainer: Thomas Treichl
%# Created: 20060809
%# ChangeLog:

function ydot = odepkg_equations_vanderpol (tvar, yvar, varargin)
  %# odepkg_equations_vanderpol is a demo function. Therefore some
  %# error handling is done. If you would write your own function you
  %# would not add any error handling to achieve highest performance.
  if (nargin == 0)
    help ('odepkg_equations_vanderpol');
    vmsg = sprintf ('Number of input arguments must be greater than zero');
    error (vmsg);
  elseif (nargin < 2 || nargin > 3)
    vmsg = sprintf ('Number of input arguments must be greater 1 and lower 4');
    error (vmsg);
  elseif (isnumeric (tvar) == false || isnumeric (yvar) == false)
    vmsg = sprintf ('First and second input argument must be valid numeric values');
    error (vmsg);
  elseif (isvector (yvar) == false || length (yvar) ~= 2)
    vmsg = sprintf ('Second input argument must be a vector of length 2');
    error (vmsg);
  end

  if (length (varargin) == 1) %# Check if parameter mu is given
    if (isscalar (varargin{1}) == true)
      mu = varargin{1};
    else
      vmsg = sprintf ('Third input argument must be a valid scalar');
      error (vmsg);
    end
  else, mu = 1; end

  %# yvar and ydot must be row vectors with 1 column
  ydot = [yvar(2); mu*(1-yvar(1)^2)*yvar(2)-yvar(1)];

%!test [vt, vy] = ode23 (@odepkg_equations_vanderpol, [0 1], [2 0]);
%!test [vt, vy] = ode23 (@odepkg_equations_vanderpol, [0 1], [2 2], 300);

%!demo
%!
%! [vt, vy] = ode45 (@odepkg_equations_vanderpol, [0 20], [2 0]);
%!
%! axis ([0, 20]);
%! plot (vt, vy(:,1), '-or;x1(t);', vt, vy(:,2), '-ob;x2(t);');
%!
%! % ----------------------------------------------------------------------
%! % The figure window shows the two states of the "Van Der Pol Equation"
%! % example. The math equation for this differential equation is
%! %   d^2y/dt^2 - mu*(1-y^2)*dy/dt + y = 0.
%! % If not manually parametrized then mu = 1 as in this demo.
%!demo
%!
%! [vt, vy] = ode45 (@odepkg_equations_vanderpol, [0 40], [2 0], 20);
%!
%! axis ([0, 40]);
%! plot (vt, vy(:,1), '-or;x1(t);', vt, vy(:,2), '-ob;x2(t);');
%!
%! % ----------------------------------------------------------------------
%! % The figure window shows the two integrated states of the "Van Der Pol
%! % Equation" example. The parameter mu = 20 was set manually in this
%! % demo.

%# Local Variables: ***
%# mode: octave ***
%# End: ***