## Copyright (C) 2006 Muthiah Annamalai
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
## @deftypefn {Function File} @var{h} = zenity_scale
## @deftypefnx {Function File} @var{h} = zenity_scale (@var{param1}, @var{value1}, ...)
## @deftypefnx {Function File} @var{s} = zenity_scale (@var{h})
## @deftypefnx {Function File} @var{s} = zenity_scale (@var{h}, "close")
## Displays a selection scale (range widget) window using zenity.
## Allows the user to choose a parameter within the set ranges, and sets
## default value, and step sizes.
## The variable @var{title} sets the title of the window.
## The variable @var{text} sets the label of the range widget.
## The other arguments @var{value}, @var{minval},@var{maxval},
## @var{step}, @var{print_partial}, and @var{hideval}.
## The range widget can be used to select anywhere from @var{minval} to
## @var{maxval} values in increments of @var{step}. The variable
## @var{print_partial} and @var{hideval} are boolean flags to partial
## and hidden views of the value on the range widget.
## The first 3 parameters are essential, while the remaining parameters
## @var{minval}, @var{maxval},@var{step},@var{print_partial},@var{hideval} if
## not specified take on default values of 0,100,1,false,false
## respectively.
## @seealso{zenity_list, zenity_progress, zenity_entry, zenity_message,
## zenity_text_info, zenity_file_selection, zenity_notification}
## @end deftypefn

function [val, status] = zenity_scale(varargin)

  ## If no arguments are given, open a new scale dialog
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
    options = zenity_options ("piped scale", varargin);
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
    options = zenity_options ("new scale", varargin);
    pre_cmd = sprintf("%s ", ...
                      options.title, ...
                      options.width, ...
                      options.height,...
                      options.timeout, ...
                      options.icon, ...
                      options.text, ...
                      options.ini, ...
                      options.end, ...
                      options.start, ...
                      options.step, ...
                      options.hide);
    if (options.partial)
      cmd     = sprintf("zenity --progress --print-partial %s", pre_cmd);
    else
      cmd     = sprintf("zenity --progress %s", pre_cmd);
    endif
    try
      sta   = popen(cmd, "r");
    catch
      sta   = -1
    end_try_catch
  endif














#  ppartial="";
#  hvalue="";

#  if(length(title)==0), title="Adjust the scale value"; endif
#  if(print_partial), ppartial="--print-partial"; endif
#  if(hideval), hvalue="--hide-value"; endif
#  
#  cmd = sprintf(['zenity --scale --title="%s" --text="%s" ', ...
#                 '--value=%d --min-value=%d --max-value=%d --step=%d ',...
#		 '%s %s '],title, text, value, minval,maxval,step,ppartial,hvalue);
#  [status, output] = system(cmd);
#  if (status == 0)
#    output = str2num(output);
#  elseif (status == 1)
#    output = value; ##default when user kills it.
#  else
#    error("zenity_scale: %s", output); ##kill -9 
#  endif


#  ## In the future, this can be changed to return a file-handle if --print-partial
#  ## is selected. If so, a pipe can be open with
#  ## fid  = fopen("zenity --scale --print-partial", "r")
#  ## read = fgets(fid)
#  ##
#  ## However, fgets can't read the value currently selected, only the one right
#  ## before the last selection



endfunction
