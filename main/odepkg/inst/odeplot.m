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
%# @deftypefn {Function} {@var{[vret]} =} odeplot (@var{vt}, @var{vy}, @var{vflag})
%# Opens a new figure window and plots the results of the differential equations while solving. The return value @var{vret} depends on the input value @var{vflag}. If @var{vflag} is the string "init" then nothing is returned, else if @var{vflag} is the value true then either the value true is returned if the calling solver function should continue or the value false if the calling solver function should terminate, else if @var{vflag} is the string "done" then again nothing will be returned. The input arguments @var{vt} and @var{vy} are the actual time stamp and the solver outputs. There is no error handling implemented in this function to achieve the highest processing speed.
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
%# ChangeLog:

function [varargout] = odeplot (vt, vy, vflag)
  %# No input argument check is done for a higher processing speed
  %# vt and vy are row vectors
  persistent vfigure; persistent vtold; 
  persistent vyold; persistent vcounter;
  if (strcmp (vflag, 'init') == true) %# nothing to return
    %# vt is either the time slot [tstart tstop] or [t0, t1, ..., tn]
    %# vy is the inital value vector vinit
    vfigure = figure; axis ([vt(1,1), vt(1,length(vt))]);
    vtold = vt(1,1); vyold = vy(1,:); vcounter = 1;
  elseif (isempty (vflag) == true) %# Return varargout{1}
    vcounter = vcounter + 1; figure (vfigure);
    vtold(vcounter,1) = vt(1,1); vyold(vcounter,:) = vy(1,:);
    plot (vtold, vyold, '-o');
    varargout{1} = true; %# Do not stop the integration algorithm
    %# if varargout{1} = false; stop the integration algorithm
  elseif (strcmp (vflag, 'done') == true) %# Cleanup will be done

  else
%    vmsg = sprintf ('Check number and types of input arguments');
  end

%!demo
%!
%! A = odeset ('MaxStep', 1.5/100);
%! ode2f (@odepkg_example_secondorderlag, [0 1.5], [0 0], A);
%!
%! % ----------------------------------------------------------------
%! % The output of the integration is ploted automatically with
%! % odeplot because nargout == 0 when calling ode2f.
%!demo
%!
%! A = odeset ('MaxStep', 1.5/100, 'OutputFcn', @odeplot);
%! [vx, vy] = ode2f (@odepkg_example_secondorderlag, [0 1.5], [0 0], A);
%!
%! % ---------------------------------------------------------------------------
%! % The output of the integration is ploted with odeplot because the OuputFcn
%! % property has been set with odeset.

%# Local Variables: ***
%# mode: octave ***
%# End: ***