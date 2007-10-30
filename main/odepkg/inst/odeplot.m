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
%# @deftypefn {Function File} {[@var{ret}] =} odeplot (@var{t}, @var{y}, @var{flag})
%#
%# Open a new figure window and plot the results from the variable @var{y} of type column vector over time while solving. The types and the values of the input parameter @var{t} and the output parameter @var{ret} depend on the input value @var{flag} that is of type string. If @var{flag} is
%# @table @option
%# @item  @code{"init"}
%# then @var{t} must be a double column vector of length 2 with the first and the last time step and nothing is returned from this function,
%# @item  @code{""}
%# then @var{t} must be a double scalar specifying the actual time step and the return value is true (resp. value 1),
%# @item  @code{"done"}
%# then @var{t} must be a double scalar specifying the last time step and nothing is returned from this function.
%# @end table
%#
%# This function is called by a OdePkg solver function if it was specified in an OdePkg options structure with the @command{odeset}. This function is an OdePkg internal helper function therefore it should never be necessary that this function is called directly by a user. There is only little error detection implemented in this function file to achieve the highest performance.
%#
%# Run examples with the command
%# @example
%# demo odeplot
%# @end example
%# @end deftypefn
%#
%# @seealso{odepkg}

function [varargout] = odeplot (vt, vy, vflag)

  %# No input argument check is done for a higher processing speed
  persistent vfigure; persistent vtold; 
  persistent vyold; persistent vcounter;

  if (strcmp (vflag, 'init') == true) 
    %# Nothing to return, vt is either the time slot [tstart tstop]
    %# or [t0, t1, ..., tn], vy is the inital value vector 'vinit'
    vfigure = figure; 
%# axis ([vt(1,1), vt(1,length(vt))]);
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