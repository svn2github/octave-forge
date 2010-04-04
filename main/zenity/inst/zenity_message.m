## Copyright (C) 2006  Søren Hauberg
## Copyright (C) 2010  Carnë Draug
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
## @deftypefn  {Function File} @var{status} = zenity_message(@var{text}, @var{type}, @var{option1}, ...)
## Displays a graphical message dialog using Zenity.
##
## Returns 0 if `OK' is pressed; 1 if `close' is pressed or the window
## functions are used to close it; or 5 if timeout has been reached.
##
## The variable @var{text} sets the message of the dialog. The @var{type} of
## message can be:
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
## The @var{option} string arguments can be:
## @table @samp
## @item title=@var{title}
## Sets the title of the message window. If no title is specified, defaults to
## the type of message.
## @item no-wrap
## Do not enable text wrapping.
## @item width=@var{width}
## Sets the message window width.
## @item height=@var{height}
## Sets the message window heigth.
## @item timeout=@var{time}
## Specifies @var{time} in seconds after which the dialog is closed.
## @end table
##
## @seealso{zenity_calendar, zenity_list, zenity_progress, zenity_entry,
## zenity_text_info, zenity_file_selection, zenity_notification}
## @end deftypefn

function status=zenity_message(text, type, varargin)

  title = timeout = wrap = width = height= "";
  if (nargin == 0 || !ischar(text))
    print_usage();
    return
  elseif (nargin == 1)
    type = "info";
  elseif (nargin >= 2)
    if (strcmpi(type,"error"))
      type = "error";
    elseif (strcmpi(type,"info"))
      type = "info";
    elseif (strcmpi(type,"question"))
      type = "question";
    elseif (strcmpi(type,"warning"))
      type = "warning";
    else
      error("zenity_message: unsupported message type: %s", type);
    endif
  endif

  if (nargin > 2)
    for i = 1:length(varargin)
      option  = varargin{i};
      isc     = ischar(option);
      if (isc && regexpi(option, "^title=") )
        title = ["--title=", option(7:end)];
      elseif (isc && strcmpi(option, "no-wrap") )
        wrap = "--no-wrap";
      elseif (isc && regexpi(option, "^width=") )
        width = ["--width=", option(7:end)];
      elseif (isc && regexpi(option, "^height=") )
        height = ["--height=", option(8:end)];
      elseif (isc && regexpi(option, "^timeout=") )
        timeout = ["--timeout=", option(9:end)];
      else
        error ("zenity_message: unsupported option");
      endif
    endfor
  endif

  cmd = sprintf('zenity --%s --text="%s" %s %s %s %s %s', ...
                  type, text, title, timeout, wrap, width, height)
  [status, output] = system(cmd);

# Exit code -1 = An unexpected error has occurred
# Exit code  0 = The user has pressed either OK or Close. 
# Exit code  1 = The user has either pressed Cancel, or used the window
# functions to close the dialog
# Exit code  5 = The dialog has been closed because the timeout has been reached
  if (status == 0 || 1 || 5)
    return
  elseif (status == -1)
    error("An unexpected error occurred: %s", output);
  else
    error("zenity_message: %s", output);
  endif
endfunction
