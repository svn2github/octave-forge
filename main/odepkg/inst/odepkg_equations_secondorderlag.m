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
%# @deftypefn  {Function} odepkg_equations_secondorderlag ()
%# Displays the help text of the function and exits with an error.
%#
%# @deftypefnx {Function} {@var{[ydot]} =} odepkg_equations_secondorderlag (@var{tvar}, @var{yvar}, @var{[vu, vK, vT1, vT2]})
%# Returns the states of the "Second Order Lag" example (control theory) that only depend on the input argument @var{yvar}. The unused variable @var{tvar} is ignored. The variable @var{yvar} must be a valid column vector. Optionally the "Second Order Lag" can be parametrized by the variables @var{vu} as the input signal, @var{vK} as the amplification, @var{vT1} as the smaller time constant and @var{vT2} as the greater time constant. Use "type odepkg_equations_secondorderlag" to see the source code of this "Linear Time-Invariant" (LTI) system. If an invalid input argument is given then the function terminates with an error.
%#
%# Run
%# @example
%# demo odepkg_equations_secondorderlag
%# @end example
%# to see an example.
%# @end deftypefn
%#
%# @seealso{odepkg}

%# Maintainer: Thomas Treichl
%# Created: 20060809
%# ChangeLog:

function ydot = odepkg_equations_secondorderlag (tvar, yvar, varargin)
  %# odepkg_equations_vanderpol is a demo function. Therefore some
  %# error handling is done. If you would write your own function you
  %# would not add any error handling to achieve highest performance.
  if (nargin == 0)
    help ('odepkg_equations_secondorderlag');
    vmsg = sprintf ('Number of input arguments must be greater than zero');
    error (vmsg);
  elseif (nargin <= 1)
    vmsg = sprintf ('Number of input arguments must be greater or equal than 2');
    error (vmsg);
  elseif (isnumeric (tvar) == false || isnumeric (yvar) == false)
    vmsg = sprintf ('First and second input argument must be valid numeric values');
    error (vmsg);
  elseif (isvector (yvar) == false || length (yvar) ~= 2)
    vmsg = sprintf ('Second input argument must be a vector of length 2');
    error (vmsg);
  end

  %# yvar and ydot must be column vectors
  %# Check if the parametrizing arguments are given
  if (length (varargin) > 0)
    if (length (varargin) ~= 4)
      vmsg = sprintf ('If parametrizing arguments are given then number of these arguments must match 4');
      error (vmsg);
    end
    vu  = varargin{1}; %# vu is the input signal of the control system
    vK  = varargin{2}; %# vK is the amplification of the control system
    vT1 = varargin{3}; %# vT1 is the smaller time constant that can be neglected
    vT2 = varargin{4}; %# vT2 is the greater time constant that is dominant
  else
    vu  = 10; vK  = 1; vT1 = 0.01; vT2 = 0.1;
  end

  ydot(1,1) = yvar(2,1);
  ydot(2,1) = 1/vT1 * (- yvar(1,1) - vT2*yvar(2,1) + vK*vu);

%!test [vt, vy] = ode45 (@odepkg_equations_secondorderlag, [0 1], [0 0]);
%!test [vt, vy] = ode45 (@odepkg_equations_secondorderlag, [0 1], [3 2]);

%!demo
%!
%! A = odeset ('RelTol', 1e-3);
%! [vt, vy] = ode45 (@odepkg_equations_secondorderlag, [0 1.4], [0 0], A);
%! 
%! axis ([0 1.4]);
%! plot(vt, 10 * ones (length (vy(:,1)),1), "-or;in (t);", ...
%!      vt, vy(:,1), "-ob;out (t);");
%!
%! % ----------------------------------------------------------------------
%! % The figure window shows the input signal and the output signal of the
%! % "Second Order Lag" example. The math equation for this differential
%! % equation is 
%! %   y + dy/dt*T2 + d^2y/dt2*T1 = u*K.
%! % If not manually parametrized then u = 10, K = 1, T1 = 0.01s and
%! % T2 = 0.1s^2. The accumulated value (t->inf) is y = u*K = 10.
%!demo
%!
%! A = odeset ('RelTol', 2e-2, 'NormControl', 'on');
%! [vt, vy] = ode45 (@odepkg_equations_secondorderlag, ...
%!                      [0 12], [0 0],  A, 5, 1, 0.01, 0.01);
%! 
%! axis ([0 12]);
%! plot(vt, 5 * ones (length (vy(:,1)),1), "-or;in (t);", ...
%!      vt, vy(:,1), "-ob;out (t);");
%!
%! % ----------------------------------------------------------------------
%! % The figure window shows the input signal and the output signal of a
%! % different parametrized "Second Order Lag" example. The parameters for
%! % this example are u = 5, K = 1, T1 = 0.01, T2 = 0.01. The accumulated 
%! % value (t->inf) is y = u*K = 5.

%# Local Variables: ***
%# mode: octave ***
%# End: ***
