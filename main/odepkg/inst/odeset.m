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
%# @deftypefn  {Function} {@var{[odestruct]} =} odeset ()
%# @deftypefnx {Function} {@var{[odestruct]} =} odeset (@var{"field1"}, @var{value1}, @dots{})
%# @deftypefnx {Function} {@var{[odestruct]} =} odeset (@var{oldstruct}, @var{"field1"}, @var{value1}, @dots{})
%# @deftypefnx {Function} {@var{[odestruct]} =} odeset (@var{oldstruct}, @var{newstruct})
%#
%# If called without any input argument then creates a new OdePkg options structure with all necessary fields and sets the values of all fields to default values.
%#
%# If called with string input arguments identifying valid OdePkg options then creates a new OdePkg options structure with all necessary fields and sets the values of the fields @var{field1}, @var{field2} etc. to the values @var{value1}, @var{value2}, etc.
%#
%# If called with the first input argument being a valid OdePkg structure then overwrites all values of options of the structure @var{oldstruct} in the fields @var{field1}, @var{field2}, etc. with new values @var{value1}, @var{value2}, etc.
%#
%# If called with two valid OdePkg structures then overwrites all values in the fields from the structure @var{oldstruct} with new values of the fields from the structure @var{newstruct}. Empty structure values from @var{newstruct} will not overwrite structure values from @var{oldstruct}.
%#
%# Run
%# @example
%# demo odeset
%# @end example
%# to see an example.
%# @end deftypefn
%#
%# @seealso{odepkg}

%# The OdePkg options structure may contain the following fields and default values if calling @command{odeset}
%#
%# @itemize @var
%# @item "RelTol" must be a positive scalar (default 1e-3)
%# @item "AbsTol" must be a positive scalar (default 1e-6)
%# @item "NormControl" must be "on" or "off" (default "off")
%# @item "NonNegative" must be a vector of integers (default [])
%# @item "OutputFcn" must be a function handle (default [])
%# @item "OutputSel" must be a vector of integers (default [])
%# @item "Refine" must be a positive integer (default 0)
%# @item "Stats" must be "on" or "off" (default "off")
%# @item "InitialStep" must be a positive scalar (default [])
%# @item "MaxStep" must be a positive scalar (default [])
%# @item "Events" must be a function handle (default [])
%# @item "Jacobian" must be a function handle or a matrix (default [])
%# @item "JPattern" must be a sparse matrix (default [])
%# @item "Vectorized" must be "on" or "off" (default "off")
%# @item "Mass" must be a function handle or a matrix (default [])
%# @item "MStateDependence" must be "none", "weak" or "strong" (default "weak")
%# @item "MvPattern" must be a sparse matrix (default [])
%# @item "MassSingular" must be "yes", "no" or "maybe" (default "maybe")
%# @item "InitialSlope" must be a vector (default [])
%# @item "MaxOrder" must be an integer between 1 and 5 (default 5)
%# @item "BDF" must be "on" or "off" (default "off")
%# @end itemize

function [vret] = odeset (varargin)

  %# Create a template OdePkg structure
  vtemplate = struct ...
    ('RelTol', [], ...
     'AbsTol', [], ...
     'NormControl', 'off', ...
     'NonNegative', [], ...
     'OutputFcn', [], ...
     'OutputSel', [], ...
     'Refine', 0, ...
     'Stats', 'off', ...
     'InitialStep', [], ...
     'MaxStep', [], ...
     'Events', [], ...
     'Jacobian', [], ...
     'JPattern', [], ...
     'Vectorized', 'off', ...
     'Mass', [], ...
     'MStateDependence', 'weak', ...
     'MvPattern', [], ...
     'MassSingular', 'maybe', ...
     'InitialSlope', [], ...
     'MaxOrder', [], ...
     'BDF', 'off');

  %# Check number and types of all input arguments
  if (nargin == 0 && nargout == 1)
    vret = odepkg_structure_check (vtemplate);
    return;

  elseif (nargin == 0)
    help ('odeset');
    error ('OdePkg:InvalidArgument', ...
      'Number of input arguments must be greater than zero');

  elseif (length (varargin) < 2)
    usage ('odeset ("field1", "value1", ...)');

  elseif (ischar (varargin{1}) && mod (length (varargin), 2) == 0)
    %# Check if there is an odd number of input arguments. If this is
    %# true then save all the structure names in varg and its values in
    %# vval and increment vnmb for every option that is found.
    vnmb = 1;
    for vcntarg = 1:2:length (varargin)
      if (ischar (varargin{vcntarg}))
        varg{vnmb} = varargin{vcntarg};
        vval{vnmb} = varargin{vcntarg+1};
        vnmb = vnmb + 1;
      else
        error ('OdePkg:InvalidArgument', ...
          'Input argument number %d is no valid string', vcntarg);
      end
    end

    %# Create and return a new OdePkg structure and fill up all new
    %# field values that have been found.
    for vcntarg = 1:(vnmb-1)
      vtemplate.(varg{vcntarg}) = vval{vcntarg};
    end
    vret = odepkg_structure_check (vtemplate);

  elseif (isstruct (varargin{1}) && ischar (varargin{2}) && ...
    mod (length (varargin), 2) == 1)
    %# Check if there is an even number of input arguments. If this is
    %# true then the first input argument also must be a valid OdePkg
    %# structure. Save all the structure names in varg and its values in
    %# vval and increment the vnmb counter for every option that is
    %# found.
    vnmb = 1;
    for vcntarg = 2:2:length (varargin)
      if (ischar (varargin{vcntarg}))
        varg{vnmb} = varargin{vcntarg};
        vval{vnmb} = varargin{vcntarg+1};
        vnmb = vnmb + 1;
      else
        error ('OdePkg:InvalidArgument', ...
          'Input argument number %d is no valid string', vcntarg);
      end
    end

    %# Use the old OdePkg structure and fill up all new field values
    %# that have been found.
    vret = odepkg_structure_check (varargin{1});
    for vcntarg = 1:(vnmb-1)
      vret.(varg{vcntarg}) = vval{vcntarg};
    end
    vret = odepkg_structure_check (vret);

  elseif (isstruct (varargin{1}) && isstruct (varargin{2}) && ...
    length (varargin) == 2)
    %# Check if the two input arguments are valid OdePkg structures and
    %# also check if there does not exist any other input argument.
    vret = odepkg_structure_check (varargin{1});
    vnew = odepkg_structure_check (varargin{2});
    vfld = fieldnames (vnew);
    vlen = length (vfld);
    for vcntfld = 1:vlen
      if (~isempty (vnew.(vfld{vcntfld})))
        vret.(vfld{vcntfld}) = vnew.(vfld{vcntfld});
      end
    end
    vret = odepkg_structure_check (vret);

  else
    error ('OdePkg:InvalidArgument', ...
      'Check types and number of all input arguments');
  end

%# All tests that are needed to check if a correct resp. valid option
%# has been set are implemented in odepkg_structure_check.m.
%!test odeoptA = odeset ();
%!test odeoptB = odeset ('AbsTol', 1e-2, 'RelTol', 1e-1);
%!     if (odeoptB.AbsTol ~= 1e-2), error; end
%!     if (odeoptB.RelTol ~= 1e-1), error; end
%!test odeoptB = odeset ('AbsTol', 1e-2, 'RelTol', 1e-1);
%!     odeoptC = odeset (odeoptB, 'NormControl', 'on');
%!test odeoptB = odeset ('AbsTol', 1e-2, 'RelTol', 1e-1);
%!     odeoptC = odeset (odeoptB, 'NormControl', 'on');
%!     odeoptD = odeset (odeoptC, odeoptB);

%!demo
%!
%! odeoptA = odeset ();
%!
%! %------------------------------------------------------------------
%! % a new ode options structure has been created and saved in odeoptA
%!demo
%!
%! odeoptB = odeset ('AbsTol', 1e-2, 'RelTol', 1e-1);
%!
%! %-------------------------------------------------------------------
%! % a new ode options structure with new Options "AbsTol" and "RelTol" 
%! % has been created and saved in odeoptB
%!demo
%!
%! odeoptB = odeset ('AbsTol', 1e-2, 'RelTol', 1e-1);
%! odeoptC = odeset (odeoptB, 'NormControl', 'on');
%!
%! %-------------------------------------------------------------------
%! % a new ode options structure from odeoptB has been created with new
%! % Option "NormControl" and saved in odeoptC
%!demo
%!
%! odeoptB = odeset ('AbsTol', 1e-2, 'RelTol', 1e-1);
%! odeoptC = odeset (odeoptB, 'NormControl', 'on');
%! odeoptD = odeset (odeoptC, odeoptB);
%!
%! %-------------------------------------------------------------------
%! % a new ode options structure from odeoptB has been created with new
%! % Option "NormControl" and saved in odeoptC

%# Local Variables: ***
%# mode: octave ***
%# End: ***
