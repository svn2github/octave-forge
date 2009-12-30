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
## Max column index currently set to 1378 (ODS has max 1024)

## Author: Philip Nienhuis <prnienhuis at users.sf.net>
## Created: 2009-12-12
## Last updated: 2009-12-27

function [ celladdress ] = calccelladdress (trow, lcol, row, column)

	if (nargin < 4) error ("calccelladdress: not enough arguments.") endif
	colnr = lcol + column - 1;
	if (colnr> 1378) error ("Column nr > 1378"); endif
	str = char (rem ((colnr-1), 26) + 'A');
	if (colnr > 26 && colnr < 703) 
		tmp = char (floor ((colnr - 27) / 26) + 'A');
		str = [tmp str];
	elseif (colnr > 702 && colnr < 1379)
		tmp = char (floor ((colnr - 703) / 26) + 'A');
		str = ['A' tmp str];
	endif
	celladdress = sprintf ("%s%d", str, trow + row - 1);

endfunction