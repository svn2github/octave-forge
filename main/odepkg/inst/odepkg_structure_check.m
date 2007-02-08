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
%# @deftypefn {Function} {@var{odestruct} =} odepkg_structure_check (@var{odestruct})
%# Checks the field names and the field values of the odepkg option structure @var{odestruct} and returns it again if it is valid. If an invalid field name or an invalid field value is detected then the function terminates with an error.
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
    vmsg = sprintf ('Number of input arguments must be greater than zero\n');
    help ('odepkg_structure_check'); error (vmsg);
  else
    vint.fld = fieldnames (vret); vint.len = length (vint.fld);
  end

  for vcntarg = 1:vint.len %# Run through the number of structure field names

    switch (vint.fld{vcntarg})

      case 'RelTol'
        if (isreal (vret.(vint.fld{vcntarg})) == true && ...
            (isvector (vret.(vint.fld{vcntarg})) == true || ...
             isscalar (vret.(vint.fld{vcntarg})) == true) && ...
            all (vret.(vint.fld{vcntarg}) > 0) == true) %# LabMat needs 'all'?!
        else
          vmsg = sprintf ('Unknown parameter "%s" or invalid parameter value "%s"\n', ...
            vint.fld{vcntarg}, char (vret.(vint.fld{vcntarg})));
          error (vmsg);
        end

      case 'AbsTol'
        if (isreal (vret.(vint.fld{vcntarg})) == true && ...
            (isvector (vret.(vint.fld{vcntarg})) == true || ...
             isscalar (vret.(vint.fld{vcntarg})) == true) && ...
            all (vret.(vint.fld{vcntarg}) > 0) == true) %# LabMat needs 'all'?!
        else
          vmsg = sprintf ('Unknown parameter "%s" or invalid parameter value "%s"\n', ...
            vint.fld{vcntarg}, char (vret.(vint.fld{vcntarg})));
          error (vmsg);
        end

      case 'NormControl'
        if (strcmp (vret.(vint.fld{vcntarg}), 'on') == true || ...
            strcmp (vret.(vint.fld{vcntarg}), 'off') == true)
        else
          vmsg = sprintf ('Unknown parameter "%s" or invalid parameter value "%s"\n', ...
            vint.fld{vcntarg}, char (vret.(vint.fld{vcntarg})));
          error (vmsg);
        end

      case 'NonNegative'
        if (isempty (vret.(vint.fld{vcntarg})) == true || ...
            isvector (vret.(vint.fld{vcntarg})) == true)
        else
          vmsg = sprintf ('Unknown parameter "%s" or invalid parameter value "%s"\n', ...
            vint.fld{vcntarg}, char (vret.(vint.fld{vcntarg})));
          error (vmsg);
        end

      case 'OutputFcn'
        if (isempty (vret.(vint.fld{vcntarg})) == true || ...
            isa (vret.(vint.fld{vcntarg}), 'function_handle') == true)
        else
          vmsg = sprintf ('Unknown parameter "%s" or invalid parameter value "%s"\n', ...
            vint.fld{vcntarg}, char (vret.(vint.fld{vcntarg})));
          error (vmsg);
        end

      case 'OutputSel'
        if (isempty  (vret.(vint.fld{vcntarg})) == true || ...
            isvector (vret.(vint.fld{vcntarg})) == true || ...
            isscalar (vret.(vint.fld{vcntarg})) == true)
        else
          vmsg = sprintf ('Unknown parameter "%s" or invalid parameter value "%s"\n', ...
            vint.fld{vcntarg}, char (vret.(vint.fld{vcntarg})));
          error (vmsg);
        end

      case 'Refine'
        if (mod (vret.(vint.fld{vcntarg}), 1) == 0 && ...
            vret.(vint.fld{vcntarg}) >= 0 && ...
            vret.(vint.fld{vcntarg}) <= 5)
        else
          vmsg = sprintf ('Unknown parameter "%s" or invalid parameter value "%s"\n', ...
            vint.fld{vcntarg}, char (vret.(vint.fld{vcntarg})));
          error (vmsg);
        end

      case 'Stats'
        if (strcmp (vret.(vint.fld{vcntarg}), 'on') == true || ...
            strcmp (vret.(vint.fld{vcntarg}), 'off') == true)
        else
          vmsg = sprintf ('Unknown parameter "%s" or invalid parameter value "%s"\n', ...
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
          vmsg = sprintf ('Unknown parameter "%s" or invalid parameter value "%s"\n', ...
            vint.fld{vcntarg}, char (vret.(vint.fld{vcntarg})));
          error (vmsg);
        end

      case 'Events'
        if (isempty (vret.(vint.fld{vcntarg})) == true || ...
            isa (vret.(vint.fld{vcntarg}), 'function_handle') == true)
        else
          vmsg = sprintf ('Unknown parameter "%s" or invalid parameter value "%s"\n', ...
            vint.fld{vcntarg}, char (vret.(vint.fld{vcntarg})));
          error (vmsg);
        end

      case 'Jacobian'
        if (isempty (vret.(vint.fld{vcntarg})) == true || ...
            ismatrix (vret.(vint.fld{vcntarg})) == true || ...
            isa (vret.(vint.fld{vcntarg}), 'function_handle') == true)
        else
          vmsg = sprintf ('Unknown parameter "%s" or invalid parameter value "%s"\n', ...
            vint.fld{vcntarg}, char (vret.(vint.fld{vcntarg})));
          error (vmsg);
        end

      case 'JPattern'
        if (isempty (vret.(vint.fld{vcntarg})) == true || ...
            issparse (vret.(vint.fld{vcntarg})) == true)
        else
          vmsg = sprintf ('Unknown parameter "%s" or invalid parameter value "%s"\n', ...
            vint.fld{vcntarg}, char (vret.(vint.fld{vcntarg})));
          error (vmsg);
        end

      case 'Vectorized'
        if (strcmp (vret.(vint.fld{vcntarg}), 'on') == true || ...
            strcmp (vret.(vint.fld{vcntarg}), 'off') == true)
        else
          vmsg = sprintf ('Unknown parameter "%s" or invalid parameter value "%s"\n', ...
            vint.fld{vcntarg}, char (vret.(vint.fld{vcntarg})));
          error (vmsg);
        end

      case 'Mass'
        if (isempty (vret.(vint.fld{vcntarg})) == true || ...
            ismatrix (vret.(vint.fld{vcntarg})) == true || ...
            isa (vret.(vint.fld{vcntarg}), 'function_handle') == true)
        else
          vmsg = sprintf ('Unknown parameter "%s" or invalid parameter value "%s"\n', ...
            vint.fld{vcntarg}, char (vret.(vint.fld{vcntarg})));
          error (vmsg);
        end

      case 'MStateDependence'
        if (strcmp (vret.(vint.fld{vcntarg}), 'none') == true || ...
            strcmp (vret.(vint.fld{vcntarg}), 'weak') == true || ...
            strcmp (vret.(vint.fld{vcntarg}), 'strong') == true)
        else
          vmsg = sprintf ('Unknown parameter "%s" or invalid parameter value "%s"\n', ...
            vint.fld{vcntarg}, char (vret.(vint.fld{vcntarg})));
          error (vmsg);
        end

      case 'MvPattern'
        if (isempty (vret.(vint.fld{vcntarg})) == true || ...
            issparse (vret.(vint.fld{vcntarg})) == true)
        else
          vmsg = sprintf ('Unknown parameter "%s" or invalid parameter value "%s"\n', ...
            vint.fld{vcntarg}, char (vret.(vint.fld{vcntarg})));
          error (vmsg);
        end

      case 'MassSingular'
        if (strcmp (vret.(vint.fld{vcntarg}), 'yes') == true || ...
            strcmp (vret.(vint.fld{vcntarg}), 'no') == true || ...
            strcmp (vret.(vint.fld{vcntarg}), 'maybe') == true)
        else
          vmsg = sprintf ('Unknown parameter "%s" or invalid parameter value "%s"\n', ...
            vint.fld{vcntarg}, char (vret.(vint.fld{vcntarg})));
          error (vmsg);
        end

      case 'InitialSlope'
        if (isempty (vret.(vint.fld{vcntarg})) == true || ...
            isvector (vret.(vint.fld{vcntarg})) == true)
        else
          vmsg = sprintf ('Unknown parameter "%s" or invalid parameter value "%s"\n', ...
            vint.fld{vcntarg}, char (vret.(vint.fld{vcntarg})));
          error (vmsg);
        end

      case 'MaxOrder'
        if (mod (vret.(vint.fld{vcntarg}), 1) == 0 && ...
            vret.(vint.fld{vcntarg}) > 0 && vret.(vint.fld{vcntarg}) < 6)
        else
          vmsg = sprintf ('Unknown parameter "%s" or invalid parameter value "%s"\n', ...
            vint.fld{vcntarg}, char (vret.(vint.fld{vcntarg})));
          error (vmsg);
        end

      case 'BDF'
        if (strcmp (vret.(vint.fld{vcntarg}), 'on') == true || ...
            strcmp (vret.(vint.fld{vcntarg}), 'off') == true)
        else
          vmsg = sprintf ('Unknown parameter "%s" or invalid parameter value "%s"\n', ...
            vint.fld{vcntarg}, char (vret.(vint.fld{vcntarg})));
          error (vmsg);
        end

      otherwise
        vmsg = sprintf ('Unknown parameter "%s" or invalid parameter value "%s"\n', ...
          vint.fld{vcntarg}, char (vret.(vint.fld{vcntarg})));
        error (vmsg);
    end %# switch
  end %# for

  %# The following line can be uncommented for a even higher level error detection
  %# if (vint.len ~= 21)
  %#   vmsg = sprintf ('Number of fields in structure must match 21');
  %#   error (vmsg);
  %# end

%!test  A = odeset ('RelTol', 1e-4);         %# odeset calls odepkg_structure_check
%!test  A = odeset ('RelTol', [1e-4, 1e-3]); %# after the options have been set
%!error A = odeset ('RelTol', []);
%!error A = odeset ('RelTol', '1e-4');
%!test  A = odeset ('AbsTol', 1e-4);
%!test  A = odeset ('AbsTol', [1e-4, 1e-3]);
%!error A = odeset ('AbsTol', []);
%!error A = odeset ('AbsTol', '1e-4');
%!test  A = odeset ('NormControl', 'on');
%!test  A = odeset ('NormControl', 'off');
%!error A = odeset ('NormControl', []);
%!error A = odeset ('NormControl', '12');
%!test  A = odeset ('NonNegative', 1);
%!test  A = odeset ('NonNegative', [1, 2, 3]);
%!error A = odeset ('NonNegative', []);
%!error A = odeset ('NonNegative', '12');
%!test  A = odeset ('OutputFcn', @odeprint);
%!test  A = odeset ('OutputFcn', @odeplot);
%!error A = odeset ('OutputFcn', []);
%!error A = odeset ('OutputFcn', 'odeprint');
%!test  A = odeset ('OutputSel', 1);
%!test  A = odeset ('OutputSel', [1, 2, 3]);
%!error A = odeset ('OutputSel', []);
%!error A = odeset ('OutputSel', '12');
%!test  A = odeset ('Refine', 3);
%!error A = odeset ('Refine', [1, 2, 3]);
%!error A = odeset ('Refine', []);
%!error A = odeset ('Refine', 6);
%!test  A = odeset ('Stats', 'on');
%!test  A = odeset ('Stats', 'off');
%!error A = odeset ('Stats', []);
%!error A = odeset ('Stats', '12');
%!test  A = odeset ('InitialStep', 3);
%!error A = odeset ('InitialStep', [1, 2, 3]);
%!error A = odeset ('InitialStep', []);
%!error A = odeset ('InitialStep', 6);
%!test  A = odeset ('MaxStep', 3);
%!error A = odeset ('MaxStep', [1, 2, 3]);
%!error A = odeset ('MaxStep', []);
%!error A = odeset ('MaxStep', 6);
%!test  A = odeset ('Events', @demo);
%!error A = odeset ('Events', 'off');
%!error A = odeset ('Events', []);
%!error A = odeset ('Events', '12');
%!test  A = odeset ('Jacobian', @demo);
%!test  A = odeset ('Jacobian', [1, 2; 3, 4]);
%!error A = odeset ('Jacobian', []);
%!error A = odeset ('Jacobian', '12');
%#!test  A = odeset ('JPattern', );
%#!test  A = odeset ('JPattern', );
%#!error A = odeset ('JPattern', );
%#!error A = odeset ('JPattern', );
%!test  A = odeset ('Vectorized', 'on');
%!test  A = odeset ('Vectorized', 'off');
%!error A = odeset ('Vectorized', []);
%!error A = odeset ('Vectorized', '12');
%!test  A = odeset ('Mass', @demo);
%!test  A = odeset ('Mass', [1, 2; 3, 4]);
%!error A = odeset ('Mass', []);
%!error A = odeset ('Mass', '12');
%!test  A = odeset ('MStateDependence', 'none');
%!test  A = odeset ('MStateDependence', 'weak');
%!test  A = odeset ('MStateDependence', 'strong');
%!error A = odeset ('MStateDependence', [1, 2; 3, 4]);
%!error A = odeset ('MStateDependence', []);
%!error A = odeset ('MStateDependence', '12');
%#!test  A = odeset ('JPattern', );
%#!test  A = odeset ('JPattern', );
%#!error A = odeset ('JPattern', );
%#!error A = odeset ('JPattern', );
%!test  A = odeset ('MassSingular', 'yes');
%!test  A = odeset ('MassSingular', 'no');
%!test  A = odeset ('MassSingular', 'maybe');
%!error A = odeset ('MassSingular', [1, 2; 3, 4]);
%!error A = odeset ('MassSingular', []);
%!error A = odeset ('MassSingular', '12');
%!test  A = odeset ('InitialSlope', [1, 2, 3]);
%!error A = odeset ('InitialSlope', 1);
%!error A = odeset ('InitialSlope', []);
%!error A = odeset ('InitialSlope', '12');
%!test  A = odeset ('MaxOrder', 3);
%!error A = odeset ('MaxOrder', 3.5);
%!error A = odeset ('MaxOrder', [1, 2; 3, 4]);
%!error A = odeset ('MaxOrder', []);
%!test  A = odeset ('BDF', 'on');
%!test  A = odeset ('BDF', 'off');
%!error A = odeset ('BDF', [1, 2; 3, 4]);
%!error A = odeset ('BDF', []);

%!demo
%!
%! odepkg_structure_check (odeset);
%!
%! %----------------------------------------------------------------
%! % Returns the checked odepkg options structure created by odeset.
%!demo
%!
%! A = odeset (); odepkg_structure_check (A);
%!
%! %----------------------------------------------------------------
%! % Create the odepkg options structure A with odeset and check
%! % it with odepkg_structure_check.

%# Local Variables: ***
%# mode: octave ***
%# End: ***