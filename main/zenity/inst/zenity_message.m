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
## @deftypefn {Function File} {@var{status} =} zenity_message (@var{text}, @var{parameter1}, @var{value1}, @dots{})
## Displays different types of graphical message dialogs using Zenity.
##
## Returns @code{0} if @option{OK} is pressed; @code{1} if @option{Close} is
## pressed or the window functions are used to close it; or @code{5} if timeout
## has been reached.
##
## The variable @var{text} sets the message of the dialog and is the only
## mandatory argument. All @var{parameters} are optional, but if given, may require
## a corresponding @var{value}. All possible parameters are:
##
## @table @samp
## @item type
## Sets the type of the message dialog. If not defined, defaults to `info'. Value
## must be one of the following:
##
## @table @samp
## @item error
## Creates an error dialog with an @option{OK} button.
## @item info
## Creates an information dialog with an @option{OK} button (default).
## @item question
## Creates a question dialog with an @option{OK} and a @option{cancel} button.
## @item warning
## Creates a warning dialog with an @option{OK} button.
## @end table
##
## @item icon
## Sets the icon of the window. Requires a string as value with the file path to
## an image, or one of the four stock icons (default is the same as the type of
## of message):
##
## @table @samp
## @item error
## @item info
## @item question
## @item warning
## @end table
##
## @item ok
## Sets the the text to show on the @option{OK} button if type of message is set
## to @option{question}. Requires a string as value.
##
## @item cancel
## Sets the the text to show on the @option{cancel} button if type of message is
## set to @option{question}. Requires a string as value.
##
## @item title
## Sets the title of the window. Requires a string as value.
##
## @item no_wrap
## Disables text wrapping. No value is required.
##
## @item width
## Sets the width of the dialog window. Requires a scalar as value.
##
## @item height
## Sets the height of the dialog window. Requires a scalar as value.
##
## @item timeout
## Sets the time in seconds after which the dialog is closed. Requires a scalar
## as value.
## @end table
##
## @strong{Note:} ultimately, the availability of some parameters is dependent
## on the user's system preferences and zenity version.
##
## @seealso{zenity_text_info, warning, error, disp, puts, printf, zenity_entry,
## zenity_notification}
## @end deftypefn

function status = zenity_message(text, varargin)

  ## Update figures so they are show before the dialog. To not be shown at this
  ## step, turn them off with 'figure(N, "visible", "off")
  ## This is similar to the functions input and pause
  drawnow;

  if (nargin < 1)
    error ("'text' argument is not optional")
  elseif (!ischar(text))
    error ("'text' argument must be a string")
  endif
  text = sprintf('--text="%s"', text);

  options = zenity_options ("message", varargin);

  if ( isempty(options.type))
    options.type = "--info";
  endif

  ## Sanity checks
  if ( !strcmpi(options.type, "--question") && (options.ok || options.cancel))
    error("Paremeters 'ok button' and 'cancel button' can only bet set in 'question' messages")
  endif

  pre_cmd = sprintf("%s ", ...
                    options.type, ...
                    text, ...
                    options.no_wrap, ...
                    options.title, ...
                    options.icon, ...
                    options.width, ...
                    options.height, ...
                    options.timeout, ...
                    options.ok, ...
                    options.cancel);

  cmd              = sprintf("zenity %s", pre_cmd);
  [status, output] = system(cmd);

  # Exit code -1 = An unexpected error has occurred
  # Exit code  0 = The user has pressed either OK or Close. 
  # Exit code  1 = The user has either pressed Cancel, or used the window
  # functions to close the dialog
  # Exit code  5 = The dialog has been closed because the timeout has been reached
  if (status == 0 || status == 1 || status == 5)
    return
  else
    error("An unexpected error occurred with exit code '%i' and output '%s'",...
          status, output);
  endif

endfunction
