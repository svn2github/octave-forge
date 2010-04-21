## Copyright (C) 2006 Søren Hauberg
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
## @deftypefn  {Function File} @var{files} = zenity_file_selection(@var{param1}, @var{value1}, ...)
## Opens a file selection dialog using Zenity. All @var{parameters} are 
## optional, but if given, may require a corresponding @var{value}. All possible
## parameters are:
## 
## @table @samp
## @item directory
## Activates directory-only selection. No value is required.
## @item filename
## Sets the default selected file. Requires a string as value.
## @item filter
## Sets a filename filter. Requires a string as value. Multiple filters can be
## set with multiple calls for this setting. The following example shows how to
## block users from selecting files that don't end in `.txt' or `.m':
## @example
## @code{zenity_file_selection ("filter", "*.txt", "filter", "*.m")}
## @end example
## @item height
## Sets the height of the dialog window. Requires a scalar as value.
## @item multiple
## Allows selection of multiple files. No value is required. @var{files} will
## hold a cell array, even if user selects only one or no file.
## @item save
## The file selection dialog is a dialog for saving files. No value is required.
## @item timeout
## Sets the time in seconds after which the dialog is closed. Requires a scalar
## as value.
## @item title
## Sets the title of the window. Requires a string as value.
## @item width
## Sets the width of the dialog window. Requires a scalar as value.
## @end table
##
## @seealso{zenity_list, zenity_entry, zenity_message, zenity_text_info}
## @end deftypefn

function files = zenity_file_selection(varargin)

  options = _zenity_options_ ("file selection", varargin);

  if ( !isempty(options.save) && (!isempty(options.multiple) || !isempty(options.directory)) )
    error ("Parameter 'save' cannot be set together with 'multiple' or directory'.");
  endif

  # The separator is set to "/" because it's an invalid character for filenames
  # in most filesystems and so, unlikely to exist in the middle of filenames.
  # It's also the fileseparator so filenames will always already start with a
  # '/' which is good since we can look for double '//' as separator for filepaths
  cmd = sprintf("zenity --file-selection --separator=\"/\" %s %s %s %s %s %s %s", ...
                 options.directory, options.filename, options.height, ...
                 options.multiple, options.save, options.timeout, ...
                 options.title, options.width, options.filter);

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
  # With 'multiple', always place the output in a cell array, even if only one
  # file is selected.
    if (options.multiple)
      idx = strfind(output, "//");
      if (idx)
        files = cell(length(idx)+1, 1);
        idx   = [0, idx, length(output)+1];
        for i = 1 : (length(idx)-1)
          files{i}  = output( idx(i)+1 : idx(i+1)-1 );
        endfor
      else
        files     = cell(1);
        files{1}  = output;
      endif
    else
      files = output;
    endif
  elseif (status == 1 && options.multiple)
    warning("No file selected. Returning empty cell array.");
    files = cell(1);
  elseif (status == 1)
    warning("No file selected. Returning empty string.");
    files = "";
  elseif (status == 5 && options.multiple)
    warning("Timeout reached. No file selected. Returning empty cell array.");
    files = cell(1);
  elseif (status == 5)
    warning("Timeout reached. No file selected. Returning empty string.");
    files = "";
  else
    error("An unexpected error occurred with exit code '%i' and output '%s'",...
          status, output);
  endif
endfunction
