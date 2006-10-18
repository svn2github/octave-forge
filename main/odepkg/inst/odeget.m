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
%# @deftypefn {Function} {@var{[vret]} =} odeget (@var{vodestruct}, @var{vname}, @var{[vdefault]})
%# @deftypefnx {Function} {@var{[vret]} =} odeget (@var{vodestruct}, @var{@{vnames@}}, @var{[@{vdefaults@}]})
%#
%# Returns the option value @var{vret} that is specified by the option name 
%# @var{vname} from the odepkg option structure @var{vodestruct}. Optionally 
%# the default value @var{vdefault} is returned if no option was set in 
%# @var{vodestruct} manually by the user. If an invalid input argument is 
%# detected then the function terminates with an error.
%#
%# The second form, returns the option values as a cell array @var{vret} that
%# is specified by the cell array of option names @var{@{vnames@}} from the 
%# odepkg option structure @var{vodestruct}. Optionally the default value of
%# @var{[@{vdefaults@}]} is returned if no option was set in @var{vodestruct}
%# manually by the user. If an invalid input argument is detected then the
%# function terminates with an error.
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
%# ChangeLog:

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
