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

## calccelladdress (R, C) - compute spreadsheet style cell address from
## row & column index (both 1-based).
## 
## Max column index currently set to 18278 (max ODS: 1024, OOXML: 16384).
## Row limits for ODF and OOXML are 65536 and 1048576, resp.

## Author: Philip Nienhuis <prnienhuis at users.sf.net>
## Created: 2009-12-12
## Updates:
## 2009-12-27 Fixed OOXML limits
## 2010-03-17 Simplified argument list, only row + column needed.

function [ celladdress ] = calccelladdress (row, column)

	if (nargin < 2) error ("calccelladdress: not enough arguments.") endif

	if (column > 18278) error ("Column nr > 18278"); endif
	rem1 = rem ((column-1), 26);
	str = char (rem1 + 'A');								# A-Z; rightmost digit
	if (column > 26 && column < 703)							# AA-ZZ
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