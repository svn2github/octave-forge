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
%# @deftypefn {Function} {@var{[ret]} =} odeplot (@var{t, y, flag})
%# Opens a new figure window and plots the results from the variable @var{y} over time while solving. The return value @var{ret} depends on the input value @var{flag}. If @var{flag} is the string "init" then nothing is returned, else if @var{flag} is empty then the value true (resp. value 1) is returned, else if @var{flag} is the string "done" then again nothing will be returned. The input arguments @var{t} and @var{y} are the actual time stamp and the solver output. This function is an odepkg plotter function that can be set with @command{odeset}, therefore this function should never be directly called by the user. No error handling has been implemented in this function to achieve the highest processing speed.
%#
%# Run
%# @example
%# demo odeplot
%# @end example
%# to see an example.
%# @end deftypefn
%#
%# @seealso{odepkg}

%# Maintainer: Thomas Treichl
%# Created: 20060809
%# ChangeLog: 20060929, Thomas Treichl
%#    As in the definitions of initial value problems as functions
%#    and if somebody uses event functions all input and output
%#    vectors must be column vectors by now.

function [varargout] = odeplot (vt, vy, vflag)

  %# No input argument check is done for a higher processing speed
  persistent vfigure; persistent vtold; 
  persistent vyold; persistent vcounter;

  if (strcmp (vflag, 'init') == true) 
    %# Nothing to return, vt is either the time slot [tstart tstop]
    %# or [t0, t1, ..., tn], vy is the inital value vector 'vinit'
    vfigure = figure; 
%#  axis ([vt(1,1), vt(1,length(vt))]);
    vtold = vt(1,1); 
    vyold = vy(:,1); 
    vcounter = 1;

  elseif (isempty (vflag) == true) 
    %# Return something in varargout{1}, either true for 'not stopping
    %# the integration' or false for 'stopping the integration'
    vcounter = vcounter + 1; 
    figure (vfigure);
    vtold(vcounter,1) = vt(1,1); 
    vyold(:,vcounter) = vy(:,1);
    plot (vtold, vyold, '-o');
    drawnow;
    varargout{1} = true; 

  elseif (strcmp (vflag, 'done') == true) 
    %# Cleanup has to be done, clear the persistent variables because
    %# we don't need them anymore
    clear ('vfigure', 'vtold', 'vyold', 'vcounter')

  end

%!demo
%!
%! A = odeset ('MaxStep', 1.5/30, 'Refine', 3);
%! ode45 (@odepkg_equations_secondorderlag, [0 1.5], [0 0], A);
%!
%! % ----------------------------------------------------------------
%! % The output of the integration is ploted automatically with
%! % odeplot because nargout == 0 when calling ode2f.
%!demo
%!
%! A = odeset ('OutputFcn', @odeplot, 'Refine', 0);
%! [vx, vy] = ode45 (@odepkg_equations_secondorderlag, [0 1.5], [0 0], A);
%!
%! % ---------------------------------------------------------------------------
%! % The output of the integration is ploted with odeplot because the OuputFcn
%! % property has been set with odeset.

%# Local Variables: ***
%# mode: octave ***
%# End: ***