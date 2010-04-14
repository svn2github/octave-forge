## Copyright (C) 2010 Carnë Draug
## 
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with this program; If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} @var{options} = _zenity_options (@var{dialog}, @var{param1}, @var{value1}, ...)
## This function is not intended for users but for the other functions of the
## zenity package. Returns the structure @var{options} that holds the processed
## @var{param} and @var{value} for the function of the zenity package
## @var{dialog}. @var{dialog} must be a string and one of the following:
##
## @table @samp
## @item calendar
## If used by zenity_calendar
## @item entry
## If used by zenity_entry
## @item file selection
## If used by zenity_file_selection
## @item list
## If used by zenity_list
## @item message
## If used by zenity_message
## @item notification
## If used by zenity_notification
## @item progress
## If used by zenity_progress
## @item scale
## If used by zenity_scale
## @item text info
## If used by zenity_text_info
## @end table
##
## @seealso{zenity_calendar, zenity_entry, zenity_file_selection, zenity_list,
## zenity_message, zenity_notification, zenity_progress, zenity_scale, 
## zenity_text_info}
## @end deftypefn

function op = _zenity_options_ (dialog, varargin)

  varargin = varargin{1};    # because other functions varargin is this varargin

  op.title = op.width = op.height = op.timeout = "";
  if ( !ischar(dialog) )
    error ("Type of dialog should be a string");
  elseif (strcmpi(dialog, "calendar"))
  elseif (strcmpi(dialog, "entry"))
    op.password = op.entry = "";
  elseif (strcmpi(dialog, "file selection"))
    op.directory = op.filename = op.multiple = op.save = "";
  elseif (strcmpi(dialog, "list"))
  elseif (strcmpi(dialog, "message"))
  elseif (strcmpi(dialog, "notification"))
  elseif (strcmpi(dialog, "progress"))
  elseif (strcmpi(dialog, "scale"))
  elseif (strcmpi(dialog, "text info"))
  else
    error ("The type of dialog '%s' is not supported", dialog);
  endif

  ## In case no options were set, returns the empty strings
  if (numel(varargin) == 1 && isempty(varargin{1}))
    return
  endif

  ## Here's the guidelines of the processing:
  ## - the parameteres and values are case insensitive
  ## - if a parameter is being defined twice, return an error
  ## - if a parameter requires a value but this is not given, return an error
  ## - check if the rigth type of value is given (char or scalar) and return an
  ## error if not

  narg = 1;
  while (narg <= numel (varargin))
    param = varargin{narg++};

    if (narg <= numel(varargin))  # Check if we are already in the last index
      value = varargin{narg};     # this is only for readability later on
    else                          # Writing varargin{narg} in all conditions
      clear value;                # is a pain and makes it even more confusing
    endif


    if ( !ischar(param) )
        error ("Parameter number %i is not a string", narg-1);

    ## Process ALL GENERAL OPTIONS first
    elseif (strcmpi(param,"title"))                   # General - title
      if ( !exist("value", "var") || !ischar(value) )
        error ("Parameter 'title' requires a string as value.");
      elseif (op.title)
        error ("Parameter 'title' defined twice, with values '%s' and '%s'", ...
                op.title(10:end-1), value);
      endif
      op.title   = sprintf("--title=\"%s\"", value);
      narg++;
    elseif (strcmpi(param,"width"))                   # General - width
      if ( !exist("value", "var") || !isscalar(value) )
        error ("Parameter 'width' requires a scalar as value.");
      elseif (op.width)
        error ("Parameter 'width' defined twice, with values '%s' and '%g'", ...
                op.width(9:end), value);
      endif
      op.width   = sprintf("--width=\"%s\"", num2str(value));
      narg++;
    elseif (strcmpi(param,"height"))                  # General - height
      if ( !exist("value", "var") || !isscalar(value) )
        error ("Parameter 'height' requires a scalar as value.");
      elseif (op.height)
        error ("Parameter 'height' defined twice, with values '%s' and '%g'", ...
                op.height(10:end), value);
      endif
      op.height  = sprintf("--height=\"%s\"", num2str(value));
      narg++;
    elseif (strcmpi(param,"timeout"))                 # General - timeout
      if ( !exist("value", "var") || !isscalar(value) )
        error ("Parameter 'timeout' requires a scalar as value.");
      elseif (op.timeout)
        error ("Parameter 'timeout' defined twice, with values '%s' and '%g'", ...
                op.timeout(11:end), value);
      endif
      op.timeout = sprintf("--timeout=\"%s\"", num2str(value));
      narg++;

    ## Process options for ZENITY_ENTRY
    elseif ( strcmpi(dialog, "entry") )
      if (strcmpi(param,"entry"))                     # Entry - entry
        if ( !exist("value", "var") || !ischar(value) )
          error ("Parameter 'entry' requires a string as value.");
        elseif (op.entry)
          error ("Parameter 'entry' defined twice, with values '%s' and '%s'", ...
                  op.entry(15:end-1), value);
        endif
        op.entry     = sprintf("--entry-text=\"%s\"", value);
        narg++;
      elseif (strcmpi(param,"password"))              # Entry - password
        if (op.password)
          error ("Parameter 'password' set twice.");
        endif
        op.password  = sprintf("--hide-text");
      else
        error ("Parameter '%s' is not supported", param);
      endif

    ## Process options for ZENITY_FILE_SELECTION
    elseif ( strcmpi(dialog, "file selection") )
      if (strcmpi(param,"directory"))                 # File selection - directory
        if (op.directory)
          error ("Parameter 'directory' set twice.");
        endif
        op.directory = sprintf("--directory");
      elseif (strcmpi(param,"filename"))              # File selection - filename
        if ( !exist("value", "var") || !ischar(value) )
          error ("Parameter 'filename' requires a string as value.");
        elseif (op.filename)
          error ("Parameter 'filename' defined twice, with values '%s' and '%s'", ...
                  op.filename(13:end-1), value);
        endif
        op.filename     = sprintf("--filename=\"%s\"", value);
        narg++;
      elseif (strcmpi(param,"multiple"))              # File selection - multiple
        if (op.multiple)
          error ("Parameter 'multiple' set twice");
        endif
        op.multiple  = sprintf("--multiple");
      elseif (strcmpi(param,"overwrite"))             # File selection - overwrite
        if (op.overwrite)
          error ("Parameter 'overwrite' set twice");
        endif
        op.overwrite  = sprintf("--confirm-overwrite");
      elseif (strcmpi(param,"save"))                  # File selection - save
        if (op.save)
          error ("Parameter 'save' set twice");
        endif
        op.save  = sprintf("--save");
      else
        error ("Parameter '%s' is not supported", param);
      endif


    else
      error ("Parameter '%s' is not supported", param);
    endif

  endwhile

endfunction
