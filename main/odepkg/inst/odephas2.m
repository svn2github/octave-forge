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
%# @deftypefn {Function} {@var{ret} =} odephas2 (@var{t, y, flag})
%# Opens a new figure window and plots the first result from the variable @var{y} over the second result from the variable @var{y} while solving. The return value @var{ret} depends on the input value of the variable @var{flag}. If @var{flag} is the string "init" then nothing is returned, else if @var{flag} is empty then the value true (resp. value 1) is returned, else if @var{flag} is the string "done" then again nothing will be returned. The input arguments @var{t} and @var{y} are the actual time stamp and the solver outputs. The value of the variable @var{t} is not needed by this function. The input arguments @var{t} and @var{y} are the actual time stamp and the solver output. This function is an odepkg plotter function that can be set with @command{odeset}, therefore this function should never be directly called by the user. No error handling has been implemented in this function to achieve the highest processing speed.
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
%# ChangeLog: 20060929, Thomas Treichl
%#    As in the definitions of initial value problems as functions and
%#    if somebody uses event functions all input and output vectors
%#    must be column vectors by now.

function [varargout] = odephas2 (vt, vy, vflag)

  %# No input argument check is done for a higher processing speed
  persistent vfigure; persistent vyold; persistent vcounter;

  if (strcmp (vflag, 'init') == true) 
    %# Nothing to return, vt is either the time slot [tstart tstop]
    %# or [t0, t1, ..., tn], vy is the inital value vector 'vinit'
    vfigure = figure; vyold = vy(:,1); vcounter = 1;

  elseif (isempty (vflag) == true) 
    %# Return something in varargout{1}, either true for 'not stopping
    %# the integration' or false for 'stopping the integration'
    vcounter = vcounter + 1; 
    figure (vfigure);
    vyold(:,vcounter) = vy(:,1); 
    plot (vyold(1,:), vyold(2,:), '-o');
    varargout{1} = true; 
    %# Do not stop the integration algorithm if varargout{1} = true;
    %# stop the integration algorithm if varargout{1} = false;

  elseif (strcmp (vflag, 'done') == true) 
    %# Cleanup has to be done, clear the persistent variables because
    %# we don't need them anymore
    clear ('vfigure', 'vyold', 'vcounter')

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
