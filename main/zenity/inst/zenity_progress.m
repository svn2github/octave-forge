## Copyright (C) 2006 Søren Hauberg <soren@hauberg.org>
## Copyright (C) 2010 Carnë Draug <carandraug+dev@gmail.com>
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
## @deftypefn {Function File} {@var{h} =} zenity_progress
## @deftypefnx {Function File} {@var{h} =} zenity_progress (@var{param1}, @var{value1}, @dots{})
## @deftypefnx {Function File} {@var{s} =} zenity_progress (@var{h}, @var{param1}, @var{value1}, @dots{})
## @deftypefnx {Function File} {@var{s} =} zenity_progress (@var{h}, "close")
## Displays a progress bar dialog using Zenity.
##
## The first and second forms of the @command{zenity_progress} function creates
## a new progress bar dialog with whatever parameters are set, and return the
## handle @var{h} for later interaction with the progress bar or @code{-1}
## on error. All @var{parameters} for this form are optional but if given, may
## require a corresponding @var{value}. All possibilities are:
##
## @table @samp
## @item percentage
## Sets the initial value of the progress bar. Requires a scalar between @code{0} and
## @code{100} as value.
##
## @item text
## Sets the text of the dialog window. Requires a string as value.
##
## @item auto close
## When the bar reachs @code{100}, automatically closes the dialog window. Requires no value.
##
## @item auto kill
## If the @option{cancel} button is pressed, it will kill the parent process
## (@abbr{i.e.} the program that is calling the function). Requires no value.
##
## @item hide cancel
## Hides the @option{cancel} button from the dialog window (the user can still
## close the window with its functions). Requires no value.
##
## @item pulsate
## The progress bar will be pulsing instead of showing a bar increasing with
## percentage. Setting the percentage, will have no effect. Requires no value.
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
##
## @end table
##
## The third form of the @command{zenity_progress} function changes the
## parameteres of the existing progress bar given the handle @var{h}. The only
## parameters allowed are @option{percentage} and @option{text}. Returns @code{0} on
## success and @code{-1} on error.
##
## The fourth form of the @command{zenity_progress} function finishes the progress
## bar, given the handle @var{h} followed by the string @code{close}. This will
## move the progress bar to the end and wait for the user to press
## @option{OK}. To avoid this behaviour, @option{auto close} can be set when
## creating the progress bar. Returns @code{0} on success and @code{-1} on error.
##
## @strong{Note:} ultimately, the availability of some parameters is dependent
## on the user's system preferences and zenity version.
##
## @seealso{zenity_notification, zenity_message}
## @end deftypefn

function sta = zenity_progress(varargin)

  ## If no arguments, open a new progress bar
  if ( nargin == 0 )
    pipelining  = 0;
  ## If first argument is the fid for an already open progress, remove it
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
        sta = pclose(handle);
      catch
        sta = -1;
      end_try_catch
      return
    endif
    options = zenity_options ("piped progress", varargin);
    ## Must add the new line only if they exist or zenity will complain about
    ## not being able to parse some of the lines.
    ## Atention to whitespace. First character must be digit or #
    ## " #test text"  <-- no error, but does nothing
    ## "#test text"   <-- changes text for 'test text
    ## "# test text"  <-- exactly the same as above
    options.text    = add_newline (options.text);
    options.percent = add_newline (options.percent);

    pre_cmd = sprintf("%s", ...
                      options.text, ...
                      options.percent);
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
    options = zenity_options ("new progress", varargin);
    pre_cmd = sprintf("%s ", ...
                      options.title, ...
                      options.width, ...
                      options.height,...
                      options.timeout, ...
                      options.icon, ...
                      options.text, ...
                      options.percent, ...
                      options.auto_close, ...
                      options.pulsate, ...
                      options.auto_kill,...
                      options.hide_cancel);
    cmd     = sprintf("zenity --progress %s", pre_cmd);
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
