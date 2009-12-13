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
## Max column index currently set to 1024 (ODS)

## Author: Philip Nienhuis <prnienhuis at users.sf.net>
## Created: 2009-12-12

function [ celladdress ] = calccelladdress (trow, lcol, row, column)

	colnr = lcol + column - 1;
	if (colnr> 1024) error ("Column nr >1024"); endif
	str = char (rem ((colnr-1), 26) + 'A');
	if (colnr > 26 && colnr < 703) 
		tmp = char (floor ((colnr - 27) / 26) + 'A');
		str = [tmp str];
	elseif (colnr > 702)
		tmp = char (floor ((colnr - 703) / 26) + 'A');
		str = ['A' tmp str];
	endif
	celladdress = sprintf ("%s%d", str, trow + row - 1);

endfunction