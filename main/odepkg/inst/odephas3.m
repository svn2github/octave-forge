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
%# @deftypefn {Function} {@var{[ret]} =} odephas3 (@var{t, y, flag})
%# Opens a new figure window and plots the first result from the variable @var{y} over the second and the third result from the variable @var{y} in three dimensions while solving. The return value @var{ret} depends on the input value of the variable @var{flag}. If @var{flag} is the string "init" then nothing is returned, else if @var{flag} is empty then the value true (resp. value 1) is returned, else if @var{flag} is the string "done" then again nothing will be returned. The input arguments @var{t} and @var{y} are the actual time stamp and the solver output. This function is an odepkg plotter function that can be set with @command{odeset}, therefore this function should never be directly called by the user. No error handling has been implemented in this function to achieve the highest processing speed.
%#
%# Run
%# @example
%# demo odephas3
%# @end example
%# to see an example.
%# @end deftypefn
%#
%# @seealso{odepkg}

%# As in the definitions of initial value problems as functions and if
%# somebody uses event functions all input and output vectors must be
%# column vectors by now.
function [varargout] = odephas3 (vt, vy, vflag)

  %# vt and vy are always column vectors, vflag can be either 'init'
  %# or [] or 'done'. If 'init' then varargout{1} = [], if [] the
  %# varargout{1} either true or false, if 'done' then varargout{1} = [].
  persistent vfigure; persistent vyold; persistent vcounter;

  if (strcmp (vflag, 'init') == true) 
    %# vt is either the time slot [tstart tstop] or [t0, t1, ..., tn]
    %# vy is the inital value vector vinit from the caller function
    vfigure = figure; 
    vyold = vy(:,1); 
    vcounter = 1;

  elseif (isempty (vflag) == true)
    %# Return something in varargout{1}, either true for 'not stopping
    %# the integration' or false for 'stopping the integration'
    vcounter = vcounter + 1; 
    figure (vfigure);
    vyold(:,vcounter) = vy(:,1); 
    plot3 (vyold(1,:), vyold(2,:), vyold (3,:), '-o');
    drawnow;
    varargout{1} = true; 

  elseif (strcmp (vflag, 'done') == true)
    %# Cleanup has to be done, clear the persistent variables because
    %# we don't need them anymore
    clear ('vfigure', 'vyold', 'vcounter')

  end

%!demo
%!
%! A = odeset ('InitialStep', 1e-3, 'MaxStep', 1e-1, 'OutputFcn', @odephas3); 
%! [t,y] = ode78 (@odepkg_equations_lorenz, [0 25], [3 15 1], A);
%!
%! % --------------------------------------------------------------------------
%! % The output of the integration is ploted with odephas3 because the OuputFcn
%! % property has been set with odeset. The figure shows the state x1 as a 
%! % function of the state x2 from the Van der Pol implementation.

%# Local Variables: ***
%# mode: octave ***
%# End: ***
