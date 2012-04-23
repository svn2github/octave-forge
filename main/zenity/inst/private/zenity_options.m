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
## @deftypefn {Function File} @var{options} = zenity_options (@var{dialog}, @var{param1}, @var{value1}, @dots{})
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

  p = inputParser;

  is_single_number = @(x) isscalar (x) && isnumeric (x);

  ## despite that we are setting defaults with inputParser we don't actually
  ## want them. If they are not set, we want to use the user's zenity default
  ## to be used. As such, we simply set something valid and will discard them
  ## if after parsing, they show up on p.UsingDefaults

  ## add general options to all zenity dialogs
  p = p.addParamValue ("height",  1, is_single_number);
  p = p.addParamValue ("icon",   "", @ischar);
  p = p.addParamValue ("timeout", 1, is_single_number);
  p = p.addParamValue ("title",  "", @ischar);
  p = p.addParamValue ("width",   1, is_single_number);

  if (!ischar (dialog))
    error ("Type of dialog should be a string");
  elseif (strcmpi (dialog, "calendar"))
    p = p.addParamValue ("day",    1, is_single_number);   # zenity still works when dates
    p = p.addParamValue ("month",  1, is_single_number);   # are invalid (day 35 of month 13)
    p = p.addParamValue ("text",  "", @ischar);
    p = p.addParamValue ("year",   1, is_single_number);   # we should do the same

  elseif (strcmpi (dialog, "entry"))
    p = p.addParamValue ("entry", "", @ischar);
    p = p.addSwitch     ("password");

  elseif (strcmpi (dialog, "file selection"))
    p = p.addSwitch     ("directory");
    p = p.addParamValue ("filename", "", @ischar);
    ## TODO add support for multiple filters (might need changes to @inputParser)
    p = p.addParamValue ("filter",   "", @ischar);
    p = p.addSwitch     ("multiple");
    p = p.addSwitch     ("overwrite");
    p = p.addSwitch     ("save");

  elseif (strcmpi (dialog, "list"))
    p = p.addSwitch     ("checklist");
    p = p.addSwitch     ("editable");
    p = p.addParamValue ("hide_column", 1, @(x) isnumeric (x) && isreal (x) && x > 0);
    p = p.addSwitch     ("multiple");
    p = p.addSwitch     ("no_headers");
    p = p.addParamValue ("numeric_output", "error", @(x) ischar (x) && any (strcmpi (x, {"error", "NaN"})));
    p = p.addParamValue ("print_column", 1, @(x) isnumeric (x) && isreal (x) && x >= 0);
    p = p.addSwitch     ("radiolist");
    p = p.addParamValue ("text", "", @ischar);

  elseif (strcmpi (dialog, "message"))
    p = p.addParamValue ("cancel", "", @ischar);
    p = p.addSwitch     ("no_wrap");
    p = p.addParamValue ("ok", "", @ischar);
    p = p.addParamValue ("type", "error", @(x) ischar (x) && any (strcmpi (x, {"error", "info", "question", "warning"})));

  elseif (strcmpi (dialog, "new notification"))
    p = p.addParamValue ("text", "", @ischar);

  elseif (strcmpi (dialog, "piped notification"))
    p = p.addParamValue ("text", "", @ischar);
    p = p.addParamValue ("message", "", @ischar);
    p = p.addParamValue ("visible", "on", @(x) ischar (x) && any (strcmpi (x, {"off", "on"})));

  elseif (strcmpi (dialog, "new progress"))
    p = p.addSwitch     ("auto_close");
    p = p.addSwitch     ("auto_kill");
    p = p.addSwitch     ("hide_cancel");
    p = p.addParamValue ("percentage", 1, @(x) is_single_number (x) && x >= 0 && x <= 100);
    p = p.addSwitch     ("pulsate");
    p = p.addParamValue ("text", "", @ischar);

  elseif (strcmpi (dialog, "piped progress"))
    p = p.addParamValue ("text", "", @ischar);
    p = p.addParamValue ("percentage", 1, @(x) is_single_number (x) && x >= 0 && x <= 100);

  elseif (strcmpi (dialog, "new scale"))
    op.text     = op.ini        = op.start  = "";
    op.hide     = op.end        = op.step   = "";
  elseif (strcmpi (dialog, "piped scale"))
  elseif (strcmpi (dialog, "text info"))
  else
    error ("The type of dialog '%s' is not supported", dialog);
  endif

  p   = p.parse(varargin{:});
  op  = p.Results;
  key = fieldnames (op);
  ## Identifies when it's being called to process stuff to send through pipes
  ## since that will have major differences in the processing
  if ( any (strcmpi(dialog, {"piped notification", "piped progress", "piped scale"})) )
    pipelining = 1;
  else
    pipelining = 0;
  endif

  for ii = 1: numel (key)
    if (pipelining)
      break                       # Move to the next loop to process the input
    elseif (any (strcmp (key{ii}, p.UsingDefaults)))
      op = setfield (op, key{ii}, "");
      continue
    endif
    switch key{ii}
      case {"auto_close"} op.auto_close   = "--auto-close";
      case {"auto_kill"}  op.auto_kill    = "--auto-kill";
      case {"cancel"}     op.cancel       = sprintf('--cancel-label="%s"', op.(key{ii}));
      case {"checklist"}  op.checklist    = "--checklist";
      case {"day"}        op.day          = sprintf('--day="%d"', round(op.(key{ii})));
      case {"directory"}  op.directory    = "--directory";
      case {"editable"}   op.editable     = "--editable";
      case {"entry"}      op.entry        = sprintf('--entry-text="%s"', op.(key{ii}));
      case {"filename"}   op.filename     = sprintf('--filename="%s"', op.(key{ii}));
      ## TODO add support for multiple filters (might need changes to @inputParser)
      case {"filter"}     op.filter       = sprintf('--file-filter="%s"', op.(key{ii}));
      case {"hide_cancel"} op.hide_cancel = "--no-cancel";
      case {"hide_column"}
        op.hide_min     = min(op.(key{ii})(:));
        op.hide_max     = max(op.(key{ii})(:));
        tmp             = "";
        for i = 1:numel(op.(key{ii}))
          str = num2str(op.(key{ii})(i));
          tmp = sprintf('%s%s,', tmp, str);
        endfor
        op.hide_column  = sprintf('--hide-column="%s"', tmp);
      case {"height"}     op.height       = sprintf('--height="%i"', round(op.(key{ii})));
      case {"icon"}
        switch tolower (op.(key{ii}))
          case {"error"}
            op.icon = '--window-icon="error"';
          case {"info"}
            op.icon = '--window-icon="info"';
          case {"question"}
            op.icon = '--window-icon="question"';
          case {"warning"}
            op.icon = '--window-icon="warning"';
          otherwise
            op.icon = sprintf('--window-icon="%s"', op.(key{ii}));
        endswitch
      case {"month"}      op.month        = sprintf('--month="%d"', round(op.(key{ii})));
      case {"multiple"}   op.multiple     = "--multiple";
      case {"no_headers"} op.no_headers   = "--hide-header";
      case {"no_wrap"}    op.no_wrap      = "--no-wrap";
      case {"numeric_output"} op.numeric_output = op.(key{ii});
      case {"ok"}         op.ok           = sprintf('--ok-label="%s"', op.(key{ii}));
      case {"overwrite"}  op.overwrite    = "--confirm-overwrite";
      case {"password"}   op.password     = "--hide-text";
      case {"print_column"}
        op.print_min    = min(op.(key{ii})(:));
        op.print_max    = max(op.(key{ii})(:));
        op.print_numel  = numel(op.(key{ii}));
        tmp             = "";
        for i = 1:numel(op.(key{ii}))
          if (op.(key{ii}) == 0)
            tmp = "all"
            break
          endif
          str = num2str(op.(key{ii})(i));
          tmp = sprintf('%s%s,', tmp, str);
        endfor
        op.print_column = sprintf('--print-column="%s"', tmp);
      case {"pulsate"}    op.pulsate      = "--pulsate";
      case {"percentage"} op.percentage   = sprintf('--percentage="%i"', floor(op.(key{ii})));
      case {"radiolist"}  op.radiolist    = "--radiolist";
      case {"save"}       op.save         = "--save";
      case {"text"}       op.text         = sprintf('--text="%s"', op.(key{ii}));
      case {"timeout"}    op.timeout      = sprintf('--timeout="%i"', round(op.(key{ii})));
      case {"title"}      op.title        = sprintf('--title="%s"', op.(key{ii}));
      case {"type"}
        switch tolower (op.(key{ii}))
          case {"error"}
            op.type = "--error";
          case {"info"}
            op.type = "--info";
          case {"question"}
            op.type = "--question";
          case {"warning"}
            op.type = "--warning";
        endswitch
      case {"width"}      op.width        = sprintf('--width="%i"', round(op.(key{ii})));
      case {"year"}       op.year         = sprintf('--year="%d"', round(op.(key{ii})));
      otherwise
        error ("Something unexpected happened when parsing options. Invalid value %s", key{ii});
    endswitch
  endfor

  for ii = 1: numel (key)
    if (!pipelining)
      break                       # It should have already been processed in the previous while block but it doesn't hurt to check again
    elseif (any (strcmp (key{ii}, p.UsingDefaults)))
      op = setfield (op, key{ii}, "");
      continue
    endif
    switch key{ii}
      case {"icon"}
        switch tolower (op.(key{ii}))
          case {"error"}
            op.icon = 'icon: error';
          case {"info"}
            op.icon = 'icon: info';
          case {"question"}
            op.icon = 'icon: question';
          case {"warning"}
            op.icon = 'icon: warning';
          otherwise
            op.icon = sprintf('icon: %s', value);
        endswitch
      case {"message"}    op.message      = sprintf('message: %s', op.(key{ii}));
      case {"percentage"} op.percentage   = sprintf('%i', op.(key{ii}));
      case {"text"}
        switch dialog
          case {"piped notification"}
            op.text         = sprintf('tooltip: %s', op.(key{ii}));
          case {"piped progress"}
            op.text         = sprintf('# %s', op.(key{ii}));
        endswitch
      case {"visible"}
        switch tolower (op.(key{ii}))
          case {"on"}
            op.visible = "visible: true";
          case {"off"}
            op.visible = "visible: false";
        endswitch
      otherwise
        error ("Something unexpected happened when parsing options. Invalid value %s", key{ii});
    endswitch
  endfor

endfunction
