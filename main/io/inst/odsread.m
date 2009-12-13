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
## @deftypefn {Function File} @var{rawarr} = odsread (@var{filename}, @var{wsh}, @var{range})
## .
##
## Proof-of-concept function for reading data from an ODS spreadsheet.
## It works but there are no error checks at all; erroneous function 
## results and empty cells are not ignored but returned as 0.
##
## You need to have jOpenDocument-1.2b2.jar in your javaclasspath (get it at
## http://www.jopendocument.org/) and the octave-forge java package installed.
##
## @var{filename} must be a valid ODS spreadsheet file name. If @var{filename}
## does not contain any directory path, the file is saved in the current
## directory.
##
## @var{wsh} is the name or index number of a worksheet in the spreadsheet file.
##
## @var{range} must be a valid spreadsheet range and cannot be empty.
##
## Return args @var{numarr} and @var{txtarr} contain numeric & text data, 
## resp.; @var{rawarr} contains the raw data and lim the actual cell ranges
## from where the data originated.
##
## Example:
##
## @example
## [ n, t, r, l ] = odsread ('test1.ods', '2ndSh', 'A1:AF250');
## @end example
##
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis at users.sf.net>
## Created: 2009-12-12

function [ numarr, txtarr, rawarr, lim ] = odsread (filename, wsh, range)

	ods = odsopen (filename, 0);
	
	[rawarr, ods] = ods2oct (ods, wsh, range);
	
	[numarr, txtarr, lim] = parsecell (rawarr, ods.limits);

	odsclose (ods);

endfunction
