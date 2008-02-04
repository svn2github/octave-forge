%# Copyright (C) 2006-2008, Thomas Treichl <treichl@users.sourceforge.net>
%# OdePkg - A package for solving differential equations with GNU Octave
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
%# along with this program; If not, see <http://www.gnu.org/licenses/>.

%# -*- texinfo -*-
%# @deftypefn {Function File} {[@var{sol}] =} odepkg_event_handle (@var{@@fun}, @var{time}, @var{y}, @var{flag}, [@var{par1}, @var{par2}, @dots{}])
%#
%# Return the solution of the event function that is specified as the first input argument @var{@@fun} in form of a function handle. The second input argument @var{time} is of type double scalar and specifies the time of the event evaluation, the third input argument @var{y} is of type double column vector and specifies the solutions, the third input argument @var{flag} is of type string and can be of the form 
%# @table @option
%# @item  @code{"init"}
%# then initialize internal persistent variables of the function @command{odepkg_event_handle} and return an empty cell array of size 4,
%# @item  @code{"calc"}
%# then do the evaluation of the event function and return the solution @var{sol} as type cell array of size 4,
%# @item  @code{"done"}
%# then cleanup internal variables of the function @command{odepkg_event_handle} and return an empty cell array of size 4.
%# @end table
%# Optionally if further input arguments @var{par1}, @var{par2}, @dots{} of any type are given then pass these parameters through @command{odepkg_event_handle} to the event function.
%#
%# This function is an OdePkg internal helper function therefore it should never be necessary that this function is called directly by a user. There is only little error detection implemented in this function file to achieve the highest performance.
%# @end deftypefn
%#
%# @seealso{odepkg}

function [vretval] = odepkg_event_handle (vevefun, vt, vy, vflag, varargin)

  %# No error handling has been implemented in this function to achieve
  %# the highest performance available.

  %# vretval{1} is true or false; either to terminate or to continue
  %# vretval{2} is the index information for which event occured
  %# vretval{3} is the time information column vector
  %# vretval{4} is the line by line result information matrix

  %# These persistent variables are needed to store the results and the
  %# time value from the processing in the time stamp before, veveold
  %# are the results from the event function, vtold the time stamp,
  %# vretcell the return values cell array, vyold the result of the ode
  %# and vevecnt the counter for how often this event handling
  %# has been called
  persistent veveold;  persistent vtold;
  persistent vretcell; persistent vyold;
  persistent vevecnt;

  %# Call the event function if an event function has been defined to
  %# initialize the internal variables of the event function an to get
  %# a value for veveold
  if (strcmp (vflag, 'init'))

    if (isempty (varargin))
      [veveold, vterm, vdir] = feval (vevefun, vt, vy);
    else
      [veveold, vterm, vdir] = feval (vevefun, vt, vy, varargin);
    end

    %# My first implementation was to return row vectors from the event
    %# functions but this is faulty if we use LabMat events. So this has
    %# changed 20060928 and by now these return vectors must be column
    %# vectors. The not so nice implementation then is:
    veveold = veveold(:)'; vterm = vterm(:)'; vdir = vdir(:)';

    vtold = vt; %# veveold has been set in the code lines before
    for vcnt = 1:4, vretcell{vcnt} = []; end
    vyold = vy; vevecnt = 1;

  %# Process the event, find the zero crossings either for a rising
  %# or for a falling edge
  elseif (isempty (vflag))

    %# Call the event function if an event function has been defined to
    %# to get the value(s) veve
    if (isempty (varargin))
      [veve, vterm, vdir] = feval (vevefun, vt, vy);
    else
      [veve, vterm, vdir] = feval (vevefun, vt, vy, varargin);
    end
    veve = veve(:)'; vterm = vterm(:)'; vdir = vdir(:)';

    %# Check if one or more signs of the event function results changed
    vsignum = (sign (veveold) ~= sign (veve));
    if (any (vsignum))         %# One or more values have changed
      vindex = find (vsignum); %# Get the index of the changed values

      if (any (vdir(vindex) == 0)) %# Rising or falling (both are possible)
        %# Don't change anything, keep the index
      elseif (any (vdir(vindex) == sign (veve(vindex))))
        %# Detected rising or falling, need a new index
        vindex = find (vdir == sign (veve));
      else
        %# Found a zero crossing that will not be notified
        vindex = [];
      end

      %# We create a new output values if we found a valid index 
      if (~isempty (vindex))
        %# Change the persistent result cell array
        vretcell{1} = any (vterm(vindex));    %# Stop integration or not
        vretcell{2}(vevecnt,1) = vindex(1,1); %# Take first event that occurs
        %# Calculate the time stamp when the event function returned 0 and
        %# calculate new values for the integration results, we do both by
        %# a linear interpolation
        vtnew = vt - veve(1,vindex) * (vt - vtold) / (veve(1,vindex) - veveold(1,vindex));
        vynew = (vy - (vt - vtnew) * (vy - vyold) / (vt - vtold));
        vretcell{3}(vevecnt,1) = vtnew;
        vretcell{4}(vevecnt,:) = vynew';
        vevecnt = vevecnt + 1;
      end

    end %# Check if one or more signs ...
    veveold = veve; vtold = vt;
    vretval = vretcell; vyold = vy;

  %# Reset this event handling function
  elseif (strcmp (vflag, 'done'))
    clear ('veveold', 'vtold', 'vretcell', 'vyold', 'vevecnt');
    for vcnt = 1:4, vretcell{vcnt} = []; end

  end %# if (strcmp (vflag, ...) == true)

%!function [veve, vterm, vdir] = feve (vt, vy, varargin)
%!  veve  = vy(1); %# Which event component should be tread
%!  vterm =     1; %# Terminate if an event is found
%!  vdir  =    -1; %# In which direction, -1 for falling
%!test 
%!  odepkg_event_handle (@feve, 0.0, [0 1 2 3], 'init', 123, 456);
%!test
%!  A = odepkg_event_handle (@feve, 2.0, [0 0 3 2], '', 123, 456);
%!  if ~(iscell (A) && isempty (A{1})), error; end
%!  A = odepkg_event_handle (@feve, 3.0, [-1 0 3 2], '', 123, 456);
%!  if ~(iscell (A) && A{1} == 1), error; end
%!test
%!  odepkg_event_handle (@feve, 4.0, [0 1 2 3], 'done', 123, 456);

%# Local Variables: ***
%# mode: octave ***
%# End: ***
