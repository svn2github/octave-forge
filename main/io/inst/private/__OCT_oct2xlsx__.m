## Copyright (C) 2013,2014 Markus Bergholz
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
## xlsxwrite function pure written in octave - no dependencies are needed.
## tested with MS Excel 2010, Gnumeric, LibreOffice 4.x
##
## usage:
##	__OCT_oct2xlsx__(filename, matrix, wsh, range, spsh_opts)
##
##	matrix: have to be a 2D Matrix. NaN will be an empty cell in Excel. Strings are not supported!
##
##	wsh: can be a 1, 2 or 3 for indexing the worksheet. >3 is not supported yet!
##	wsh: can be string for naming the worksheet. the string has a limit length of 31!
##	wsh can be a cell for defining worksheet index and name at the same time. e.g. {2,'Made by Octave'}
##	xlswrite('default.xlsx',m) % default written to Table 1, named "Table1"
##	xlswrite('filename.xlsx',m,3) % written to Table 3, named "Table3"
##	xlswrite('another.xlsx',k,'string named') % written to Table 1, named "string named"
##	xlswrite('impressive.xlsx',data,{'my data',2}) % written to Table 2, named "my data"
##	xlswrite('impressive.xlsx',datay,{3, 'my other data'}) % written to Table 3, named "my other data"
##	xlswrite('next.xlsx',data,{'my data',2},'B2') % values will start at B2 (temporary broken!)
##
##	octave:85> m=rand(100,100);
##	octave:86> tic, xlsxwrite('test20.xlsx',m); toc
##	Elapsed time is 3.1919641494751 seconds.
##
##	octave:97> m=rand(1234,702);
##	octave:98> tic, xlsxwrite('interesting.xlsx',m); toc
##	Elapsed time is 253.35110616684 seconds.
## @end deftypefn

## Author: Markus Bergholz <markuman@gmail.com>
## ToDo
## - use english language as default (atm it's all german. "Tabelle1" instead of "Table1").
## - fix write to defined range (rows still starts a row 1)
## - write more than 3 worksheets
## - date and boolean type
## - write cell (numeric and string mixed)
## - open/add/edit/manipulate an existing xlsx file
## - improve mex file

## ChangeLog
## 2014/01/24		- include to io package
##			        - add write to defined range/position (offset). Works for colums, not for rows!
## 2014/01/20		- remove 702 column limit
##           		- write mex file to bypass the bottleneck (still exists because mex file calls a script file! now ~230sec for 1000x1000 matrix. before ~410sec)
## 2014/01/17		- include __OCT_cc__ instead of __number_to_alphabetic
##           		- fix/improve zip behavior
## 2013/11/23		- prepare xlswrite for handling existing files
##           		- take care for excel limitations (maybe tbc)
## 2013/11/17		- user can write to another worksheet. limited to index 1, 2 or 3 atm
##           		- user can name the worksheets by string. automatically written to sheetid 1.
##           		- user can define name+index at the same time {2,'wsh name'} e.g.
## 2013/11/16		- relationshiptypes validation fix
## Version 0.1
## 2013/11/08		- Initial Release

function [xls, rstatus] = __OCT_oct2xlsx__ (filename, matrix, wsh=1, crange="", spsh_opts, obj_dims)

% ####### Below code already in caller
%if (isempty (crange))
%  offset.row = 0;
%  offset.col = 0;
%else
%  offset.row = str2double (cell2mat (regexp (crange, '(\d*)', 'tokens'))) - 1;
%  offset.col = __OCT_cc__ (cell2mat (cell2mat (regexp (crange, '([A-Z]*)', 'tokens')))) - 1;
%endif

% ####### Below code already in oct2xls
%# Input matrix check
%# ==================
%if (ndims (matrix) != 2)
%  error ("xlsxwrite only supports 2D matrix");
%endif
%
%if (1048576 < rows (matrix))
%  error ("Too many rows. Excel is limited to 1,048,576 rows!");
%endif
%if 16384 < columns (matrix)
%  error ("Too many columns. Excel is limited to 16,384 colums!");
%endif

############## Nakijken, we hebben niet alles nodig

## FIXME
# when file exist, it gets complicated
if (ischar (wsh))
  if (31 < length (wsh))
    error ("Worksheet name longer than 31 characters is not supported by Excel");
  endif
  wsh_string = wsh;
  wsh_number = 1;
elseif (isnumeric (wsh))
  if (1 == wsh)
    wsh_number = wsh;
    wsh_string = "Tabelle1";
  elseif (2 == wsh)
    wsh_number = wsh;
    wsh_string = ("Tabelle2");
  elseif 3 == wsh
    wsh_number = wsh;
    wsh_string = "Tabelle3";
  else 
    error('wsh index must be 1, 2 or 3');
  endif
endif

## something cool, that matlab doesn't support
# xlswrite('myfile.xlsx',matrix,{'1','Sheetname'})
if (iscell (wsh))
  # check size
  if (1 ~= rows (wsh) || 2 ~= columns (wsh))
    error ("Too many input arguments for wsh");
  endif
  # check first argument
  if (1 == ischar (wsh{1,1}))
    if (31 < length (wsh{1,1}))
      error ("Worksheet name longer than 31 characters is not supported by Excel");
    endif
    wsh_string=wsh{1,1};
  elseif (isnumeric (wsh{1,1}))
    if (1 ~= ismember (wsh{1,1} ,1:3))
      error ("wsh index must be 1, 2 or 3");
    endif
    wsh_number = wsh{1,1};
  else
    error ("wsh should contain one numeric value (for indexing) and one string (for naming)");
  endif
  
  # check second argument
  if (ischar (wsh{1,2}))
    if (31 < length(wsh{1,2}))
      error ("Worksheet name longer than 31 characters is not supported by Excel");
    endif 
    wsh_string = wsh{1,2};
  elseif (isnumeric (wsh{1,2}))
    if (! ismember (wsh{1,2} ,1:3))
      error ("wsh index must be 1, 2 or 3");
    endif
    wsh_number = wsh{1,2};
  else
    error ("wsh should contain one numeric value (for indexing) and one string (for naming)");
  endif
endif

############ Kan vervangen door één functie-call met [be|over]schrijven worksheet

%if (! exist (filename, "file"))

  __OCT_OOXML_create_file__ (filename, matrix, wsh_number, wsh_string, offset);

%elseif (2 == exist (filename,"file"));
%
%  error('sorry, edit an existing file is not implemented yet')
%  %__OOXML_modify_file(filename, matrix, wsh_number, wsh_string);
%
%else
%
%  error ("%s is not a file!", filename)
%
%endif


endfunction
