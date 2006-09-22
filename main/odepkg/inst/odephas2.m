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
%# @deftypefn {Function} {@var{[ret]} =} odephas2 (@var{t, y, flag})
%# Opens a new figure window and plots the first and the second result from the variable @var{y} of the differential equation in two dimensions while solving. The return value @var{ret} depends on the input value  of the variable @var{flag}. If @var{flag} is the string "init" then nothing is returned, else if @var{flag} is empty then the value true (resp. value 1) is returned, else if @var{flag} is the string "done" then again nothing will be returned. The input arguments @var{t} and @var{y} are the actual time stamp and the solver outputs. The value of the variable @var{t} is not needed by this function. There is no error handling implemented in this function to achieve the highest performance.
%#
%# Run
%# @example
%# demo odephas2
%# @end example
%# to see an example.
%# @end deftypefn
%#
%# @seealso{odepkg}

%# Maintainer: Thomas Treichl
%# Created: 20060906
%# ChangeLog:

function [varargout] = odephas2 (vt, vy, vflag)
  %# vt and vy are always row vectors for all OutputFcns in odepkg
  persistent vfigure;
  persistent vyold;
  persistent vcounter;

  if (strcmp (vflag, 'init') == true) 
    %# nothing to return, vt is either the time slot [tstart tstop] or
    %# [t0, t1, ..., tn], vy is the inital value vector vinit
    vfigure = figure; vyold = vy(1,:); vcounter = 1;

  elseif (isempty (vflag) == true) 
    %# Return something in varargout{1}
    vcounter = vcounter + 1; 
    figure (vfigure);
    vyold(vcounter,:) = vy(1,:); 
    plot (vyold(:,1), vyold(:,2), '-o');
    varargout{1} = true; 
    %# Do not stop the integration algorithm if varargout{1} = true;
    %# stop the integration algorithm if varargout{1} = false;

  elseif (strcmp (vflag, 'done') == true) 
    %# Cleanup will be done but nothing to do in this function

  else
    %# Not necessary - cf. source code of function odeprint
    %# vmsg = sprintf ('Check number and types of input arguments');
  end

%!demo
%!
%! A = odeset ('OutputFcn', @odephas2, 'RelTol', 1e-3);
%! [vx, vy] = ode54 (@odepkg_equations_vanderpol, [0 20], [2 0], A);
%!
%! % --------------------------------------------------------------------------
%! % The output of the integration is ploted with odephas2 because the OuputFcn
%! % property has been set with odeset. The figure shows the state x1 as a 
%! % function of the state x2 from the Van der Pol implementation.
%!demo
%!
%! A = odeset ('OutputFcn', @odephas2, 'RelTol', 1e-7);
%! [vx, vy] = ode45 (@odepkg_equations_secondorderlag, [0 1.5], [0 0], A);
%!
%! % --------------------------------------------------------------------------
%! % The output of the integration is ploted with odephas2 because the OuputFcn
%! % property has been set with odeset. The figure shows the state x1 as a 
%! % function of the state x2 from the second order lag implementation.

%# Local Variables: ***
%# mode: octave ***
%# End: ***
