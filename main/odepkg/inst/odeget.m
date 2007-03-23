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
%# @deftypefn  {Function} {@var{ret} =} odeget (@var{odestruct}, @var{name}, @var{[default]})
%# @deftypefnx {Function} {@var{ret} =} odeget (@var{odestruct}, @var{@{names@}}, @var{[@{defaults@}]})
%#
%# The first form returns the option value @var{ret} that is specified by the option name @var{name} from the odepkg option structure @var{odestruct}. Optionally the default value @var{default} is returned if this option was not manually set in @var{odestruct}. If an invalid input argument is detected then the function terminates with an error.
%#
%# The second form returns the option values as a cell array @var{ret} in that order that is specified by the cell array of option names @var{@{names@}} from the odepkg option structure @var{odestruct}. Optionally the default value from the cell array @var{@{defaults@}} is returned that depends on that option that was not manually set in @var{odestruct}. If an invalid input argument is detected then the function terminates with an error.
%#
%# Run
%# @example
%# demo odeget
%# @end example
%# to see an example.
%# @end deftypefn
%#
%# @seealso{odepkg}

%# Maintainer: Thomas Treichl
%# Created: 20060809
%# ChangeLog: 20061022, Thomas Treichl
%#    Changed help text. We cannot create a function of the form 
%#    odeget (@var{odestruct}, @var{name1}, @var{name2}) because we
%#    would get a mismatch with function form 1 like described above.


function [vret] = odeget (varargin)

  if (nargin == 0) %# Check number and types of input arguments
    vmsg = sprintf ('Number of input arguments must be greater than zero');
    help ('odeget'); error (vmsg);
  elseif (isstruct (varargin{1}) == true) %# Check first input argument
    vint.odestruct = odepkg_structure_check (varargin{1});
    vint.otemplate = odeset; %# Create default odepkg otpions structure
  else
    vmsg = sprintf ('First input argument must be a valid odepkg otpions structure');
    error (vmsg);
  end

  %# Check number and types of other input arguments
  if (length (varargin) < 2 || length (varargin) > 3)
    vmsg = sprintf ('odeget (odestruct, "option", default) or\n       odeget (odestruct, {"opt1", "opt2", ...}, {def1, def2, ...})');
    usage (vmsg);
  elseif (ischar (varargin{2}) == true && isempty (varargin{2}) == false)
    vint.arguments = {varargin{2}};
    vint.lengtharg = 1;
  elseif (iscellstr (varargin{2}) == true && isempty (varargin{2}) == false)
    vint.arguments = varargin{2};
    vint.lengtharg = length (vint.arguments);
  end

  if (nargin == 3) %# Check if third input argument is valid
    if (iscell (varargin{3}) == true)
      vint.defaults = varargin{3};
      vint.lengthdf = length (vint.defaults);
    else
      vint.defaults = {varargin{3}};
      vint.lengthdf = 1;
    end
    if (vint.lengtharg ~= vint.lengthdf)
      vmsg = sprintf ('If third argument is given then sizes of argument 2 and argument 3 must be the equal');
      error (vmsg);
    end
  end

  %# Run through number of input arguments given
  for vcntarg = 1:vint.lengtharg
    if (vint.odestruct.(vint.arguments{vcntarg}) == vint.otemplate.(vint.arguments{vcntarg}))
      if (nargin == 3), vint.returnval{vcntarg} = vint.defaults{vcntarg};
      else, vint.returnval{vcntarg} = vint.odestruct.(vint.arguments{vcntarg}); end
    else, vint.returnval{vcntarg} = vint.odestruct.(vint.arguments{vcntarg});
    end
  end

  %# Postprocessing, store results in the vret variable
  if (vint.lengtharg == 1), vret = vint.returnval{1};
  else, vret = vint.returnval; end

%!test odeget (odeset, 'RelTol');
%!test odeget (odeset, 'RelTol', 10);
%!test odeget (odeset, {'RelTol', 'AbsTol'});
%!test odeget (odeset, {'RelTol', 'AbsTol'}, {10 20});

%!demo
%!
%! A = odeset ('RelTol', 1e-1, 'AbsTol', 1e-2);
%! odeget (A, 'RelTol', [])
%! %----------------------------------------------------------------
%! % Returns the manually changed value RelTol of the odepkg options
%! % strutcure A. If RelTol wouldn't have been changed then [] would
%! % be returned.

%!demo
%!
%! A = odeset ('RelTol', 1e-1);
%! odeget (A, {'RelTol', 'AbsTol'}, {1e-2 1e-4})
%! %----------------------------------------------------------------
%! % Returns the manually changed value of RelTol and the value 1e-4
%! % for AbsTol of the odepkg options strutcure A.

%# Local Variables: ***
%# mode: octave ***
%# End: ***
