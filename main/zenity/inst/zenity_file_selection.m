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
## @deftypefn {Function File} {[@var{files} @var{status}] =} zenity_file_selection (@var{param1}, @var{value1}, @dots{})
## Opens a file selection dialog using Zenity.
##
## @var{files} is a string or a cell array of strings depending on whether the
## function has been set to allow selection of multiple files or directories.
##
## @var{status} will be @code{0} if user pressed @option{OK} (and selected
## something), @code{1} if closed the window without selecting something, and
## @code{5} if timeout has been reached (and therefore no file was selected).
##
## All @var{parameters} are optional, but if given, may require a corresponding
## @var{value}. All possible parameters are:
##
## @table @samp
## @item directory
## Activates directory-only selection. No value is required.
##
## @item filename
## Sets the default selected file. Requires a string as value.
##
## @item filter
## Sets a filename filter. Requires a string as value. Multiple filters can be
## set with multiple calls of this parameter, or one filter can be made with
## multiple regexp. Filters can also be named which blocks the user from actualy
## seeing the filter.. The following examples shows how to create two filters,
## two named filters, one filter for two different extensions, and the same
## filter but named:
## @example
## @code{zenity_file_selection ("filter", "*.txt", "filter", "*.m")}
## @code{zenity_file_selection ("filter", "text files| *.txt", "filter", "octave files| *.m")}
## @code{zenity_file_selection ("filter", "*.tif *.png")}
## @code{zenity_file_selection ("filter", "Images | *.tif *.png")}
## @end example
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
## @item multiple
## Allows selection of multiple files. No value is required. @var{files} will
## hold a cell array, even if user selects only one or no file.
##
## @item save
## The file selection dialog is a dialog for saving files. No value is required.
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
## @end table
##
## @strong{Note:} ultimately, the availability of some parameters is dependent
## on the user's system preferences and zenity version.
##
## @seealso{zenity_list, zenity_entry, zenity_message, zenity_text_info}
## @end deftypefn

function [files, status] = zenity_file_selection(varargin)

  ## Update figures so they are show before the dialog. To not be shown at this
  ## step, turn them off with 'figure(N, "visible", "off")
  ## This is similar to the functions input and pause
  drawnow;

  options = zenity_options ("file selection", varargin);

  if ( !isempty(options.save) && (!isempty(options.multiple) || !isempty(options.directory)) )
    error ("Parameter 'save' cannot be set together with 'multiple' or directory'.");
  endif

  # The separator is set to "/" because it's an invalid character for filenames
  # in most filesystems and so, unlikely to exist in the middle of filenames.
  # It's also the fileseparator so filenames will always already start with a
  # '/' which is good since we can look for double '//' as separator for filepaths
  pre_cmd = sprintf("%s ", ...
                    options.directory, ...
                    options.filename, ...
                    options.height, ...
                    options.multiple, ...
                    options.save, ...
                    options.timeout, ...
                    options.title, ...
                    options.width, ...
                    options.filter, ...
                    options.icon);

  cmd              = sprintf("zenity --file-selection --separator=\"/\" %s", pre_cmd);
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
  elseif (options.multiple && (status == 1 || status == 5) )
    files = cell(1);
  elseif (status == 1 || status == 5)
    files = "";
  else
    error("An unexpected error occurred with exit code '%i' and output '%s'",...
          status, output);
  endif
endfunction
