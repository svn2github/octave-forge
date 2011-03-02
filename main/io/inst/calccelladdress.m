## Copyright (C) 2009,2010 Philip
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

## Compute spreadsheet style cell address from row & column index (both 1-based).
## 
## Max column index: 18278 (max ODS: 1024, OOXML: 16384).
## Max row index 1048576 (max ODS 1.2: 65536; OOXML / ODS 1.2-extended: 1048576).

## Author: Philip Nienhuis <prnienhuis at users.sf.net>
## Created: 2009-12-12
## Updates:
## 2009-12-27 Fixed OOXML limits
## 2010-03-17 Simplified argument list, only row + column needed
## 2010-09-27 Made error message more comprehensible
## 2010-10-11 Added check for row range
## 2011-03-01 Textual fixes in header

function [ celladdress ] = calccelladdress (row, column)

	if (nargin < 2) error ("calccelladdress: Two arguments needed") endif

	if (column > 18278 || column < 1) error ("Specified column out of range (1..18278)"); endif
	if (row > 1048576 || row < 1), error ('Specified row out of range (1..1048576)'); endif
	rem1 = rem ((column-1), 26);
	str = char (rem1 + 'A');								# A-Z; rightmost digit
	if (column > 26 && column < 703)						# AA-ZZ
		tmp = char (floor(column - rem1) / 26 - 1 + 'A');	# Leftmost digit
		str = [tmp str];
	elseif (column > 702 && column < 18279)					# AAA-ZZZ
		rem2 = rem ((column - 26 - rem1) - 1, 676);
		str2 = char (rem2 / 26 + 'A');						# Middle digit
		column = column -  rem2 - rem1;
		str3 = char (column / 676 - 1 + 'A');				# Leftmost digit
		str = [str3 str2 str];
	endif	
	celladdress = sprintf ("%s%d", str, row);

endfunction