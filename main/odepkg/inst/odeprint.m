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
%# @deftypefn {Function} {@var{[ret]} =} odeprint (@var{t, y, flag})
%# Displays the results of the differential equations in the octave window while solving. The first column shows the actual time stamp, the following columns show the values of the solvers for each time stamp. The return value @var{ret} depends on the input value @var{flag}. If @var{flag} is the string "init" then nothing is returned, else if @var{flag} is empty then true (resp. value 1) is returned to tell the calling solver function to continue, else if @var{flag} is the string "done" then again nothing will be returned. The input arguments @var{t} and @var{y} are the actual time stamp and the solver output. This function is an odepkg plotter function that can be set with @command{odeset}, therefore this function should never be directly called by the user. No error handling has been implemented in this function to achieve the highest processing speed.
%#
%# Run
%# @example
%# demo odeprint
%# @end example
%# to see an example.
%# @end deftypefn
%#
%# @seealso{odepkg}

%# As in the definitions of initial value problems as functions and if
%# somebody uses event functions all input and output vectors must be
%# column vectors by now.
function [varargout] = odeprint (vt, vy, vflag, varargin)

  %# No input argument check is done for a higher processing speed
  %# vt and vy are always column vectors, see also function odeplot,
  %# odephas2 and odephas3 for another implementation. vflag either
  %# is "init", [] or "done".

  if (strcmp (vflag, 'init') == true)
    fprintf (1, '%f%s\n', vt (1,1), sprintf (' %f', vy) );
    fflush (1);

  elseif (isempty (vflag) == true) %# Return varargout{1}
    fprintf (1, '%f%s\n', vt (1,1), sprintf (' %f', vy) );
    fflush (1);
    varargout{1} = true; 
    %# Do not stop the integration algorithm
    %# if varargout{1} = false; stop the integration algorithm

  elseif (strcmp (vflag, 'done') == true) 
    %# Cleanup could be done, but nothing to do in this function

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