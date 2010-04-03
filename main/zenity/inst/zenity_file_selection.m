## Copyright (C) 2006 Søren Hauberg
## Copyright (C) 2010 Carnë Draug
## 
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
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
## @deftypefn  {Function File} @var{files} = zenity_file_selection(@var{title}, @var{option1}, ...)
## Opens a file selection dialog using Zenity. The variable @var{title} sets the
## title of the file selection window. The optional string arguments can be:
## @table @samp
## @item save
## The file selection dialog is a dialog for saving files.
## @item multiple
## It is possible to select multiple files. @var{files} will hold a cell array,
## even if user selects only one or no file.
## @item directory
## Activates directory-only selection.
## @item timeout=XX
## Specifies timeout @var{XX} in seconds after which the dialog is closed. If
## no file is selected in the specified time, returns an empty string or cell
## array, depending whether `multiple' was selected or not.
## @item Anything else
## The argument will be the default selected file.
## @end table
##
## @seealso{zenity_calendar, zenity_list, zenity_progress, zenity_entry, zenity_message,
## zenity_text_info, zenity_notification}
## @end deftypefn

function files = zenity_file_selection(title, varargin)

  save = multiple = directory = filename = timeout = "";
  if (nargin == 0 || isempty(title))
    title = "Select a file";
  endif
  for i = 1:length(varargin)
    option  = varargin{i};
    isc     = ischar(option);
    if (isc && strcmpi(option, "save"))
      save = "--save";
    elseif (isc && strcmpi(option, "multiple"))
      multiple = "--multiple";
    elseif (isc && strcmpi(option, "directory"))
      directory = "--directory";
    elseif (isc)
      if (strfind(option, "timeout="))
        timeout = ["--timeout=", option(strfind(option, "=")+1 : end)];
      else
        filename = sprintf('--filename="%s"', varargin{i});
      endif
    else
      error("zenity_file_selection: unsupported option");
    endif
  endfor

# The separator is set to "/" because it's an invalid character for filenames
# in most filesystems and so, unlikely to exist in the middle of filenames.
# It's also the fileseparator so filenames will always already start with a
# '/' which is good since we can look for double '//' as separator for filepaths
  cmd = sprintf('zenity --file-selection --title="%s" --separator="/" %s %s %s %s %s', ...
                 title, save, multiple, directory, filename, timeout);
  [status, output] = system(cmd);
  if (status == 0)
    if (output(end) == "\n")
        output = output(1:end-1);
    endif
# With 'multiple', always place the output in a cell array, even if only one
# file is selected.
    if (multiple)
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
# Exit code -1 = An unexpected error has occurred
# Exit code  1 = The user has either pressed Cancel, or used the window
# functions to close the dialog
# Exit code  5 = The dialog has been closed because the timeout has been reached
  elseif (status == 1 && multiple)
    warning("No file selected. Returning empty cell array.");
    files = cell(1);
  elseif (status == 1)
    warning("No file selected. Returning empty string.");
    files = "";
  elseif (status == 5 && multiple)
    warning("Timeout reached. No file selected selected. Returning empty cell array.");
    files = cell(1);
  elseif (status == 5)
    warning("Timeout reached. No file selected selected. Returning empty string.");
    files = "";
  elseif (status == -1)
    error("An unexpected error occurred: %s", output);
  else
    error("zenity_file_selection: %s", output);
  endif
endfunction
