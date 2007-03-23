%# Copyright (C) 2007, Thomas Treichl <treichl@users.sourceforge.net>
%# OdePkg - Package for solving differential equations with octave
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
%# @deftypefn {Function} @var{scd} = odepkg_testsuite_calcscd (@var{solution, reference, abstol, reltol})
%#
%# Returns a normalized value for the minimum number of correct digits @var{scd} that is calculated from the solution at the end of an integration interval @var{solution} and a set of reference values @var{reference}. The input arguments @var{abstol} and @var{reltol} are unused but present because of compatibility with the function @command{odepkg_testsuite_calcmescd}.
%# 
%# Run
%# @example
%# demo odepkg_testsuite_calcscd
%# @end example
%# to see an example.
%# @end deftypefn
%#
%# @seealso{odepkg}

function vscd = odepkg_testsuite_calcscd (vsol, vref, vatol, vrtol)
  vsol = vsol(:); vref = vref(:);
  vrel = (vref - vsol) / vref;
  vscd = -log10 (norm (vrel, inf));

%!demo
%!
%! odepkg_testsuite_calcscd ([1, 2, 2.9], [1, 2, 3], NaN, NaN)
%! 
%! % ---------------------------------------------------------------------------
%! % Displays the value for the mimum number of correct digits in the
%! % vector sol = [1, 2, 2.9] compared to the reference vector ref = [1, 2, 3].
%!demo
%!
%! odepkg_testsuite_calcscd ([1 + 1e10, 2 + 1e10, 3 + 1e10], [1, 2, 3], NaN, NaN)
%! 
%! % ---------------------------------------------------------------------------
%! % Displays the value for the mimum number of correct digits in the
%! % vector sol = [1, 2, 2.9] compared to the reference vector ref = [1, 2, 3].

%!assert (odepkg_testsuite_calcscd ([1, 2, 3], [1, 2, 3], NaN, NaN), Inf);
%!assert (odepkg_testsuite_calcscd ([1, 2, 3], [1, 2.1, 3], 1, 1), 1.5, 0.2);
%!assert (odepkg_testsuite_calcscd ([1, 2, 3], [1+1e-6, 2, 3], 1, 1), 6.5, 0.2);

%# Local Variables: ***
%# mode: octave ***
%# End: ***
