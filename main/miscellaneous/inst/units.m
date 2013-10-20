## Copyright (C) 2005 Carl Osterwisch <osterwischc@asme.org>
## Copyright (C) 2013 Carnë Draug <carandraug@octave.org>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn  {Function File} {} units (@var{fromUnit}, @var{toUnit})
## @deftypefnx {Function File} {} units (@var{fromUnit}, @var{toUnit}, @var{x})
## Return the conversion factor from @var{fromUnit} to @var{toUnit} measurements.
##
## This is an octave interface to the @strong{GNU Units} program which comes
## with an annotated, extendable database defining over two thousand 
## measurement units.  See @code{man units} or 
## @url{http://www.gnu.org/software/units} for more information.
## If the optional argument @var{x} is supplied, return that argument
## multiplied by the conversion factor.  Nonlinear conversions
## such as Fahrenheit to Celsius are not currently supported.  For example, to 
## convert three values from miles per hour into meters per second:
##
## @example
## units ("mile/hr", "m/sec", [30, 55, 75])
## ans =
##
##   13.411  24.587  33.528
## @end example
## @end deftypefn

function y = units (fromUnit, toUnit, x = 1)

  if (nargin < 2 || nargin > 3)
    print_usage ();
  elseif (! ischar (fromUnit))
    error ("units: FromUNIT must be a string");
  elseif (! ischar (toUnit))
    error ("units: ToUNIT must be a string");
  elseif (! isnumeric (x))
    error ("units: X must be numeric");
  endif

  ## Does the version of units available have the compact option that
  ## will make things easier to parse?
  persistent compact = compact_option ();

  if (compact)
    cmd = sprintf ('units --compact --one-line -o "%%.16g" "%s" "%s"',
                   fromUnit, toUnit);
    [status, rawoutput] = system (cmd);
    if (status)
      error ("units: %s", rawoutput);
    endif
  else
    ## No compact or one-line option, we need to find the conversion factor
    ## from the text ourselves
    cmd = sprintf ('units -o "%%.16g" "%s" "%s"', fromUnit, toUnit);
    [status, rawoutput] = system (cmd);
    if (status)
      error ("units: %s", rawoutput);
    endif
    ini_factor = index (rawoutput, "*");
    end_factor = index (rawoutput, "\n") - 1;
    if (isempty (ini_factor) || ini_factor > end_factor)
        error ("units: unable to parse output from units:\n%s", rawoutput);
    endif
    rawoutput = rawoutput(ini_factor+1:end_factor);
  endif

  ## FIXME missing support for non-linear conversions. See for example:
  ##          units --compact --one-line tempC tempF
  c_factor = str2double (rawoutput);
  if (any (isnan (c_factor(:))))
    if (index (rawoutput, "="))
      ## If there's an equal on the output, it was probably a formula
      ## for a non-linear conversion such as "tempC(x) = x K + stdtemp"
      error ("units: no support for non-linear conversion of '%s' to '%s'",
             fromUnit, toUnit);
    else
      error ("units: unable to parse output `%s' from units.", rawoutput);
    endif
  endif

  y = x * c_factor;
endfunction

function compact = compact_option ()
  ## First check if units is installed and whether it's GNU or not. We can't
  ## use the status of "units --version" because it exits with 3 on success.
  [status, rawoutput] = system ("command -v units");
  if (status || isempty (rawoutput))
    ## For some reason, --version option would return an exit status
    error ("units: %s\nVerify that GNU units is installed in the current path.",
           rawoutput);
  endif
  [status, rawoutput] = system ("units --version");
  if (! strcmp (rawoutput(1:3), "GNU"))
    warning ("units: non-GNU version of units found. Results may be unexpected.");
  endif

  compact = true;
  ## Check if the compact and one-line options are available
  [status, rawoutput] = system ("units --compact --one-line --version");
  if (status)
    compact = false;
  endif
endfunction

%!demo
%! a.value = 100; a.unit = 'lb';
%! b.value =  50; b.unit = 'oz';
%! c.unit = 'kg';
%! c.value = units(a.unit, c.unit, a.value) + units(b.unit, c.unit, b.value)

%!assert (units ("in", "mm"), 25.4)
%!assert (units ("in", "mm", [5 7; 8 9]), 25.4 * [5 7; 8 9])
%!error <non-linear conversion> units ("tempC", "tempF")
