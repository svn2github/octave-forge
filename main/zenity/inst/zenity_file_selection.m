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
## @deftypefn  {Function File} zenity_file_selection(@var{title}, @var{option1}, ...)
## Opens a file selection dialog.
## The variable @var{title} sets the title of the file selection window.
## The optional string arguments can be
## @table @samp
## @item save
## The file selection dialog is a dialog for saving files.
## @item multiple
## It is possible to select multiple files. @var{title}} will hold a cell array, even
## if user selects only one file.
## @item directory
## It is possible to select only directories.
## @item Anything else
## The argument will be the default selected file.
## @end table
## and @code{error}.
##
## @seealso{zenity_calendar, zenity_list, zenity_progress, zenity_entry, zenity_message,
## zenity_text_info, zenity_notification}
## @end deftypefn

function files = zenity_file_selection(title, varargin)

  save = multiple = directory = filename = "";
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
      filename = sprintf('--filename="%s"', varargin{i});
    else
      error("zenity_file_selection: unsupported option");
    endif
  endfor

  # Separator set to "/" because it's an invalid character in most decent
  # filesystems and so, unlikely to exist in the middle of filenames
  # It's also the fileseparator so filenames will always already start with a
  # '/' which is good since it can look for double '//' as separator
  cmd = sprintf('zenity --file-selection --title="%s" --separator="/" %s %s %s %s', ...
                 title, save, multiple, directory, filename);
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
        files = cell(length(idx)+1,1);
        idx   = [0, idx, length(output)];
        for i = 1:(length(idx)-2)
          files{i} = output((idx(i)+1):(idx(i+1)-1));
        endfor
        files{i+1} = output((idx(i+1)+1):idx(end));
        return
      else
        files     = cell(1);
        files{1}  = output;
        return
      endif
    else
      files = output;
    endif
  elseif (status == 1 || status == -1)
    warning("No file selected selected. Returning empty string.");
    files = "";
  else
    error("zenity_file_selection: %s", output);
  endif
endfunction
