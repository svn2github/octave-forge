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
## @deftypefn {Function File} {@var{h} =} zenity_notification
## @deftypefnx {Function File} {@var{h} =} zenity_notification (@var{param1}, @var{value1}, @dots{})
## @deftypefnx {Function File} {@var{s} =} zenity_notification (@var{h}, @var{param1}, @var{value1}, @dots{})
## @deftypefnx {Function File} {@var{s} =} zenity_notification (@var{h}, "close")
## Displays an icon with a text in the notification area, and pop up messages
## using Zenity.
##
## The first and second forms of the @command{zenity_notification} function creates
## a new notification icon with whatever parameters are set, and return the
## handle @var{h} for later interaction with the notification icon or @code{-1}
## on error.
##
## The third form of the @command{zenity_notification} function changes the
## parameteres of the existing icon and/or displays popup messages given the
## handle @var{h}. Returns @code{0} on success and @code{-1} on error.
##
## The fourth form of the @command{zenity_notification} function closes the
## notification icon given the handle @var{h} followed by the string
## @code{close}. Returns @code{0} on success and @code{-1} on error.
##
## The following example, creates a notification info icon in the notification
## panel that shows the text @samp{working} when the mouse is over the
## icon. Then shows a pop up message saying @samp{step 1 started} followed by
## another saying @samp{error during step 1} all the while changing the icon
## from info to error. It then finnaly closes the icon, removing it from the
## notification panel. Trough all the example, the text stays @samp{working}.
##
## @example
## @group
## h = zenity_notification ("text", "working", "icon", "info")
## zenity_notification (h, "message", "step 1 started")
## zenity_notification (h, "message", "error during step 1", "icon", "error")
## zenity_notification (h, "close")
## @end group
## @end example
##
## All @var{parameters} are optional but if given, may require a corresponding
## @var{value}. All possible parameters are:
##
## @table @samp
## @item message
## Shows a pop up notification. Requires a string as value and Can only be used
## if the notification icon already exists. Newline characters are illegal
## characters and will be replaced by a space from the message.
##
## @item icon
## Sets or changes new or existent notification icons. Requires a string as
## value. It can either be the path for an image or one of the four default
## icons:
##
## @table @samp
## @item error
## @item info
## @item question
## @item warning (default)
## @end table
##
## Note: The icon will also appear next to any message.
##
## @item text
## Sets the notification text. Requires a string as value. This text appears
## when the mouse is placed over the icon. To show a popup notification, use
## @option{message}.
##
## @item timeout
## Sets the time in seconds after which the dialog is closed. Requires a scalar
## as value and can only be set when creating a new icon.
##
## @item visible
## Sets the visibility pf the icon in the notification area. Requires the string
## @code{on} or @code{off} as value and can only be used if the notification
## icon already exists.
## @end table
##
## @strong{Note:} ultimately, the availability of some parameters is dependent
## on the user's system preferences and zenity version.
##
## @seealso{zenity_progress, zenity_message}
## @end deftypefn

function sta = zenity_notification (varargin)

  ## Update figures so they are show before the dialog. To not be shown at this
  ## step, turn them off with 'figure(N, "visible", "off")
  ## This is similar to the functions input and pause
  drawnow;

  ## If no arguments, open a new notification
  if ( nargin == 0 )
    pipelining  = 0;
  ## If first argument is the fid for an already open notification, remove it
  ## from varargin (remove it != empty it) before feeding to zenity_options
  elseif (isscalar (varargin{1}) && isnumeric(varargin{1}) )
    pipelining  = 1;
    handle      = varargin{1};
    varargin(1) = [];
  elseif ( ischar(varargin{1}) && strcmpi(varargin{1}, "close") )
    error("Argument to close was given, but not the handle.")
  else
    pipelining  = 0;
  endif

  if (pipelining)
    ## If the first argument after the handle is the string 'close' say 'bye bye'
    if ( ischar(varargin{1}) && strcmpi(varargin{1}, "close") )
      if (nargin > 2)
        warning ("There's %g argument(s) after '%s' which will be ignored", (nargin-2), varargin{1})
      endif
      try
        sta = fclose (handle);
      catch
        sta = -1;
      end_try_catch
#      ## Commented because function should return the exit code, not give an error
#      if (sta != 0)
#        error ("Error when closing zenity notification");
#      endif
      return
    endif
    options = zenity_options ("piped notification", varargin);
    if ( isempty(options.icon))
      options.type = "--info";
    endif

    ## Must add the new line only if they exist or zenity will complain about
    ## not being able to parse some of the lines.
    ## Atention to whitespace after the command. Example:
    ## "   icon:question"  <-- no error, changes icon for question correctly
    ## "icon:question   "  <-- error, unable to fid the icon
    options.icon    = add_newline (options.icon);
    options.text    = add_newline (options.text);
    options.message = add_newline (options.message);
    options.visible = add_newline (options.visible);
    ## icon comes first so that if there's a new message it already comes
    ## with the new icon (the icon is also present on the messages, not only in
    ## the panel)
    pre_cmd = sprintf("%s", ...
                      options.icon, ... # This one (icon), must come first
                      options.text, ...
                      options.message, ...
                      options.visible);
    try
      ## just in case someone has been playing with the pipe, flush it before
      fflush (handle);
      sta = fputs(handle, pre_cmd);
      ## make sure there's no input buffered
      fflush (handle);
    catch
      sta = -1;
    end_try_catch
  else
    options = zenity_options ("new notification", varargin);
    pre_cmd = sprintf("%s ", ...
                      options.icon, ... 
                      options.text, ...
                      options.timeout)
    cmd     = sprintf("zenity --notification --listen %s", pre_cmd);
    try
      sta   = popen(cmd, "w");
    catch
      sta   = -1
    end_try_catch
  endif

endfunction

### Add new lines only if the option exist and replace other newlines that may be
function val = add_newline (val)
  if(!isempty(val))
    val = strrep (val, "\n", " ");
    val = sprintf("%s\n", val);
  endif
endfunction
