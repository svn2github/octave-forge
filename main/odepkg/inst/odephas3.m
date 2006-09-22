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
%# @deftypefn {Function} {@var{[ret]} =} odephas3 (@var{t, y, flag})
%# Opens a new figure window and plots the first, the second and the third result from the variable @var{y} of the differential equations in three dimensions while solving. The return value @var{ret} depends on the input value of the variable @var{flag}. If @var{flag} is the string "init" then nothing is returned, else if @var{flag} is empty then the value true (resp. value 1) is returned, else if @var{flag} is the string "done" then again nothing will be returned. The input arguments @var{t} and @var{y} are the actual time stamp and the solver outputs. The value of the variable @var{t} is not needed by this function. There is no error handling implemented in this function to achieve the highest performance.
%#
%# Run
%# @example
%# demo odephas3
%# @end example
%# to see an example.
%# @end deftypefn
%#
%# @seealso{odepkg}

%# Maintainer: Thomas Treichl
%# Created: 20060912
%# ChangeLog:

function [varargout] = odephas3 (vt, vy, vflag)
  %# vt and vy are always row vectors, vflag can be either 'init' or []
  %# or 'done'. If 'init' then varargout{1} = [], if [] the
  %# varargout{1} either true or false, if 'done' then varargout{1} = [].
  persistent vfigure;
  persistent vyold;
  persistent vcounter;

  if (strcmp (vflag, 'init') == true) 
    %# vt is either the time slot [tstart tstop] or [t0, t1, ..., tn]
    %# vy is the inital value vector vinit from the caller function
    vfigure = figure; 
    vyold = vy(1,:); 
    vcounter = 1;

  elseif (isempty (vflag) == true)
    %# Return something in varargout{1} = true or false
    vcounter = vcounter + 1; 
    figure (vfigure);
    vyold(vcounter,:) = vy(1,:); 
    plot3 (vyold(:,1), vyold(:,2), vyold (:,3), '-o');
    varargout{1} = true; 
    %# Do not stop the integration algorithm if varargout{1} = true;
    %# if varargout{1} = false; stop the integration algorithm

  elseif (strcmp (vflag, 'done') == true)
    %# Cleanup will be done, but nothing to do in this function

  else
    vmsg = sprintf ('Check number and types of input arguments');
    error (vmsg);

  end %# if (strcmp (vflag, 'init') == true)

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
