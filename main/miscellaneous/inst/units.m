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

  persistent available  = check_units ();
  persistent compact    = has_compact_option ();
  persistent template   = template_cmd (compact);

  cmd = sprintf ('%s "%s" "%s"', template, fromUnit, toUnit);
  [status, rawoutput] = system (cmd);
  if (status)
    error ("units: %s", rawoutput);
  endif

  if (! compact)
    ## No compact or one-line option, we need to find the conversion factor
    ## from the text ourselves
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
    if (index (rawoutput, "=") || index (rawoutput, "+") ||
        index (rawoutput, "-") || index (rawoutput, "*") ||
        index (rawoutput, "/"))
      ## If there's a mathematical operator in the output, it may be a formula
      ## for a non-linear conversion such as "tempC(x) = x K + stdtemp"
      ## We don't check for the equal only because it won't appear in
      ## version 1.00 which although it was released before 1996, it's still
      ## what's distributed with Mac OSX (see bug #38270)
      error ("units: no support for non-linear conversion of '%s' to '%s'",
             fromUnit, toUnit);
    else
      error ("units: unable to parse output `%s' from units.", rawoutput);
    endif
  endif

  y = x * c_factor;
endfunction

function fpath = check_units ()
  ## See bug #38270 about why we're checking this way.
  fpath = file_in_path (getenv ("PATH"), sprintf ("units%s", octave_config_info ("EXEEXT")));
  if (isempty (fpath))
    error ("units: %s\nVerify that GNU units is installed in the current path.",
           rawoutput);
  endif
endfunction

function compact = has_compact_option ()
  compact = true;
  ## We must give some units to convert because the only thing that would
  ## make it not do any work (--version) actually exits with exit value 3
  [status, rawoutput] = system ('units --compact --one-line "in" "cm"');
  if (status)
    compact = false;
  endif
endfunction

function template = template_cmd (compact)
  ## do we have the format option?
  format = true;
  [status, rawoutput] = system ('units --output-format "%%.16g" "in" "cm"');
  if (status)
    format = false;
  endif

  template = "units ";
  if (format)
    template = [template '--output-format "%.16g" '];
  endif
  if (compact)
    template = [template '--compact --one-line '];
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
