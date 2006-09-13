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
%# @deftypefn {Function} {@var{[vret]} =} odephas3 (@var{vt}, @var{vy}, @var{vflag})
%# Opens a new figure window and plots the first, the second and the third result of the differential equation in three dimensions. The return value @var{vret} depends on the input value @var{vflag}. If @var{vflag} is the string "init" then nothing is returned, else if @var{vflag} is the value true (resp. logical 1) then either the value true is returned if the calling solver function should continue or the value false (resp. logical 0) if the calling solver function should terminate, else if @var{vflag} is the string "done" then again nothing will be returned. The input arguments @var{vt} and @var{vy} are the actual time stamp and the solver outputs. There is no error handling implemented in this function to achieve the highest performance.
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
  persistent vfigure; %# vt and vy are always row vectors
  persistent vyold;   %# and also for all OutputFcns in odepkg
  persistent vcounter;
  if (strcmp (vflag, 'init') == true) 
    %# nothing to return
    %# vt is either the time slot [tstart tstop] or [t0, t1, ..., tn]
    %# vy is the inital value vector vinit
    vfigure = figure; vyold = vy(1,:); vcounter = 1;
  elseif (isempty (vflag) == true)
     %# Return something in varargout{1}
    vcounter = vcounter + 1; figure (vfigure);
    vyold(vcounter,:) = vy(1,:); plot3 (vyold(:,1), vyold(:,2), vyold (:,3), '-o');
    varargout{1} = true; 
    %# Do not stop the integration algorithm
    %# if varargout{1} = false; stop the integration algorithm
  elseif (strcmp (vflag, 'done') == true)
    %# Cleanup will be done
    %# Nothing to do in this function
  else
    %# vmsg = sprintf ('Check number and types of input arguments');
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
