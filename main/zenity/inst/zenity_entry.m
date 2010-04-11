## Copyright (C) 2006 Søren Hauberg
## Copyright (C) 2010 Carnë Draug
## 
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with this program; If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn  {Function File} @var{s} = zenity_entry(@var{text}, @var{parameter1}, @var{value1}, ...)
## Displays a text entry dialog. The variable @var{text} sets the dialog text
## and is the only mandatory argument.
##
## All @var{parameter1} are optional, but if given, may require a corresponding
## @var{value1}. All possible parameters are:
## @table @samp
## @item entry
## Sets the default text in the entry field. Requires a string as value.
## @item title
## Sets the title of the window. Requires a string as value.
## @item password
## Hides the text in the text entry fiel. No value is required.
## @item width
## Sets the width of the dialog window. Requires a scalar as value.
## @item height
## Sets the height of the dialog window. Requires a scalar as value.
## @item timeout
## Sets the time in seconds after which the dialog is closed. Requires a scalar
## as value.
## @end table
##
## @seealso{input, menu, kbhit, zenity_message, zenity_file_selection}
## @end deftypefn

function out = zenity_entry(text, varargin)

  if (nargin < 1)
    error ("'text' argument is not optional")
  elseif (!ischar(text))
    error ("'text' argument must be a string")
  endif
  text = ["--text=\"", text, "\""];

  ## Process of all options and values
  entry = title = password = width = height = timeout = "";

  narg = 1;
  while (narg <= numel (varargin))
    option = varargin{narg++};
    if ( !ischar(option) )
        error ("Option/parameter number %i is not a string", narg)

    elseif (strcmpi(option,"entry"))
      if ( !ischar(varargin{narg}) )
        error ("Parameter 'entry' requires a string as value.");
      endif
      entry     = ["--entry-text=\"", varargin{narg++}, "\""];

    elseif (strcmpi(option,"title"))
      if ( !ischar(varargin{narg}) )
        error ("Parameter 'title' requires a string as value.");
      endif
      title     = ["--title=\"", varargin{narg++}, "\""];

    elseif (strcmpi(option,"password"))
      password  = "--hide-text";

    elseif (strcmpi(option,"width"))
      if ( !isscalar(varargin{narg}) )
        error ("Parameter 'width' requires a scalar as value.");
      endif
      value     = num2str (varargin{narg++});
      width     = ["--width=", value];

    elseif (strcmpi(option,"height"))
      if ( !isscalar(varargin{narg}) )
        error ("Parameter 'height' requires a scalar as value.");
      endif
      value     = num2str (varargin{narg++});
      height    = ["--height=", value];

    elseif (strcmpi(option,"timeout"))
      if ( !isscalar(varargin{narg}) )
        error ("Parameter 'timeout' requires a scalar as value.");
      endif
      value     = num2str (varargin{narg++});
      timeout   = ["--timeout=", value];

    else
      error ("Parameter '%s' not supported", option)
    endif

  endwhile

  cmd = sprintf("zenity --entry %s %s %s %s %s %s %s %s", ...
                text, entry, title, password, width, height, timeout);
  [status, output] = system(cmd);

  ## Exit code -1 = An unexpected error has occurred
  ## Exit code  0 = The user has pressed either OK or Close. 
  ## Exit code  1 = The user has either pressed Cancel, or used the window
  ## functions to close the dialog
  ## Exit code  5 = The dialog has been closed because the timeout has been reached
  if (status == 0)
    if (output(end) == "\n")
      output = output(1:end-1);
    endif
    out = output;

  elseif (status == 1)
    warning("No value entered. Returning empty string.");
    out = "";

  elseif (status == 5)
    warning("Timeout reached. Returning empty string.");
    out = "";

  else
    error("An unexpected error occurred with exit code '%i' and output '%s'",...
          status, output);

  endif

endfunction
