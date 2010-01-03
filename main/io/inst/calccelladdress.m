## Copyright (C) 2009 Philip
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

## calccelladdress - compute spreadsheet style cell address from
## row & column index.
## 
## Max column index currently set to 18278 (max ODS: 1024, OOXML: 16384).
## Row limits for ODF and OOXML are 65536 and 1048576, resp.

## Author: Philip Nienhuis <prnienhuis at users.sf.net>
## Created: 2009-12-12
## Last updated: 2009-12-27

function [ celladdress ] = calccelladdress (trow, lcol, row, column)

	if (nargin < 4) error ("calccelladdress: not enough arguments.") endif
	colnr = lcol + column - 1;
	if (colnr > 18278) error ("Column nr > 18278"); endif
	rem1 = rem ((colnr-1), 26);
	str = char (rem1 + 'A');								# A-Z; rightmost digit
	if (colnr > 26 && colnr < 703)							# AA-ZZ
		tmp = char (floor(colnr - rem1) / 26 - 1 + 'A');	# Leftmost digit
		str = [tmp str];
	elseif (colnr > 702 && colnr < 18279)					# AAA-ZZZ
		rem2 = rem ((colnr - 26 - rem1) - 1, 676);
		str2 = char (rem2 / 26 + 'A');						# Middle digit
		colnr = colnr -  rem2 - rem1;
		str3 = char (colnr / 676 - 1 + 'A');				# Leftmost digit
		str = [str3 str2 str];
	endif	
	celladdress = sprintf ("%s%d", str, trow + row - 1);

endfunction