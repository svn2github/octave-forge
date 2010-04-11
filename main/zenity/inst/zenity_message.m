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
## @deftypefn  {Function File} @var{status} = zenity_message(@var{text}, @var{parameter1}, @var{value1}, ...)
## Displays different types of graphical message dialogs using Zenity.
##
## Returns 0 if `OK' is pressed; 1 if `Close' is pressed or the window
## functions are used to close it; or 5 if timeout has been reached.
##
## The variable @var{text} sets the message of the dialog and is the only
## mandatory argument. All @var{parameter1} are optional, but if given, may require
## a corresponding @var{value1}. All possible parameters are:
##
## @table @samp
## @item type
## Sets the type of the message dialog. If not defined, defaults to `info'. Value
## must be one of the following:
##
## @table @samp
## @item error
## Creates an error dialog.
## @item info
## Creates an information dialog (default).
## @item question
## Creates a question dialog.
## @item warning
## Creates a warning dialog.
## @end table
##
## @item title
## Sets the title of the window. Requires a string as value.
## @item no-wrap
## Disables text wrapping. No value is required.
## @item width
## Sets the width of the dialog window. Requires a scalar as value.
## @item height
## Sets the height of the dialog window. Requires a scalar as value.
## @item timeout
## Sets the time in seconds after which the dialog is closed. Requires a scalar
## as value.
## @end table
##
## @seealso{zenity_text_info, warning, error, disp, puts, printf, zenity_entry,
## zenity_notification}
## @end deftypefn

function status = zenity_message(text, varargin)

  if (nargin < 1)
    error ("'text' argument is not optional")
  elseif (!ischar(text))
    error ("'text' argument must be a string")
  endif
  text = ["--text=\"", text, "\""];

  ## Process of all options and values
  type = "--info";  # Info is the default type
  title = wrap = width = height = timeout = "";

  narg = 1;
  while (narg <= numel (varargin))
    option = varargin{narg++};
    if ( !ischar(option) )
        error ("Option/parameter number %i is not a string", narg)

    elseif (strcmpi(option,"type"))
      if ( !ischar(varargin{narg}) )
        error ("Parameter 'type' requires a string as value.");
      endif
      value     = varargin{narg++};
      if (strcmpi(value,"error"))
        type    = "--error";
      elseif (strcmpi(value,"info"))
        type    = "--info";
      elseif (strcmpi(value,"question"))
        type    = "--question";
      elseif (strcmpi(value,"warning"))
        type    = "--warning";
      else
        error ("Illegal value '%s' for parameter 'type'", value);
      endif

    elseif (strcmpi(option,"title"))
      if ( !ischar(varargin{narg}) )
        error ("Parameter 'title' requires a string as value.");
      endif
      title     = ["--title=\"", varargin{narg++}, "\""];

    elseif (strcmpi(option,"no-wrap"))
      wrap      = "--no-wrap";

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

  cmd = sprintf('zenity %s %s %s %s %s %s %s', ...
                type, text, title, timeout, wrap, width, height);
  [status, output] = system(cmd);

# Exit code -1 = An unexpected error has occurred
# Exit code  0 = The user has pressed either OK or Close. 
# Exit code  1 = The user has either pressed Cancel, or used the window
# functions to close the dialog
# Exit code  5 = The dialog has been closed because the timeout has been reached
  if (status == 0 || 1 || 5)
    return

  else
    error("An unexpected error occurred with exit code '%i' and output '%s'",...
          status, output);
  endif

endfunction
