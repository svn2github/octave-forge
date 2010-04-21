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
## @var{dialog}, or the defaults when they are not defined.. @var{dialog} must
## be a string and one of the following:
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

  ## A present from zenity_list. Take it out of varargin before before other stuff
  if ( strcmpi(dialog, "list") )
   list.col       = varargin{end};
    varargin(end) = [];             # By using (end), it actually pulls the value out instead of leaving it empty
  endif

  op.title = op.width = op.height = op.timeout = op.icon = "";
  if ( !ischar(dialog) )
    error ("Type of dialog should be a string");
  elseif (strcmpi(dialog, "calendar"))
  elseif (strcmpi(dialog, "entry"))
    op.password = op.entry = "";
  elseif (strcmpi(dialog, "file selection"))
    op.directory = op.filename = op.filter = op.multiple = op.save = "";
  elseif (strcmpi(dialog, "list"))
    op.separator = op.text  = op.hide  = op.print_col = op.print_col_one = "";
    op.multiple  = op.radio = op.check = op.editable  = op.hide_one      = "";
  elseif (strcmpi(dialog, "message"))
    op.type = op.wrap = "";
  elseif (strcmpi(dialog, "notification"))
    op.text = "";
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
      value = "";                 # is a pain and makes it even more confusing
    endif


    if ( !ischar(param) )
        error ("All parameters must be strings.");

    ## Process ALL GENERAL OPTIONS first
    elseif (strcmpi(param,"title"))                   # General - title
      narg            = sanity_checks ("char", param, value, op.title, narg);
      op.title        = sprintf("--title=\"%s\"", value);
    elseif (strcmpi(param,"width"))                   # General - width
      narg            = sanity_checks ("scalar", param, value, op.width, narg);
      op.width        = sprintf("--width=\"%s\"", num2str(value));
    elseif (strcmpi(param,"height"))                  # General - height
      narg            = sanity_checks ("scalar", param, value, op.height, narg);
      op.height       = sprintf("--height=\"%s\"", num2str(value));
    elseif (strcmpi(param,"timeout"))                 # General - timeout
      narg            = sanity_checks ("scalar", param, value, op.timeout, narg);
      op.timeout      = sprintf("--timeout=\"%s\"", num2str(value));
    elseif (strcmpi(param,"icon"))                    # General - icon
      narg            = sanity_checks ("char", param, value, op.icon, narg);
      if (strcmpi(value, "error"))
        op.icon       = "--window-icon=\"error\"";
      elseif (strcmpi(value, "info"))
        op.icon       = "--window-icon=\"info\"";
      elseif (strcmpi(value, "question"))
        op.icon       = "--window-icon=\"question\"";
      elseif (strcmpi(value, "warning"))
        op.icon       = "--window-icon=\"warning\"";
      else
        op.icon       = sprintf("--window-icon=\"%s\"", value);
      endif

    ## Process options for ZENITY_ENTRY
    elseif ( strcmpi(dialog, "entry") )
      if (strcmpi(param,"entry"))                     # Entry - entry text
        narg            = sanity_checks ("char", param, value, op.entry, narg);
        op.entry        = sprintf("--entry-text=\"%s\"", value);
      elseif (strcmpi(param,"password"))              # Entry - password
        narg            = sanity_checks ("indie", param, value, op.password, narg);
        op.password     = "--hide-text";
      else
        error ("Parameter '%s' is not supported for '%s' dialog.", param, dialog);
      endif

    ## Process options for ZENITY_FILE_SELECTION
    elseif ( strcmpi(dialog, "file selection") )
      if (strcmpi(param,"directory"))                 # File selection - directory
        narg            = sanity_checks ("indie", param, value, op.directory, narg);
        op.directory    = "--directory";
      elseif (strcmpi(param,"filename"))              # File selection - filename
        narg            = sanity_checks ("char", param, value, op.filename, narg);
        op.filename     = sprintf("--filename=\"%s\"", value);
      elseif (strcmpi(param,"filter"))                # File selection - file filter
        narg            = sanity_checks ("multiple-char", param, value, op.directory, narg);
        op.filter       = sprintf("%s --file-filter=\"%s\"", op.filter, value);
      elseif (strcmpi(param,"multiple"))              # File selection - multiple
        narg            = sanity_checks ("indie", param, value, op.multiple, narg);
        op.multiple     = "--multiple";
      elseif (strcmpi(param,"overwrite"))             # File selection - overwrite
        narg            = sanity_checks ("indie", param, value, op.overwrite, narg);
        op.overwrite    = "--confirm-overwrite";
      elseif (strcmpi(param,"save"))                  # File selection - save
        narg            = sanity_checks ("indie", param, value, op.save, narg);
        op.save         = "--save";
      else
        error ("Parameter '%s' is not supported for '%s' dialog.", param, dialog);
      endif

    ## Process options for ZENITY_MESSAGE
    elseif ( strcmpi(dialog, "message") )
      if (strcmpi(param,"type"))                      # Message - type
        narg            = sanity_checks ("valueless", param, value, op.type, narg);
        if (strcmpi(value,"error"))
          op.type       = "--error";
        elseif (strcmpi(value,"info"))
          op.type       = "--info";
        elseif (strcmpi(value,"question"))
          op.type       = "--question";
        elseif (strcmpi(value,"warning"))
          op.type       = "--warning";
        else
          error ("Non supported type of message dialog '%s'", value);
        endif
      elseif (strcmpi(param,"wrap"))                  # Message - wrap
        narg            = sanity_checks ("indie", param, value, op.wrap, narg);
        op.wrap         = "--no-wrap";
      else
        error ("Parameter '%s' is not supported for '%s' dialog.", param, dialog);
      endif

    ## Process options for ZENITY_NOTIFICATION
    elseif ( strcmpi(dialog, "notification") )
      if (strcmpi(param,"text"))                      # Notification - text
        narg            = sanity_checks ("char", param, value, op.text, narg);
        op.text         = sprintf("--text=\"%s\"", value);
      else
        error ("Parameter '%s' is not supported for '%s' dialog.", param, dialog);
      endif

    ## Process options for ZENITY_LIST
    ## TODO should an option to change the separator be set for list?
    elseif ( strcmpi(dialog, "list") )
      if (strcmpi(param,"text"))                      # List - text
        narg            = sanity_checks ("char", param, value, op.text, narg);
        op.text         = sprintf("--text=\"%s\"", value);
      elseif (strcmpi(param,"editable"))              # List - editable
        narg            = sanity_checks ("indie", param, value, op.editable, narg);
        op.editable     = "--editable";
      elseif (strcmpi(param,"multiple"))              # List - multiple
        narg            = sanity_checks ("indie", param, value, op.multiple, narg);
        op.multiple     = "--multiple";
      elseif (strcmpi(param,"radiolist"))              # List - radiolist
        narg            = sanity_checks ("indie", param, value, op.radio, narg);
        op.radio        = "--radiolist";
      elseif (strcmpi(param,"checklist"))              # List - checklist
        narg            = sanity_checks ("indie", param, value, op.check, narg);
        op.check        = "--checklist";
      elseif (strcmpi(param,"hide column"))            # List - hide column
        narg            = sanity_checks ("num", param, value, op.hide, narg);
        tmp             = "";
        for i = 1:numel(value)
          if (value(i) == 1)
            op.hide_one = 1;                          # Needed for sanity checks
          elseif (value(i) < 1)
            error ("Value %g is not accepted for parameter '%s', must be larger than zero.", value(i), param)
          elseif (value(i) > list.col)
            error ("Value %g for the parameter '%s' is larger than the number of columns.", value(i), param)
          endif
          str = num2str(value(i));
          tmp = sprintf("%s%s,", tmp, str);
        endfor
        op.hide         = sprintf("--hide-column=%s", tmp);
      elseif (strcmpi(param,"print column"))          # List - print column
        narg            = sanity_checks ("num", param, value, op.print_col, narg);
        tmp             = "";
        for i = 1:numel(value)
          if (value(i) == 1)
            op.print_col_one = 1;                     # Needed for sanity checks
          elseif (value(i) == 0)
            if (numel(value) > 1)
              error ("Value 0 (all) found as value for parameter '%s'. If desired must be set alone as scalar.", param);
            endif
            tmp = "all";
            break
          elseif (value(i) < 0)
            error ("Value %g is not accepted for parameter '%s', all must be non-negative.", value(i), param)
          elseif (value(i) > list.col)
            error ("Value %g for the parameter '%s' is larger than the number of columns.", value(i), param)
          endif
          str = num2str(value(i));
          tmp = sprintf("%s%s,", tmp, str);
        endfor
        op.hide         = sprintf("--print-column=%s", tmp);
      else
        error ("Parameter '%s' is not supported for '%s' dialog.", param, dialog);
      endif

    else
      error ("Parameter '%s' is not supported.", param);
    endif

  endwhile

  ## Set the DEFAULTS
  if (strcmpi(dialog,"message"))                      # Defaults for message
    if ( isempty(op.type) )
      op.type = "--info";
    endif
  elseif (strcmpi(dialog,"notification"))             # Defaults for notification
    if ( isempty(op.icon) )
      op.icon = "--window-icon=\"warning\"";
    endif
  endif

endfunction

################################################################################
function narg = sanity_checks (type, param, value, previous, narg)
  if (strcmpi(type,"char"))                             # Value must be string
    if (previous)
      idx = strfind(previous, "=");
      error ("Parameter '%s' set twice, with values '%s' and '%s'.", ...
                  param, previous(idx(1)+2:end-1), value);
    elseif ( isempty(value) || !ischar(value) )
      error ("Parameter '%s' requires a string as value.", param);
    endif
    narg++;

  elseif (strcmpi(type,"scalar"))                       # Value must be scalar
    if (previous)
      idx = strfind(previous, "=");
      error ("Parameter '%s' set twice, with values '%s' and '%g'.", ...
                  param, previous(idx(1)+2:end-1), value);
    elseif ( isempty(value) || !isscalar(value) )
      error ("Parameter '%s' requires a scalar as value.", param);
    endif
    narg++;

  elseif (strcmpi(type,"indie"))                        # Independent parameter
    if (previous)
      error ("Parameter '%s' set twice.", param);
    endif

  elseif (strcmpi(type,"valueless"))                    # Valueless parameter
    if (previous)
      error ("Parameter '%s' set twice, with values '%s' and '%s'.", ...
                  param, previous(3:end), value);
    elseif ( isempty(value) || !ischar(value) )
      error ("Parameter '%s' requires a string as value.", param);
    endif
    narg++;

  elseif (strcmpi(type,"multiple-char"))                # Value can be set more than once
    if ( isempty(value) || !ischar(value) )
      error ("Parameter '%s' requires a string as value.", param);
    endif
    narg++;

  elseif (strcmpi(type,"num"))                # Value can be set more than once
    if ( isempty(value) || !isnumeric(value) )
      error ("Parameter '%s' requires a numeric as value.", param);
    endif
    narg++;


  else
    error ("Non supported type for sanity_checks '%s'.", type)
  endif

endfunction
