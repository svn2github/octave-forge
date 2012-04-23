## Copyright (C) 2006 Søren Hauberg <soren@hauberg.org>
## Copyright (C) 2010, 2012 Carnë Draug <carandraug+dev@gmail.com>
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
## @deftypefn {Function File} {[@var{entry}, @var{status}] =} zenity_entry (@var{text}, @var{parameter1}, @var{value1}, @dots{})
## Displays a text entry dialog using Zenity.
##
## The variable @var{text} sets the dialog text and is the only mandatory
## argument.
## 
## @var{entry} is a string with the text from the entry field and @var{status} 
## is a scalar with the exit code. @var{status} will have a value of @code{0} if
## @option{OK} is pressed; @code{1} if @option{Close} is pressed or the window
## functions are used to close it; or @code{5} if timeout has been reached.
##
## Note that unless @option{OK} is used to close the window, @var{entry} will be
## an empty string, despite whatever text was in the entry field.
##
## All @var{parameters} are optional, but if given, may require a corresponding
## @var{value}. All possible parameters are:
##
## @table @samp
## @item entry
## Sets the default text in the entry field. Requires a string as value.
##
## @item title
## Sets the title of the window. Requires a string as value.
##
## @item password
## Hides the text in the text entry field. No value is required.
##
## @item width
## Sets the width of the dialog window. Requires a scalar as value.
##
## @item height
## Sets the height of the dialog window. Requires a scalar as value.
##
## @item icon
## Sets the icon of the window. Requires a string as value with the file path to
## an image, or one of the four stock icons:
##
## @table @samp
## @item error
## @item info
## @item question
## @item warning
## @end table
##
## @item timeout
## Sets the time in seconds after which the dialog is closed. Requires a scalar
## as value.
## @end table
##
## @strong{Note:} ultimately, the availability of some parameters is dependent
## on the user's system preferences and zenity version.
##
## @seealso{input, menu, kbhit, zenity_message, zenity_file_selection}
## @end deftypefn

function [out, status] = zenity_entry(text, varargin)

  ## Update figures so they are show before the dialog. To not be shown at this
  ## step, turn them off with 'figure(N, "visible", "off")
  ## This is similar to the functions input and pause
  drawnow;

  if (nargin < 1)
    error ("'text' argument is not optional")
  elseif (!ischar(text))
    error ("'text' argument must be a string")
  endif
  text = sprintf("--text=\"%s\"", text);

  options = zenity_options ("entry", varargin);

  pre_cmd = sprintf("%s ", ...
                    text, ...
                    options.entry, ...
                    options.title, ...
                    options.password, ...
                    options.icon, ...
                    options.width, ...
                    options.height, ...
                    options.timeout);

  cmd              = sprintf("zenity --entry %s", pre_cmd);
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
  elseif (status == 1 || status == 5)
    out = "";
  else
    error("An unexpected error occurred with exit code '%i' and output '%s'",...
          status, output);
  endif

endfunction
