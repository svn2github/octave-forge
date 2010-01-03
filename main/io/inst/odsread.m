## Copyright (C) 2009 Philip Nienhuis <prnienhuis at users.sf.net>
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
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} [@var{numarr}, @var{txtarr}, @var{rawarr},  @var{limits}] = odsread (@var{filename})
## @deftypefnx {Function File} [@var{numarr}, @var{txtarr}, @var{rawarr}, @var{limits}] = odsread (@var{filename}, @var{wsh})
## @deftypefnx {Function File} [@var{numarr}, @var{txtarr}, @var{rawarr}, @var{limits}] = odsread (@var{filename}, @var{wsh}, @var{range})
## @deftypefnx {Function File} [@var{numarr}, @var{txtarr}, @var{rawarr}, @var{limits}] = odsread (@var{filename}, @var{wsh}, @var{range}, @var{reqintf})
##
## Read data contained in range @var{range} from worksheet @var{wsh}
## in OpenOffice.org Calc spreadsheet file @var{filename}.
##
## You need the octave-forge java package (> 1.2.5) and one or both of
## jopendocument.jar or preferrably: (odfdom.jar & xercesImpl.jar) in
## your javaclasspath.
##
## Return argument @var{numarr} contains the numeric data, optional
## return arguments @var{txtarr} and @var{rawarr} contain text strings
## and the raw spreadsheet cell data, respectively, and @var{limits} is
##a struct containing the data origins of the various returned arrays.
##
## If @var{filename} does not contain any directory, the file is
## assumed to be in the current directory.
##
## @var{wsh} is either numerical or text, in the latter case it is 
## case-sensitive and it should conformtoOpenOffice.org Calc sheet
## name requirements.
## Note that in case of a numerical @var{wsh} this number refers to the
## position in the worksheet stack, counted from the left in a Calc
## window. The default is numerical 1, i.e. the leftmost worksheet
## in the Calc file.
##
## @var{range} is expected to be a regular spreadsheet range format,
## or "" (empty string, indicating all data in a worksheet).
##
## If only the first argument is specified, odsread will try to read
## all contents from the first = leftmost (or the only) worksheet (as
## if a range of @'' (empty string) was specified).
## 
## If only two arguments are specified, odsread assumes the second
## argument to be @var{wsh} and to refer to a worksheet. In that case
## odsread tries to read all data contained in that worksheet.
##
## The optional last argument @var{reqintf} can be used to override 
## the automatic selection by odsread of one interface out of the
## supported ones: Java/ODFtoolkit ('OTK') or Java/jOpenDocument 
## ('JOD').
##
## Erroneous data and empty cells are set to NaN in @var{numarr} and
## turn up empty in @var{txtarr} and @var{rawarr}. Date/time values
## in date/time formatted cells are returned as numerical values in
## @var{obj} with base 1-1-000. Note that OpenOfice.org and MS-Excel
## have different date base values (1/1/0000 & 1/1/1900, resp.) and
## internal representation so MS-Excel spreadsheets rewritten into
## .ods format by OpenOffice.org Calc may have different date base
## values.
##
## @var{numarr} and @var{txtarr} are trimmed from empty outer rows
## and columns, so any returned array may turn out to be smaller than
## requested in @var{range}.
##
## When reading from merged cells, all array elements NOT corresponding 
## to the leftmost or upper Calc cell will be treated as if the
## "corresponding" Calc cells are empty.
##
## odsread is just a wrapper for a collection of scripts that find out
## the interface to be used and do the actual reading. For each call
## to odsread the interface must be started and the Calc file read into
## memory. When reading multiple ranges (in optionally multiple worksheets)
## a significant speed boost can be obtained by invoking those scripts
## directly (odsopen / ods2oct [/ parsecell] / ... / odsclose).
##
## Examples:
##
## @example
##   A = odsread ('test4.ods', '2nd_sheet', 'C3:AB40');
##   (which returns the numeric contents in range C3:AB40 in worksheet
##   '2nd_sheet' from file test4.ods into numeric array A) 
## @end example
##
## @example
##   [An, Tn, Ra, limits] = odsread ('Sales2009.ods', 'Third_sheet');
##   (which returns all data in worksheet 'Third_sheet' in file test4.ods
##   into array An, the text data into array Tn, the raw cell data into
##   cell array Ra and the ranges from where the actual data came in limits)
## @end example
##
## @seealso odsopen, ods2oct, odsclose, odsfinfo, parsecell
##
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis at users.sf.net>
## Created: 2009-12-12
## Last update: 2009-12-29

function [ numarr, txtarr, rawarr, lim ] = odsread (filename, wsh=1, datrange=[], reqintf=[])

	ods = odsopen (filename, 0, reqintf);
	
	[rawarr, ods] = ods2oct (ods, wsh, datrange);
	
	[numarr, txtarr, lim] = parsecell (rawarr, ods.limits);

	ods = odsclose (ods);

endfunction
