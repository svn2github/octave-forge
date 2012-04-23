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
## @deftypefn {Function File} {@var{options} =} zenity_options (@var{dialog}, @var{param1}, @var{value1}, @dots{})
## This function is not intended for users but for the other functions of the
## zenity package. Returns the structure @var{options} that holds the processed
## @var{param} and @var{value} for the function of the zenity package
## @var{dialog}, or the defaults when they are not defined.. @var{dialog} must
## be a string and one of the following:
##
## @table @samp
## @item calendar
## @item entry
## @item file selection
## @item list
## @item message
## @item new notification
## @item piped notification
## @item new progress
## @item piped progress
## @item scale
## @item text info
## @end table
##
## @seealso{zenity_calendar, zenity_entry, zenity_file_selection, zenity_list,
## zenity_message, zenity_notification, zenity_progress, zenity_scale, 
## zenity_text_info}
## @end deftypefn

function op = zenity_options (dialog, varargin)

  varargin = varargin{1};    # because other functions varargin is this varargin

  ## Create empty variables in case user does not set them
  op.title = op.width = op.height = op.timeout = op.icon = "";
  if ( !ischar(dialog) )
    error ("Type of dialog should be a string");
  elseif (strcmpi(dialog, "calendar"))
    op.text = op.day = op.month = op.year = "";
  elseif (strcmpi(dialog, "entry"))
    op.password = op.entry = "";
  elseif (strcmpi(dialog, "file selection"))
    op.directory = op.filename = op.filter = op.multiple = op.save = "";
  elseif (strcmpi(dialog, "list"))
    op.separator = op.text     = op.hide      = op.print_col = op.no_head = "";
    op.multiple  = op.radio    = op.check     = op.editable  = "";
    op.hide_max  = op.hide_min = op.print_max = op.print_min = "";
    op.print_numel = op.num_out = "";
  elseif (strcmpi(dialog, "message"))
    op.type = op.wrap = op.ok = op.cancel = "";
  elseif (strcmpi(dialog, "new notification"))
    op.text = "";
  elseif (strcmpi(dialog, "piped notification"))
    op.text = op.message = op.visible = "";
  elseif (strcmpi(dialog, "new progress"))
    op.percent  = op.text       = op.auto_close   = "";
    op.pulsate  = op.auto_kill  = op.hide_cancel  = "";
  elseif (strcmpi(dialog, "piped progress"))
    op.percent  = op.text = "";
  elseif (strcmpi(dialog, "new scale"))
    op.text     = op.ini        = op.start  = "";
    op.hide     = op.end        = op.step   = "";
  elseif (strcmpi(dialog, "piped scale"))
  elseif (strcmpi(dialog, "text info"))
  else
    error ("The type of dialog '%s' is not supported", dialog);
  endif

  ## In case no options were set, stop here and return the empty strings
  if (numel(varargin) == 1 && isempty(varargin{1}))
    return
  endif

  ## Identifies when it's being called to process stuff to send through pipes
  ## since that will have major differences in the processing
  if ( any (strcmpi(dialog, {"piped notification", "piped progress", "piped scale"})) )
    pipelining = 1;
  else
    pipelining = 0;
  endif

  ## Here's the guidelines for the processing:
  ## - the parameteres and values are case insensitive
  ## - if a parameter is being defined twice, return an error
  ## - if a parameter requires a value but this is not given, return an error
  ## - check if the rigth type of value is given (char or scalar) and return an
  ## error if not

  ## This will hold the index of varargin  that's currently being processed
  narg = 1;

  ## This will ONLY process the input when the output WON'T be sent through a
  ## pipe. See the next while block for when it is
  while (narg <= numel (varargin))
    if (pipelining)
      break                       # Move to the next while to process the input
    endif
    param = varargin{narg++};

    if (narg <= numel(varargin))  # Check if we are already in the last index
      value = varargin{narg};     # this is only for readability later on.
    else                          # Writing varargin{narg} in all conditions
      value = "";                 # is a pain and makes it even more confusing
    endif

    if ( !ischar(param) )
        error ("All parameters must be strings.");

    ## Process ALL GENERAL OPTIONS first
    elseif (strcmpi(param,"title"))                   # General - title
      narg            = sanity_checks ("char", param, value, op.title, narg);
      op.title        = sprintf('--title="%s"', value);
    elseif (strcmpi(param,"width"))                   # General - width
      narg            = sanity_checks ("scalar", param, value, op.width, narg);
      op.width        = sprintf('--width="%i"', value);
    elseif (strcmpi(param,"height"))                  # General - height
      narg            = sanity_checks ("scalar", param, value, op.height, narg);
      op.height       = sprintf('--height="%i"', value);
    elseif (strcmpi(param,"timeout"))                 # General - timeout
      narg            = sanity_checks ("scalar", param, value, op.timeout, narg);
      op.timeout      = sprintf('--timeout="%i"', value);
    elseif (strcmpi(param,"icon"))                    # General - icon
      narg            = sanity_checks ("char", param, value, op.icon, narg);
      if (strcmpi(value, "error"))
        op.icon       = '--window-icon="error"';
      elseif (strcmpi(value, "info"))
        op.icon       = '--window-icon="info"';
      elseif (strcmpi(value, "question"))
        op.icon       = '--window-icon="question"';
      elseif (strcmpi(value, "warning"))
        op.icon       = '--window-icon="warning"';
      else
        op.icon       = sprintf('--window-icon="%s"', value);
      endif

    ## Process options for ZENITY_ENTRY
    elseif ( strcmpi(dialog, "entry") )
      if (strcmpi(param,"entry"))                     # Entry - entry text
        narg            = sanity_checks ("char", param, value, op.entry, narg);
        op.entry        = sprintf('--entry-text="%s"', value);
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
        op.filename     = sprintf('--filename="%s"', value);
      elseif (strcmpi(param,"filter"))                # File selection - file filter
        narg            = sanity_checks ("multiple-char", param, value, op.directory, narg);
        op.filter       = sprintf('%s --file-filter="%s"', op.filter, value);
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
      elseif (strcmpi(param,"ok button"))             # Message - OK button
        narg            = sanity_checks ("char", param, value, op.ok, narg);
        op.ok           = sprintf('--ok-label="%s"', value);
      elseif (strcmpi(param,"cancel button"))         # Message - cancel button
        narg            = sanity_checks ("char", param, value, op.cancel, narg);
        op.cancel       = sprintf('--cancel-label="%s"', value);
      else
        error ("Parameter '%s' is not supported for '%s' dialog.", param, dialog);
      endif

    ## Process options for ZENITY_NOTIFICATION (creating new)
    elseif ( strcmpi(dialog, "new notification") )
      if (strcmpi(param,"text"))                      # Notification - text
        narg            = sanity_checks ("char", param, value, op.text, narg);
        op.text         = sprintf('--text="%s"', value);
      else
        error ("Parameter '%s' is not supported for '%s' dialog.", param, dialog);
      endif

    ## Process options for ZENITY_LIST
    elseif ( strcmpi(dialog, "list") )
      if (strcmpi(param,"text"))                      # List - text
        narg            = sanity_checks ("char", param, value, op.text, narg);
        op.text         = sprintf('--text="%s"', value);
      elseif (strcmpi(param,"no headers"))            # List - no headers
        narg            = sanity_checks ("indie", param, value, op.no_head, narg);
        op.no_head      = "--hide-header";
      elseif (strcmpi(param,"editable"))              # List - editable
        narg            = sanity_checks ("indie", param, value, op.editable, narg);
        op.editable     = "--editable";
      elseif (strcmpi(param,"multiple"))              # List - multiple
        narg            = sanity_checks ("indie", param, value, op.multiple, narg);
        op.multiple     = "--multiple";
      elseif (strcmpi(param,"radiolist"))             # List - radiolist
        narg            = sanity_checks ("indie", param, value, op.radio, narg);
        op.radio        = "--radiolist";
      elseif (strcmpi(param,"checklist"))             # List - checklist
        narg            = sanity_checks ("indie", param, value, op.check, narg);
        op.check        = "--checklist";
      elseif (strcmpi(param,"numeric output"))        # List - numeric output
        narg            = sanity_checks ("char", param, value, op.num_out, narg);
        op.num_out      = value;
      elseif (strcmpi(param,"hide column"))           # List - hide column
        narg            = sanity_checks ("num", param, value, op.hide, narg);
        op.hide_min     = min(value(:));
        op.hide_max     = max(value(:));
        tmp             = "";
        for i = 1:numel(value)
          str = num2str(value(i));
          tmp = sprintf('%s%s,', tmp, str);
        endfor
        op.hide         = sprintf('--hide-column="%s"', tmp);
      elseif (strcmpi(param,"print column"))          # List - print column
        narg            = sanity_checks ("num", param, value, op.print_col, narg);
        op.print_min    = min(value(:));
        op.print_max    = max(value(:));
        op.print_numel  = numel(value);
        tmp             = "";
        for i = 1:numel(value)
          if (value == 0)
            tmp = "all"
            break
          endif
          str = num2str(value(i));
          tmp = sprintf('%s%s,', tmp, str);
        endfor
        op.print_col    = sprintf('--print-column="%s"', tmp);
      else
        error ("Parameter '%s' is not supported for '%s' dialog.", param, dialog);
      endif

    ## Process options for ZENITY_PROGRESS (creating new)
    elseif ( strcmpi(dialog, "new progress") )
      if (strcmpi(param,"text"))                      # Progress - text
        narg            = sanity_checks ("char", param, value, op.text, narg);
        op.text         = sprintf('--text="%s"', value);
      elseif (strcmpi(param,"auto close"))            # Progress - auto close
        narg            = sanity_checks ("indie", param, value, op.auto_close, narg);
        op.auto_close   = "--auto-close";
      elseif (strcmpi(param,"auto kill"))             # Progress - auto close
        narg            = sanity_checks ("indie", param, value, op.auto_kill, narg);
        op.auto_kill    = "--auto-kill";
      elseif (strcmpi(param,"hide cancel"))           # Progress - hide cancel
        narg            = sanity_checks ("indie", param, value, op.hide_cancel, narg);
        op.hide_cancel  = "--no-cancel";
      elseif (strcmpi(param,"pulsate"))               # Progress - pulsate
        narg            = sanity_checks ("indie", param, value, op.pulsate, narg);
        op.pulsate      = "--pulsate";
      elseif (strcmpi(param,"percentage"))            # Progress - percentage
        narg            = sanity_checks ("scalar", param, value, op.percent, narg);
        if (value < 0 || value > 100)
          error("Percentage must be between '0' and '100' but it was set to '%g'", value)
        endif
        ## floor must be used to round, so to avoid returning 100, which in the
        ## the case of having auto-close set, would close the dialog too soon
        op.percent      = sprintf('--percentage="%i"', floor(value));
      else
        error ("Parameter '%s' is not supported for '%s' dialog.", param, dialog);
      endif

    ## Process options for ZENITY_CALENDAR
    elseif ( strcmpi(dialog, "calendar") )
      if (strcmpi(param,"text"))                 # Calendar - text
        narg            = sanity_checks ("char", param, value, op.text, narg);
        op.text         = sprintf('--text="%s"', value);
      elseif (strcmpi(param,"day"))                   # Calendar - day
        narg            = sanity_checks ("scalar", param, value, op.day, narg);
        value           = round (value);
        if (value < 1 || value > 31) error("Default selection '%d' for day", value); endif
        op.day          = sprintf('--day="%d"', value);
      elseif (strcmpi(param,"month"))                   # Calendar - month
        narg            = sanity_checks ("scalar", param, value, op.month, narg);
        value           = round (value);
        if (value < 1 || value > 12) error("Invalid default selection '%d' for month", value); endif
        op.month        = sprintf('--month="%d"', value);
      elseif (strcmpi(param,"year"))                   # Calendar - day
        narg            = sanity_checks ("scalar", param, value, op.year, narg);
        value           = round (value);
        op.year         = sprintf('--year="%d"', value);
      else
        error ("Parameter '%s' is not supported for '%s' dialog.", param, dialog);
      endif

    else
      error ("Parameter '%s' is not supported.", param);
    endif

  endwhile


  ## This will ONLY process the input when the output WILL be sent through a
  ## pipe. See the previous while block when creating new dialogs
  while (narg <= numel (varargin))
    if (!pipelining)
      break                       # It should have already been processed in the previous while block but it doesn't hurt to check again
    endif
    param = varargin{narg++};

    if (narg <= numel(varargin))  # Check if we are already in the last index
      value = varargin{narg};     # this is only for readability later on
    else                          # Writing varargin{narg} in all conditions
      value = "";                 # is a pain and makes it even more confusing
    endif

    ## Process options for ZENITY_NOTIFICATION (pipelining)
    if ( strcmpi(dialog, "piped notification") )
      if (strcmpi(param,"text"))                      # Notification - text
        narg            = sanity_checks ("char", param, value, op.text, narg);
        op.text         = sprintf('tooltip: %s', value);
      elseif (strcmpi(param,"message"))                  # Notification - message
        narg            = sanity_checks ("char", param, value, op.message, narg);
        op.message      = sprintf('message: %s', value);
      elseif (strcmpi(param,"visible"))                  # Notification - message
        narg            = sanity_checks ("char", param, value, op.message, narg);
        if (strcmpi(value, "on"))
          op.visible    = "visible: true";
        elseif (strcmpi(value, "off"))
          op.visible    = "visible: false";
        else
          error ("'%s' is not a valid value for the parameter '%s'", value, param)
        endif
      elseif (strcmpi(param,"icon"))                  # Notification - icon
        narg            = sanity_checks ("char", param, value, op.icon, narg);
        if (strcmpi(value, "error"))
          op.icon       = 'icon: error';
        elseif (strcmpi(value, "info"))
          op.icon       = 'icon: info';
        elseif (strcmpi(value, "question"))
          op.icon       = 'icon: question';
        elseif (strcmpi(value, "warning"))
          op.icon       = 'icon: warning';
        else
          op.icon       = sprintf('icon: %s', value);
        endif
      else
        error ("Parameter '%s' is not supported for '%s' dialog.", param, dialog);
      endif

    ## Process options for ZENITY_PROGRESS (pipelining)
    elseif ( strcmpi(dialog, "piped progress") )
      if (strcmpi(param,"text"))                      # Progress - text
        narg            = sanity_checks ("char", param, value, op.text, narg);
        op.text         = sprintf('# %s', value);
      elseif (strcmpi(param,"percentage"))            # Progress - percentage
        narg            = sanity_checks ("scalar", param, value, op.percent, narg);
        if (value < 0 || value > 100)
          error("Percentage must be between '0' and '100' but it was set to '%g'", value)
        endif
        ## floor must be used to round, so to avoid returning 100, which in the
        ## the case of having auto-close set, would close the dialog too soon
        op.percent      = sprintf('%i', floor(value));
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
  elseif (strcmpi(dialog,"new notification"))             # Defaults for notification
    if ( isempty(op.icon) )
      op.icon = '--window-icon="warning"';
    endif
  endif

endfunction

################################################################################
##  Extra functions
################################################################################
function narg = sanity_checks (type, param, value, previous, narg)
  if (strcmpi(type,"char"))                             # Value must be string
    if (previous)
      idx = strfind(previous, "=");
      error ("Parameter '%s' set twice, with values '%s' and '%g'.", ...
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

  elseif (strcmpi(type,"num"))                          # Value can be set more than once
    if (previous)
      idx = strfind(previous, "=");
      error ("Parameter '%s' set twice, with values '%s' and '%g'.", ...
                  param, previous(idx(1)+2:end-1), value);
    elseif ( isempty(value) || !isnumeric(value) )
      error ("Parameter '%s' requires a numeric as value.", param);
    endif
    narg++;


  else
    error ("Non supported type for sanity_checks '%s'.", type)
  endif

endfunction
