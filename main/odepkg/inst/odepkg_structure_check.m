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
%# @deftypefn {Function} odepkg_structure_check ()
%# Displays the help text of the function and terminates with an error.
%#
%# @deftypefnx {Function} {@var{[vodestruct]} =} odepkg_structure_check (@var{vodestruct})
%# Checks the field names and the field values of the odepkg option structure @var{vodestruct} and returns it. If an invalid field name or an invalid field value is detected then the function terminates with an error.
%#
%# Run
%# @example
%# demo odepkg_structure_check
%# @end example
%# to see an example.
%# @end deftypefn
%#
%# @seealso{odepkg}

%# Maintainer: Thomas Treichl
%# Created: 20060809
%# ChangeLog:

function [vret] = odepkg_structure_check (vret)
  if (nargin == 0) %# Check number of input arguments
    vmsg = sprintf ('Number of input arguments must be greater than zero');
    help ('odepkg_structure_check'); error (vmsg);
  else
    vint.fld = fieldnames (vret); vint.len = length (vint.fld);
  end

  for vcntarg = 1:vint.len %# Run through the number of structure field names
    %# vint.fld{vcntarg}
    %# vret.(vint.fld{vcntarg})

    switch (vint.fld{vcntarg})

      case 'RelTol'
        if (isreal (vret.(vint.fld{vcntarg})) == true && ...
            isscalar (vret.(vint.fld{vcntarg})) == true && ...
            vret.(vint.fld{vcntarg}) > 0)
        else
          vmsg = sprintf ('Unknown parameter "%s" or invalid parameter value "%s"', ...
            vint.fld{vcntarg}, char (vret.(vint.fld{vcntarg})));
          error (vmsg);
        end

      case 'AbsTol'
        if (isreal (vret.(vint.fld{vcntarg})) == true && ...
            (isvector (vret.(vint.fld{vcntarg})) == true || ...
             isscalar (vret.(vint.fld{vcntarg})) == true) && ...
            all (vret.(vint.fld{vcntarg}) > 0) == true) %# LabMat needs 'all'?!
        else
          vmsg = sprintf ('Unknown parameter "%s" or invalid parameter value "%s"', ...
            vint.fld{vcntarg}, char (vret.(vint.fld{vcntarg})));
          error (vmsg);
        end

      case 'NormControl'
        if (strcmp (vret.(vint.fld{vcntarg}), 'on') == true || ...
            strcmp (vret.(vint.fld{vcntarg}), 'off') == true)
        else
          vmsg = sprintf ('Unknown parameter "%s" or invalid parameter value "%s"', ...
            vint.fld{vcntarg}, char (vret.(vint.fld{vcntarg})));
          error (vmsg);
        end

      case 'NonNegative'
        if (isempty (vret.(vint.fld{vcntarg})) == true || ...
            isvector (vret.(vint.fld{vcntarg})) == true)
%#          for vcounter = 1:length (vret.(vint.fld{vcntarg}))
%#            if (isbool (int8 (vret.(vint.fld{vcntarg})(vcounter))) == false)
%#              vmsg = sprintf ('Unknown parameter "%s" or invalid parameter value "%s"', ...
%#                vint.fld{vcntarg}, char (vret.(vint.fld{vcntarg})));
%#              error (vmsg);
%#            end
%#          end
        else
          vmsg = sprintf ('Unknown parameter "%s" or invalid parameter value "%s"', ...
            vint.fld{vcntarg}, char (vret.(vint.fld{vcntarg})));
          error (vmsg);
        end

      case 'OutputFcn'
        if (isempty (vret.(vint.fld{vcntarg})) == true || ...
            isa (vret.(vint.fld{vcntarg}), 'function_handle') == true)
          %# strcmp ('function handle', strrep (class (vret.(vint.fld{vcntarg})), '_', ' ')) == true)
        else
          vmsg = sprintf ('Unknown parameter "%s" or invalid parameter value "%s"', ...
            vint.fld{vcntarg}, char (vret.(vint.fld{vcntarg})));
          error (vmsg);
        end

      case 'OutputSel'
        if (isempty  (vret.(vint.fld{vcntarg})) == true || ...
            isvector (vret.(vint.fld{vcntarg})) == true || ...
            isscalar (vret.(vint.fld{vcntarg})) == true)
        else
          vmsg = sprintf ('Unknown parameter "%s" or invalid parameter value "%s"', ...
            vint.fld{vcntarg}, char (vret.(vint.fld{vcntarg})));
          error (vmsg);
        end

      case 'Refine'
        if (mod (vret.(vint.fld{vcntarg}), 1) == 0 && ...
            vret.(vint.fld{vcntarg}) >= 0 && ...
            vret.(vint.fld{vcntarg}) <= 5)
        else
          vmsg = sprintf ('Unknown parameter "%s" or invalid parameter value "%s"', ...
            vint.fld{vcntarg}, char (vret.(vint.fld{vcntarg})));
          error (vmsg);
        end

      case 'Stats'
        if (strcmp (vret.(vint.fld{vcntarg}), 'on') == true || ...
            strcmp (vret.(vint.fld{vcntarg}), 'off') == true)
        else
          vmsg = sprintf ('Unknown parameter "%s" or invalid parameter value "%s"', ...
            vint.fld{vcntarg}, char (vret.(vint.fld{vcntarg})));
          error (vmsg);
        end

      case 'InitialStep'
        if (isempty (vret.(vint.fld{vcntarg})) == true || ...
            (isreal (vret.(vint.fld{vcntarg})) == true && ...
             vret.(vint.fld{vcntarg}) > 0) )
        else
          vmsg = sprintf ('Unknown parameter "%s" or invalid parameter value "%s"', ...
            vint.fld{vcntarg}, char (vret.(vint.fld{vcntarg})));
          error (vmsg);
        end

      case 'MaxStep'
        if (isempty (vret.(vint.fld{vcntarg})) == true || ...
            (isscalar (vret.(vint.fld{vcntarg})) == true && vret.(vint.fld{vcntarg}) > 0) )
        else
          vmsg = sprintf ('Unknown parameter "%s" or invalid parameter value "%s"', ...
            vint.fld{vcntarg}, char (vret.(vint.fld{vcntarg})));
          error (vmsg);
        end

      case 'Events'
        if (isempty (vret.(vint.fld{vcntarg})) == true || ...
            isa (vret.(vint.fld{vcntarg}), 'function_handle') == true)
          %# strcmp ('function handle', strrep (class (vret.(vint.fld{vcntarg})), '_', ' ')) == true)
        else
          vmsg = sprintf ('Unknown parameter "%s" or invalid parameter value "%s"', ...
            vint.fld{vcntarg}, char (vret.(vint.fld{vcntarg})));
          error (vmsg);
        end

      case 'Jacobian'
        if (isempty (vret.(vint.fld{vcntarg})) == true || ...
            ismatrix (vret.(vint.fld{vcntarg})) == true || ...
            strcmp ('function handle', strrep (class (vret.(vint.fld{vcntarg})), '_', ' ')) == true)
        else
          vmsg = sprintf ('Unknown parameter "%s" or invalid parameter value "%s"', ...
            vint.fld{vcntarg}, char (vret.(vint.fld{vcntarg})));
          error (vmsg);
        end

      case 'JPattern'
        if (isempty (vret.(vint.fld{vcntarg})) == true || ...
            issparse (vret.(vint.fld{vcntarg})) == true)
        else
          vmsg = sprintf ('Unknown parameter "%s" or invalid parameter value "%s"', ...
            vint.fld{vcntarg}, char (vret.(vint.fld{vcntarg})));
          error (vmsg);
        end

      case 'Vectorized'
        if (strcmp (vret.(vint.fld{vcntarg}), 'on') == true || ...
            strcmp (vret.(vint.fld{vcntarg}), 'off') == true)
        else
          vmsg = sprintf ('Unknown parameter "%s" or invalid parameter value "%s"', ...
            vint.fld{vcntarg}, char (vret.(vint.fld{vcntarg})));
          error (vmsg);
        end

      case 'Mass'
        if (isempty (vret.(vint.fld{vcntarg})) == true || ...
            ismatrix (vret.(vint.fld{vcntarg})) == true || ...
            strcmp ('function handle', strrep (class (vret.(vint.fld{vcntarg})), '_', ' ')) == true)
        else
          vmsg = sprintf ('Unknown parameter "%s" or invalid parameter value "%s"', ...
            vint.fld{vcntarg}, char (vret.(vint.fld{vcntarg})));
          error (vmsg);
        end

      case 'MStateDependence'
        if (strcmp (vret.(vint.fld{vcntarg}), 'none') == true || ...
            strcmp (vret.(vint.fld{vcntarg}), 'weak') == true || ...
            strcmp (vret.(vint.fld{vcntarg}), 'strong') == true)
        else
          vmsg = sprintf ('Unknown parameter "%s" or invalid parameter value "%s"', ...
            vint.fld{vcntarg}, char (vret.(vint.fld{vcntarg})));
          error (vmsg);
        end

      case 'MvPattern'
        if (isempty (vret.(vint.fld{vcntarg})) == true || ...
            issparse (vret.(vint.fld{vcntarg})) == true)
        else
          vmsg = sprintf ('Unknown parameter "%s" or invalid parameter value "%s"', ...
            vint.fld{vcntarg}, char (vret.(vint.fld{vcntarg})));
          error (vmsg);
        end

      case 'MassSingular'
        if (strcmp (vret.(vint.fld{vcntarg}), 'yes') == true || ...
            strcmp (vret.(vint.fld{vcntarg}), 'no') == true || ...
            strcmp (vret.(vint.fld{vcntarg}), 'maybe') == true)
        else
          vmsg = sprintf ('Unknown parameter "%s" or invalid parameter value "%s"', ...
            vint.fld{vcntarg}, char (vret.(vint.fld{vcntarg})));
          error (vmsg);
        end

      case 'InitialSlope'
        if (isempty (vret.(vint.fld{vcntarg})) == true || ...
            isvector (vret.(vint.fld{vcntarg})) == true)
        else
          vmsg = sprintf ('Unknown parameter "%s" or invalid parameter value "%s"', ...
            vint.fld{vcntarg}, char (vret.(vint.fld{vcntarg})));
          error (vmsg);
        end

      case 'MaxOrder'
        if (mod (vret.(vint.fld{vcntarg}), 1) == 0 && ...
            vret.(vint.fld{vcntarg}) > 0 && vret.(vint.fld{vcntarg}) < 6)
        else
          vmsg = sprintf ('Unknown parameter "%s" or invalid parameter value "%s"', ...
            vint.fld{vcntarg}, char (vret.(vint.fld{vcntarg})));
          error (vmsg);
        end

      case 'BDF'
        if (strcmp (vret.(vint.fld{vcntarg}), 'on') == true || ...
            strcmp (vret.(vint.fld{vcntarg}), 'off') == true)
        else
          vmsg = sprintf ('Unknown parameter "%s" or invalid parameter value "%s"', ...
            vint.fld{vcntarg}, char (vret.(vint.fld{vcntarg})));
          error (vmsg);
        end

      otherwise
        vmsg = sprintf ('Unknown parameter "%s" or invalid parameter value "%s"', ...
          vint.fld{vcntarg}, char (vret.(vint.fld{vcntarg})));
        error (vmsg);
    end %# switch
  end %# for

  %# Check sizes of the parameters RelTol and AbsTol
%#  if (any (size (vret.AbsTol) ~= size (vret.RelTol)) == true)
%#    vmsg = sprintf ('Sizes of parameters "RelTol" and "AbsTol" must be the same');
%#    error (vmsg);
%#  end 

  %# The following line can be uncommented for a even higher level error detection
  %# if (vint.len ~= 21)
  %#   vmsg = sprintf ('Number of fields in structure must match 21');
  %#   error (vmsg);
  %# end

%!test odepkg_structure_check (odeset);
%!test A = odeset (); odepkg_structure_check (A);

%!demo
%!
%! odepkg_structure_check (odeset);
%!
%! %---------------------------------------------------------------
%! % Returns the checked odepkg options structure created by
%! % odeset.
%!demo
%!
%! A = odeset (); odepkg_structure_check (A);
%!
%! %---------------------------------------------------------------
%! % Create the odepkg options structure A with odeset and check
%! % it with odepkg_structure_check.

%# Local Variables: ***
%# mode: octave ***
%# End: ***