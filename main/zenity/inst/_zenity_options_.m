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

function options = _zenity_options_ (dialog, unprocessed)

  options.title = options.width = options.height = options.timeout = "";
  if ( !ischar(dialog) )
    error ("Type of dialog should be a string");
  elseif (strcmpi(dialog, "calendar"))
    dialog = "calendar";
  elseif (strcmpi(dialog, "entry"))
    dialog = "entry";
    options.password = options.entry = "";
  elseif (strcmpi(dialog, "file selection"))
    dialog = "file selection";
  elseif (strcmpi(dialog, "list"))
    dialog = "list";
  elseif (strcmpi(dialog, "message"))
    dialog = "message";
  elseif (strcmpi(dialog, "notification"))
    dialog = "notification";
  elseif (strcmpi(dialog, "progress"))
    dialog = "progress";
  elseif (strcmpi(dialog, "scale"))
    dialog = "scale";
  elseif (strcmpi(dialog, "text info"))
    dialog = "text info";
  else
    error ("The type of dialog '%s' is not supported", dialog);
  endif

  ## In case no options were set, returns the empty strings
  if (numel(unprocessed) == 1 && isempty(unprocessed{1}))
    return
  endif

  ## Here's the guidelines of the processing:
  ## - the parameteres and values are case insensitive
  ## - if a parameter is being defined twice, return an error
  ## - if a parameter requires a value but this is not given, return an error
  ## - check if the rigth type of value is given (char or scalar) and return an
  ## error if not

  narg = 1;
  while (narg <= numel (unprocessed))
    param = unprocessed{narg++};

    if (narg <= numel(unprocessed)) # Check if we are already in the last index
      value = unprocessed{narg};    # this is only for readability later on
    else
      clear value;
    endif

    if ( !ischar(param) )
        error ("Parameter number %i is not a string", narg-1);

    ## Process all general options first
    elseif (strcmpi(param,"title"))
      if ( !exist("value", "var") || !ischar(value) )
        error ("Parameter 'title' requires a string as value.");
      elseif (options.title)
        error ("Parameter 'title' defined twice, with values '%s' and '%s'", ...
                title(10,end-1), value);
      endif
      options.title   = ["--title=\"", value, "\""];
      narg++;

    elseif (strcmpi(param,"width"))
      if ( !exist("value", "var") || !isscalar(value) )
        error ("Parameter 'width' requires a scalar as value.");
      elseif (options.width)
        error ("Parameter 'width' defined twice, with values '%s' and '%g'", ...
                width(9,end), value);
      endif
      options.width    = ["--width=", num2str(value)];
      narg++;

    elseif (strcmpi(param,"height"))
      if ( !exist("value", "var") || !isscalar(value) )
        error ("Parameter 'height' requires a scalar as value.");
      elseif (options.height)
        error ("Parameter 'height' defined twice, with values '%s' and '%g'", ...
                height(10,end), value);
      endif
      options.height   = ["--height=", num2str(value)];
      narg++;

    elseif (strcmpi(param,"timeout"))
      if ( !exist("value", "var") || !isscalar(value) )
        error ("Parameter 'timeout' requires a scalar as value.");
      elseif (options.timeout)
        error ("Parameter 'timeout' defined twice, with values '%s' and '%g'", ...
                timeout(11,end), value);
      endif
      options.timeout = ["--timeout=", num2str(value)];
      narg++;

    ## Process options for zenity_entry
    elseif (dialog == "entry")
      if (strcmpi(param,"entry"))
        if ( !exist("value", "var") || !ischar(value) )
          error ("Parameter 'entry' requires a string as value.");
        endif
        options.entry     = ["--entry-text=\"", value, "\""];
        narg++;

      elseif (strcmpi(param,"password"))
        options.password  = "--hide-text";
      else
        error ("Parameter '%s' is not supported", param);
      endif

    else
      error ("Parameter '%s' is not supported", param);
    endif

  endwhile

endfunction
