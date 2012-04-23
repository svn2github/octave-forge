## Copyright (C) 2006 Søren Hauberg <soren@hauberg.org>
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
## @deftypefn {Function File} {[@var{selected}, @var{status}] =} zenity_list (@var{columns}, @var{data}, @var{param1}, @var{value1}, @dots{})
## Displays a graphical list of data using Zenity. The values on the list can be
## selected and/or modified by the user.
##
## @var{columns} must be a cell array of strings of length N containing the
## headers for each column of the list. @var{data} must be a cell array of
## strings of size NxM containing the data for the list.
##
## The following code produces a list dialog with two columns. The first column,
## @code{Age}, will have the values @code{10} and @code{20}, while the second,
## @code{Height}, will have the values @code{120cm} and @code{180cm}:
##
## @example
## @group
## columns = @{"Age", "Height"@}
## data    = @{"10", "120cm"
##            "20", "180cm"@}
## zenity_list(columns, data)
## @end group
## @end example
##
## @var{selected} holds a string with the value of the first column of the
## selected row. If the parameter @option{multiple} is set, or the @option{print
## column} has multiple values, @var{selected} is a cell array of strings. If a
## value is empty, it returns @code{(null)}. The values of @var{selected} may
## come in any order since the user is allowed to sort them. Instead, use of the
## parameter @option{hide column}, together with a numbered column is recomended.
##
## In the case no value has been selected when the window closes, @var{selected}
## will hold an empty string or cell array, the same size as it would be
## expected if one value had been selected.
##
## @var{status} holds the exit code. @code{0} if user pressed @option{OK} and
## selected at least one row, @code{1} if pressed @option{cancel}, @code{5} if
## timeout has been reached, and @code{256} if user has pressed @option{OK} but
## selected no row.
##
## All @var{parameters} are optional, but if given, may require a corresponding
## @var{value}. All possible parameters are:
##
## @table @samp
## @item checklist
## The first column in the list will be of check buttons. No value is required. If
## set, the first column of @var{data} must consist of strings with values
## @code{true} or @code{false} and the rows with values of @code{true} will be
## selected by default. This parameter cannot be set together with
## @option{editable}.or @option{checklist}. It automatically sets
## the parameter @option{multiple}. @var{selected} will return the
## values for the second column of data.
##
## The following example creates a list with the first and second row selected
## by default. If user press @option{OK}, it will return a cell array with two rows,
## with the strings @code{FreeBSD} and @code{Linux}.
##
## @example
## @group
## columns = @{"", "OS"@}
## data    = @{"true" , "FreeBSD"
##            "true" , "Linux"
##            "false", "NetBSD"
##            "false", "OpenBSD"
##            "false", "OpenSolaris"@}
## zenity_list(columns, data, "checklist")
## @end group
## @end example
##
## @item editable
## Allows the user to edit the values. No value is required. It cannot be set
## together with @option{checklist} or @option{radiolist}. Since a
## value can be erased, if an empty value is selected, it returns @code{(null)}.
##
## @item height
## Sets the height of the dialog window. Requires a scalar as value.
##
## @item hide_column
## Hides the specified columns from the user. Requires a numeric data type as
## value. Multiple columns can be selected with ranges or matrixes. If
## @option{radiolist} or @option{checklist} are set, the first
## column cannot cannot be hidden. The values of these columns will still be
## present in @var{selected}.
##
## The following example will show a list with foods only and a column with
## radio buttons. It will return the third column of @var{data}, the one that is
## not shown and holds the numbers.
##
## @example
## @group
## columns = @{"", "Foods", "not visible"@}
## data    = @{"true" , "Ice cream", "1"
##            "false", "Danish",    "2"
##            "false", "Soup",      "3"
##            "false", "Lasagne",   "4"@}
## zenity_list(columns, data, "radiolist", "hide_column", 3, "print_column", 3)
## @end group
## @end example
##
## @item no_headers
## Doesn't show the headers. No value is required. @var{columns} still needs to
## be defined and have the right size but may be a cell array of empty
## strings. Since the headers are hidden, the user cannot sort the values of the
## columns.
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
## Allows multiple rows to be selected. No value is required. It cannot be set
## with @option{radiolist} and is automatically set when @option{checklist} is set.
##
## @item numeric_output
## Returns @var{selected} as a matrix and numeric values (double precision type)
## instead of cell array of strings. It uses the function str2double for the
## conversion. Requires a string as value. Possible values are: 
##
## @table @samp
## @item error
## Abort the function and give an error if unable to covert into numeric form.
## @item nan
## Returns @code{NaN} for the values it is unable to convert.
## @end table
##
## @item print_column
## The numbers of the columns whose values should be returned. Requires a numeric
## data type as value. Multiple columns can be selected with ranges or matrixes,
## and all columns can be selected with the scalar @code{0}. If the
## @option{radiolist} or @option{checklist} are set, the first
## column cannot cannot be returned.
##
## @item radiolist
## The first column in the list will be of radio buttons. No value is required. If
## set, the first column of @var{data} must be consiste of strings with values
## @code{true} or @code{false}. If a row has a value of @code{true}, and only
## one row can have that value, it will be selected by default. Cannot be set
## with @option{multiple}, @option{editable}.or @option{checklist}. @var{selected}
## will return the values for the second column of data.
##
## @item text
## Sets the dialog text. Requires a string as value.
##
## @item timeout
## Sets the time in seconds after which the dialog is closed. Requires a scalar
## as value.
##
## @item title
## Sets the title of the window. Requires a string as value.
##
## @item width
## Sets the width of the dialog window. Requires a scalar as value.
##
## @end table
##
## @strong{Note:} ultimately, the availability of some parameters is dependent
## on the user's system preferences and zenity version.
##
## @seealso{input, menu, kbhit, zenity_message, zenity_file_selection,
## zenity_notification}
## @end deftypefn

function [val, status] = zenity_list(col, data, varargin)

  ## List of things that cannot be done:
  ## * editable cannot be set at the same time of checklist or radiolist
  ## * radiolist and checklist cannot be set at the same time
  ## * multiple and radiolist cannot be set at the same time
  ## * if radiolist or checklist are set, only 'true' and 'false' strings are
  ## allowed in the first column of data
  ## * if radiolist is set, only one row of the first column can have a string
  ## value of 'true'. All others must be 'false'
  ## * if print and hide column are set, they can't have a value of 1 (which is
  ## the buttons column)
  ## * if print and hide column are set, they can't have a value of larger than
  ## the number of columns  
  ## * if print value is to be set to zero (all columns), it must be set alone
  ## and not together with other values which contradict him
  ## * number of columns 'data' must be the same size as 'columns'
  ## * all cells in 'data' and 'column' must be strings


  ## TODO
  ## * should have the option to use logical values in the first column of data
  ## when using radio or check buttons?
  ## * parameters 'radiolist' and 'checklist' could take as value a cell array. The
  ## first would have to be a string with the column tittle and the second either
  ## a matrix of 1 and 0 (for the selected by default) or a scalar value with the
  ## row number to select by default
  ## * it could be possible to have a parameter that sets the divisor instead of
  ## counting on the low chances of having a value with the string we use. However,
  ## it's not so obvious how zenity will escape things, and same goes for the index
  ## function used to split the output

  ## Update figures so they are show before the dialog. To not be shown at this
  ## step, turn them off with 'figure(N, "visible", "off")
  ## This is similar to the functions input and pause
  drawnow;

  if (nargin < 1)
    error ("'columns' argument is not optional.")
  elseif (nargin < 2)
    error ("'data' argument is not optional.")
  elseif (!iscell(col))
    error ("'columns' argument must be a cell array.")
  elseif (!iscell(data))
    error ("'data' argument must be a cell array.")
  endif

  ## Sanity checks
  ## by using numel(col) instead of columns, allows to not worry on the dimension they are placed
  if (columns(data) != numel(col))
    error("size of 'columns' (%g) is different than the number of columns in 'data' (%g).", ...
          numel(col), columns(data))
  elseif (!all (cellfun (@ischar, data)))
      error ("all elements in 'data' must be strings.");
  elseif (!all (cellfun (@ischar, col)))
      error ("all elements in 'col' must be strings.");
  endif

  options = zenity_options ("list", varargin);

  ## More sanity checks
  if ( !isempty(options.checklist) && !isempty(options.radiolist) )
    error ("Parameter 'checklist' cannot be set together with 'radiolist'.")
  elseif( !isempty(options.multiple) && !isempty(options.radiolist) )
    error ("Parameter 'multiple' cannot be set together with 'radiolist'.")
  elseif ( !isempty(options.editable) && !isempty(options.radiolist) )
    error ("Parameter 'editable' cannot be set together with 'radiolist'.")
  elseif ( !isempty(options.editable) && !isempty(options.checklist) )
    error ("Parameter 'editable' cannot be set together with 'checklist'.")
  elseif ( !isempty(options.hide_column) && options.hide_min == 1 && (!isempty(options.checklist) || !isempty(options.radiolist)) )
    error ("'hide column' cannot have a value of 1 when 'checklist' and 'radiolist' are set.");
  elseif ( !isempty(options.print_column) && options.print_min == 1 && (!isempty(options.checklist) || !isempty(options.radiolist)) )
    error ("'print column' cannot have a value of 1 when 'checklist' and 'radiolist' are set.");
  elseif ( !isempty(options.print_column) && options.print_min == 0 && options.print_numel > 1)
    error ("Value of 0 (all) found as value for parameter 'print column' as part of multiple values. If desired, it must be set as scalar.");
  elseif ( !isempty(options.hide_column) && options.hide_max > numel(col) )
    error ("Value %g found for the parameter 'hide column' and is larger than the number of columns.", options.hide_max)
  elseif ( !isempty(options.print_column) && options.print_max > numel(col) )
    error ("Value %g found for the parameter 'print column' and is larger than the number of columns.", options.print_max)
  elseif ( !isempty(options.print_column) && options.print_min < 0 )
    error ("Negative value '%g' found for the parameter 'print column'.", options.print_min)
  elseif ( !isempty(options.hide_column) && options.hide_min < 1 )
    error ("Parameter 'hide column' cannot have values smaller than 1 (found minimun as '%g').", options.hide_min)
  endif

  if ( !isempty(options.checklist) )
    for i = 1:rows(data)
      if ( !strcmpi(data{i,1},"true") && !strcmpi(data{i,1},"false") )
        error ("All cells on the first column of 'data' must be either 'true' or 'false' when 'radiolist' or 'checklist' are set.");
      endif
    endfor
  elseif (!isempty(options.radiolist) )
    seen_true = 0;
    for i = 1:rows(data)
      if ( !strcmpi(data{i,1},"true") && !strcmpi(data{i,1},"false") )
        error ("All cells on the first column of 'data' must be either 'true' or 'false' when 'radiolist' or 'checklist' are set.");
      elseif (strcmpi(data{i,1},"true"))
        if (seen_true == 1)
          error ("Only one cell on the first column of 'data' can be true, when 'radiolist is set.");
        endif
        seen_true = 1;
      endif
    endfor
  endif

  ## Process for input
  data          = data';
  options.col   = sprintf("--column=\"%s\" ", col{:});
  options.data  = sprintf("\"%s\" ", data{:});

  ## Set separator
  options.separator = '--separator="/\\\|/\\\\"';   # Will use /\|/\ as separator
  ## we enter the delimiter here as well, as it appears in the zenity output,
  ## to prevent bugs from appearing if we change it one day
  sep_for_find      = '/\|/\';

  pre_cmd = sprintf("%s ", ...
                    options.title, ...
                    options.width, ...
                    options.height, ...
                    options.timeout, ...
                    options.separator, ...
                    options.text, ...
                    options.hide_column, ...
                    options.print_column, ...
                    options.multiple, ...
                    options.radiolist, ...
                    options.checklist, ...
                    options.editable, ...
                    options.icon, ...
                    options.col, ...
                    options.no_headers, ...
                    options.data);

  cmd               = sprintf ("zenity --list %s", pre_cmd);
  [status, output]  = system(cmd);

  # Exit code -1 = An unexpected error has occurred
  # Exit code  0 = The user has pressed either OK or Close. 
  # Exit code  1 = The user has either pressed Cancel, or used the window
  # functions to close the dialog
  # Exit code  5 = The dialog has been closed because the timeout has been reached

  # If it would be possible for the function to return more than one value
  if ( !isempty(options.checklist) || !isempty(options.multiple) || (!isempty(options.print_column) && options.print_numel > 1))
    multi = 1;
  else
    multi = 0;
  endif

  # Calculate the number of expected columns
  if ( !isempty(options.print_column) && options.print_min == 0 && (options.checklist || options.radiolist) )
    expec_col = numel(col) -1;
  elseif (!isempty(options.print_column) && options.print_min == 0)
    expec_col = numel(col);
  elseif (!isempty(options.print_column) && options.print_min != 0)
    expec_col = options.print_numel;
  else
    expec_col = 1;
  endif

  if (status == 0)
    ## User can press OK without selecting anything which returns empty string
    if (isempty(output) || (numel(output) == 1 && output(end) == "\n") )
      if (multi)
        val = cell(1,expec_col);
      else
        val = "";
      endif
     status = 256; # zenity should never return this value, it's forged for octave
     return
    endif
    if (output(end) == "\n")
        output = output(1:end-1);
    endif
    ## When 'multiple' values are expected, always place the output in a cell
    ## array, even if only one file is selected.
    if (multi)
      idx = strfind(output, sep_for_find);
      if (idx)
        tmp_val   = cell(length(idx)+1, 1);
        idx       = [(-(length(sep_for_find))+1), idx, length(output)+1];
        for i = 1 : (length(idx)-1)
          tmp_val{i}  = output( idx(i)+(length(sep_for_find)) : idx(i+1)-1 );
        endfor
        ## Order of the output will have them ordered by row. Must create an
        ## inversed cell array to allocate the values and transverse it at the end
        val = cell(expec_col, numel(tmp_val)/expec_col);
        for i = 1 : numel(tmp_val)
          val(i) = tmp_val(i);
        endfor
        val = val';
      else
        val     = cell(1);
        val{1}  = output;
      endif
    else
      val = output;
    endif
  elseif (multi && (status == 1 || status == 5))
    val = cell(1, expec_col);
  elseif (status == 1 || status ==5)
    val = "";
  else
    error("An unexpected error occurred with exit code '%i' and output '%s'.",...
          status, output);
  endif

  ## If user asked for numeric output, convert it to matrix
  ## TODO: currently, if timeout is reached, zenity returns nothing and an empty
  ## cell array gives an error on str2double. However, in the future (gnome
  ## bug #651948) this may be changed. When it does, the condition should accept
  ## status == 5 AND check if the cell array is not completely empty
  if (status == 0 && options.numeric_output)
    val = str2double(val);
    if (strcmpi(options.numeric_output, "error"))
      if ( any(isnan( val(:) )) )
        error("Conversion of output to numeric form was unsucessful")
      endif
    elseif (strcmpi(options.numeric_output, "nan"))
      ## Do nothing
    else
      error("Unknow value '%s' for the parameter 'numeric output'", option.num_out)
    endif
  endif

endfunction
