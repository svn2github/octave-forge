## Copyright (C) 2009 Philip Nienhuis <pr.nienhuis at users.sf.net>
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

## ods2oct - get data out of an ODS spreadsheet into octave.
## Watch out, no error checks, and spreadsheet formula error results
## are conveyed as 0 (zero).
##
## Author: Philip Nienhuis
## Created: 2009-12-13

function [ rawarr, ods ] = ods2oct (ods, wsh, range)

	sh	= ods.workbook.getSheet (wsh);
	
	[dummy, nrows, ncols, toprow, lcol] = parse_sp_range (range);

	# Placeholder for data
	rawarr = cell (nrows, ncols);
	for ii=1:nrows
		for jj = 1:ncols
			celladdress = calccelladdress (toprow, lcol, ii, jj);
			try
				val = sh.getCellAt (celladdress).getValue ();
			catch
				# No panic, probably a merged cell
				val = {};
			end_try_catch
			if (~isempty (val))
				if (ischar (val))
					# Text string
					rawarr (ii, jj) = val;
				elseif (isnumeric (val))
					# Boolean
					if (val) rawarr (ii, jj) = true; else; rawarr (ii, jj) = false; endif 
				else
					try
						val = sh.getCellAt (celladdress).getValue ().doubleValue ();
						rawarr (ii, jj) = val;
					catch
						# Probably empty Cell
					end_try_catch
				endif
			endif
		endfor
	endfor
	
	ods.limits = [ lcol, lcol+ncols-1; toprow, toprow+nrows-1 ];

endfunction
