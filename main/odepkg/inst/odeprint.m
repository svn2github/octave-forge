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
%# @deftypefn {Function File} {[@var{ret}] =} odeprint (@var{t}, @var{y}, @var{flag})
%#
%# Display the results of the set of differential equations in the Octave window while solving. The first column of the screen output shows the actual time stamp that is given with the input arguemtn @var{t}, the following columns show the results from the function evaluation that are given by the column vector @var{y}. The types and the values of the input parameter @var{t} and the output parameter @var{ret} depend on the input value @var{flag} that is of type string. If @var{flag} is
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
%# demo odeprint
%# @end example
%# @end deftypefn
%#
%# @seealso{odepkg}

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