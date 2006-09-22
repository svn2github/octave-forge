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
%# @deftypefn  {Function} odeset ()
%# Displays the help text of the function and terminates with an error.
%#
%# @deftypefnx {Function} {@var{[odestruct]} =} odeset ()
%# Creates a new ode options structure with all necessary fields and sets the values of all fields to the defaults.
%#
%# @deftypefnx {Function} {@var{[odestruct]} =} odeset (@var{"field1"}, @var{value1}, @dots{})
%# Creates a new ode options structure with all necessary fields and sets the values of the fields @var{field1}, @var{field2} etc. to the values @var{value1}, @var{value2}, etc. If an unknown option field or an invalid option value is detected then the function terminates with an error.
%#
%# @deftypefnx {Function} {@var{[odestruct]} =} odeset (@var{oldstruct}, @var{"field1"}, @var{value1}, @dots{})
%# Overwrites all values of the structure @var{oldstruct} in the fields @var{field1}, @var{field2}, etc. with new values @var{value1}, @var{value2}, etc. If an unknown option field or an invalid option value is detected then the function terminates with an error.
%#
%# @deftypefnx {Function} {@var{[odestruct]} =} odeset (@var{oldstruct}, @var{newstruct})
%# Overwrites all values in the fields from the structure @var{oldstruct} with new values of the fields from the structure @var{newstruct}. Any empty matrix values from @var{newstruct} are not treated. If an unknown option field or an invalid option value is detected then the function terminates with an error.
%#
%# Run
%# @example
%# demo odeset
%# @end example
%# to see an example.
%# @end deftypefn
%#
%# @unnumberedsubsec Valid field names of the odepkg options structure
%# The odepkg options structure may contain the following fields and default values if calling @command{odeset}
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
%#
%# @seealso{odepkg}

%# Maintainer: Thomas Treichl
%# Created: 20060809
%# ChangeLog:

function [vret] = odeset (varargin)
  %# Create and check structure(s) for ode solvers (and others)
  vint.template = struct ...
    ('RelTol', 1e-3, ...
     'AbsTol', 1e-6, ...
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
     'MaxOrder', 5, ...
     'BDF', 'off');

  %# Check number and types of input arguments
  if (nargin == 0 && nargout == 1)
    vret = vint.template; vret = odepkg_structure_check (vret); return;
  elseif (nargin == 0)
    help ('odeset');
    vmsg = sprintf ('Number of input arguments must be greater than zero');
    error (vmsg);
  elseif (length (varargin) < 2)
    vmsg = sprintf ('odeset ("field1", "value1", ...)'); usage (vmsg);
  elseif (ischar (varargin{1}) == true && mod (length (varargin), 2) == 0)
    vint.nmb = 1; %# Check if the first input argument is a string (and all other)
    for vcntarg = 1:2:length (varargin)
      if (ischar (varargin{vcntarg}) == true)
        vint.arg{vint.nmb} = varargin{vcntarg};
        vint.val{vint.nmb} = varargin{vcntarg+1}; %# Second argument can be of any type
        vint.nmb = vint.nmb + 1;
      else, vmsg = sprintf ('Input argument number %d is no valid string', vcntarg); error (vmsg); end
    end
  elseif (isstruct (varargin{1}) == true && ischar (varargin{2}) == true && mod (length (varargin), 2) == 1)
    vint.nmb = 1; vint.oldstruct = varargin{1};
    for vcntarg = 2:2:length (varargin)
      if (ischar (varargin{vcntarg}) == true)
        vint.arg{vint.nmb} = varargin{vcntarg};
        vint.val{vint.nmb} = varargin{vcntarg+1};
        vint.nmb = vint.nmb + 1;
      else, vmsg = sprintf ('Input argument number %d is no valid string', vcntarg); error (vmsg); end
    end
  elseif (isstruct (varargin{1}) == true && isstruct (varargin{2}) == true && length (varargin) == 2)
    vint.oldstruct = varargin{1}; vint.newstruct = varargin{2};
  else
    vmsg = sprintf ('Check types and number of input arguments'); usage (vmsg);
  end

  %# Create the vret structure with all the fields necessary
  if (isfield (vint, 'oldstruct') == false)
    vret = vint.template;
    for vcntarg = 1:(vint.nmb-1), vret.(vint.arg{vcntarg}) = vint.val{vcntarg}; end
    vret = odepkg_structure_check (vret);
  elseif (isfield (vint, 'oldstruct') == true && isfield (vint, 'newstruct') == false)
    vret = vint.oldstruct;
    for vcntarg = 1:(vint.nmb-1), vret.(vint.arg{vcntarg}) = vint.val{vcntarg}; end
    vret = odepkg_structure_check (vret);
  elseif (isfield (vint, 'oldstruct') == true && isfield (vint, 'newstruct') == true)
    vret = vint.oldstruct;
    vint.newstruct = odepkg_structure_check (vint.newstruct);
    vint.fld = fieldnames (vint.newstruct);
    vint.len = length (vint.fld);
    for vcntfld = 1:vint.len
      if (isempty (vint.newstruct.(vint.fld{vcntfld})) == false)
        vret.(vint.fld{vcntfld}) = vint.newstruct.(vint.fld{vcntfld});
      end
    end
    vret = odepkg_structure_check (vret);
  end

%!test odeoptA = odeset ();
%!test odeoptB = odeset ('AbsTol', 1e-2, 'RelTol', 1e-1);
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