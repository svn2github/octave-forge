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

## parse_sp_range
##  Parse a string representing a range of cells for a spreadsheet  
##  into nr of rows and nr of columns and also extract top left
##  cell address + top row+ left column. Some error checks are implemented.

## Author: Philip Nienhuis
## Created: 2009-06-20
## Latest update 2009-12-11

function [topleft, nrows, ncols, toprow, lcol] = parse_sp_range (range_org)

	# This entire function needs fixing or replacement for OOXML (larger ranges)

	range = deblank (toupper (range_org));
	range_error = 0; nrows = 0; ncols = 0;

	if (index (range, ':') == 0) 
		if (isempty (range))
			range_error = 0;
			leftcol = 'A';
			rightcol = 'A';
		else
			# Only upperleft cell given, just complete range to 1x1
			range = [range ":" range];
		endif
	endif
	[topleft, lowerright] = strtok (range, ':');
	[st, en] = regexp (topleft, '\d+');
	toprow = str2num (topleft(st:en));
	leftcol = deblank (topleft(1:st-1));
	[st, en1] = regexp( leftcol,'\s+');
	if (isempty (en1)) 
		en1=0; 
	endif
	[st, en2] = regexp (leftcol,'\D+');
	leftcol = leftcol(en1+1:en2);

	[st, en] = regexp (lowerright,'\d+');
	bottomrow = str2num (lowerright(st:en));
	rightcol = deblank (lowerright(2:st-1));
	[st, en1] = regexp (rightcol,'\s+');
	if (isempty (en1)) 
		en1=0; 
	endif
	[st, en2] = regexp (rightcol,'\D+');
	rightcol = rightcol(en1+1:en2);
	nrows = bottomrow - toprow + 1; 
	if (nrows < 1) 
		range_error = 1; 
	endif

	if (range_error == 0) 
	# Get columns. 
	# FIXME for OOXML! We provisonally assume Excel 97 format, max 256 columns
	ncols = 0;  
	[st, en1] = regexp (leftcol, '\D+');
	[st, en2] = regexp (rightcol, '\D+');
	i1= 0; i2 = 0;
	if (en2 > en1)
		i1 = rightcol(2:2) - leftcol(1:1) + 1;
		i2 = rightcol(1:1) - 'A'+ 1;
		lcol = leftcol(1:1) - 'A' + 1;
		elseif (en2 == en1) 
			i1 = rightcol(en2) - leftcol(en2) + 1;
			lcol = leftcol(1:1) - 'A' + 1;
			if (en2 == 2)
				i2 = rightcol(1) - leftcol(1);
				lcol = lcol * 26 + (leftcol(2:2) - 'A' + 1);
			endif
		else
			range_error = 1;	 
		endif
		ncols = i1 + 26 * i2;
		if (ncols < 1) 
			range_error = 1; 
		endif
	endif

	if (range_error > 0) 
		ncols = 0; nrows = 0;
		error ("Spreadsheet range error! ");
	endif
  
endfunction
