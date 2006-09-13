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
%# @deftypefn {Function} {@var{[vret]} =} odeprint (@var{vt}, @var{vy}, @var{vflag})
%# Displays the results of the differential equations while solving. The return value @var{vret} depends on the input value @var{vflag}. If @var{vflag} is the string "init" then nothing is returned, else if @var{vflag} is the value true then either the value true is returned if the calling solver function should continue or the value false if the calling solver function should terminate, else if @var{vflag} is the string "done" then again nothing will be returned. The input arguments @var{vt} and @var{vy} are the actual time stamp and the solver outputs. There is no error handling implemented in this function to achieve the highest processing speed.
%#
%# Run
%# @example
%# demo odeprint
%# @end example
%# to see an example.
%# @end deftypefn
%#
%# @seealso{odepkg}

%# Maintainer: Thomas Treichl
%# Created: 20060809
%# ChangeLog:

function [varargout] = odeprint (vt, vy, vflag)
  %# No input argument check is done for a higher processing speed
  %# vt and vy are row vectors, vflag is either "init", true or false or "done"
  if (strcmp (vflag, 'init') == true) %# nothing to return
    vtstart = vt (1,1);
    printf ('%f', vtstart); printf (' %f', vy); printf ('\n');
  elseif (isempty (vflag) == true) %# Return varargout{1}
    printf ('%f', vt); printf (' %f', vy); printf ('\n');
    varargout{1} = true; %# Do not stop the integration algorithm
    %# if varargout{1} = false; stop the integration algorithm
  elseif (strcmp (vflag, 'done') == true) %# Cleanup will be done
    %# Nothing to do in this function
  else
    vmsg = sprintf ('Check number and types of input arguments');
  end

%!demo
%!
%! A = odeset ('OutputFcn', @odeprint);
%! [vx, vy] = ode78 (@odepkg_equations_secondorderlag, [0 1.5], [0 0], A);
%!
%! % ---------------------------------------------------------------------
%! % The output of the integration is ploted with odeprint because the
%! % OuputFcn property has been set with odeset.

%# Local Variables: ***
%# mode: octave ***
%# End: ***