## Copyright (C) 2006 Søren Hauberg
## Copyright (C) 2010 Carnë Draug
## 
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
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
## @deftypefn  {Function File} status = zenity_notification(@var{param1}, @var{value1}, ...)
## Displays an icon with a text in the notification area using Zenity.
##
## @var{status} is the exit code of the function and has a value of @code{0} if
## it is pressed; @code{1} if @option{Close} is pressed or the window
## functions are used to close it; or @code{5} if timeout has been reached.
##
## All variables are optional but if given, may require a corresponding
## @var{value}. All possible parameters are:
##
## @table @samp
## @item icon
## Sets the icon of notification. Requires a string as value. It can either be
## the path for an image or one of the four default icons:
##
## @table @samp
## @item error
## @item info
## @item question
## @item warning (default)
## @end table
## @item text
## Sets the notification text. Requires a string as value.
## @item timeout
## Sets the time in seconds after which the dialog is closed. Requires a scalar
## as value.
## @end table
##
## @seealso{zenity_progress, zenity_message}
## @end deftypefn

function [output status] = zenity_notification (varargin)

  options = _zenity_options_ ("notification", varargin);

  pre_cmd = sprintf("%s ", ...
                    options.icon, options.text, options.timeout);

  cmd              = sprintf("zenity --notification --listen %s", pre_cmd);
  [status, output] = system(cmd);
  ## Exit code -1 = An unexpected error has occurred
  ## Exit code  0 = The user has pressed either OK or Close. 
  ## Exit code  1 = The user has either pressed Cancel, or used the window
  ## functions to close the dialog
  ## Exit code  5 = The dialog has been closed because the timeout has been reached
  if (status == 0 || status == 1 || status == 5)
    return
  else
    error("An unexpected error occurred with exit code '%i' and output '%s'",...
          status, output);
  endif
endfunction
