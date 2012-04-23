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
## @deftypefn {Function File} {[@var{date} @var{status}] =} zenity_calendar (@var{param1}, @var{value1}, @dots{})
## Opens a date selection dialog using Zenity.
##
## @var{date} is the first three members of the date vector of the selected date,
## representing the year, month and day respectively.
##
## @var{status} will be @code{0} if user pressed @option{OK} (and selected
## something), @code{1} if closed the window without selecting something, and
## @code{5} if timeout has been reached (and therefore no date was selected).
##
## If user does not select a date, all members of @var{date} will have a value
## of zero.
##
## All @var{parameters} are optional, but if given, may require a corresponding
## @var{value}. All possible parameters are:
##
## @table @samp
##
## @item text
## Sets the text of the dialog window. Requires a string as value.
##
## @item year
## Sets the default selected year. Requires a scalar as value.
##
## @item month
## Sets the default selected months. Requires a scalar as value.
##
## @item day
## Sets the default selected day. Requires a scalar as value.
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
##
## @item title
## Sets the title of the window. Requires a string as value.
##
## @item height
## Sets the height of the dialog window. Requires a scalar as value.
##
## @item width
## Sets the width of the dialog window. Requires a scalar as value.
## @end table
##
## @strong{Note:} ultimately, the availability of some parameters is dependent
## on the user's system preferences and zenity version.
##
## @seealso{datevec, datestr, date, clock, zenity_entry, zenity_message, zenity_text_info}
## @end deftypefn

## -*- texinfo -*-
## @deftypefn  {Function File} @var{d} = zenity_calendar(@var{title}, @var{day}, @var{month}, @var{year})
## Displays a date selection window.
## The variable @var{title} sets the title of the calendar.
## The optional arguments @var{day}, @var{month}, and @var{year} changes
## the standard selected date.
##
## @seealso{zenity_list, zenity_progress, zenity_entry, zenity_message,
## zenity_text_info, zenity_file_selection, zenity_notification}
## @end deftypefn

function [d, status] = zenity_calendar(varargin)

  ## Update figures so they are show before the dialog. To not be shown at this
  ## step, turn them off with 'figure(N, "visible", "off")
  ## This is similar to the functions input and pause
  drawnow;

  options = zenity_options ("calendar", varargin);

  pre_cmd = sprintf("%s ", ...
                    options.title, ...
                    options.width, ...
                    options.height, ...
                    options.timeout, ...
                    options.icon, ...
                    options.text, ...
                    options.day, ...
                    options.month, ...
                    options.year);

  ## Ideal would be to use date format %%4Y%%2m%%2d (format number 29 of datestr)
  ## but datevec doesn't support it yet (octave 3.2.4). In the mean time, uses
  ## format number 24
  cmd              = sprintf("zenity --calendar --date-format=%%4Y%%2m%%2d %s", pre_cmd);
  [status, output] = system(cmd);

  # Exit code -1 = An unexpected error has occurred
  # Exit code  0 = The user has pressed either OK or Close. 
  # Exit code  1 = The user has either pressed Cancel, or used the window
  # functions to close the dialog
  # Exit code  5 = The dialog has been closed because the timeout has been reached
  if (status == 0)
    if (output(end) == "\n")
        output = output(1:end-1);
    endif
    d = datevec(output, "yyyymmdd");
    d(4:6) = [];   # remove the hours, minutes and seconds field which are zeros
  elseif (status == 1 || status == 5)
    d (1:3) = 0;
  else
    error("An unexpected error occurred with exit code '%i' and output '%s'",...
          status, output);
  endif
endfunction
