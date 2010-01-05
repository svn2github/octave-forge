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

## -*- texinfo -*-
## @deftypefn {Function File} [ @var{rawarr}, @var{ods}, @var{rstatus} ] = ods2oct (@var{ods})
## @deftypefnx {Function File} [ @var{rawarr}, @var{ods}, @var{rstatus} ] = ods2oct (@var{ods}, @var{wsh})
## @deftypefnx {Function File} [ @var{rawarr}, @var{ods}, @var{rstatus} ] = ods2oct (@var{ods}, @var{wsh}, @var{range})
##
## Read data contained within range @var{range} from worksheet @var{wsh}
## in an OpenOffice.org spreadsheet file pointed to in struct @var{ods}.
##
## ods2oct is a mere wrapper for interface-dependent scripts (e.g.,
## ods2jotk2oct and ods2jod2oct) that do the actual reading.
##
## @var{wsh} is either numerical or text, in the latter case it is 
## case-sensitive and it may be max. 31 characters long.
## Note that in case of a numerical @var{wsh} this number refers to the
## position in the worksheet stack, counted from the left in a Calc
## window. The default is numerical 1, i.e. the leftmost worksheet
## in the ODS file.
##
## @var{range} is expected to be a regular spreadsheet range format,
## or "" (empty string, indicating all data in a worksheet).
##
## If only the first argument is specified, ods2oct will try to read
## all contents from the first = leftmost (or the only) worksheet (as
## if a range of @'' (empty string) was specified).
## 
## If only two arguments are specified, ods2oct assumes the second
## argument to be @var{wsh}. In that case ods2oct will try to read
## all data contained in that worksheet.
##
## Return argument @var{rawarr} contains the raw spreadsheet cell data.
## Optional return argument @var{ods} contains the pointer struct. Field
## @var{ods}.limits contains the outermost column and row numbers of the
## actually read cell range.
## @var{rstatus} will be set to 1 if the requested data have been read
## successfully, 0 otherwise.
## Use parsecell() to separate numeric and text values from @var{rawarr}.
##
## @var{ods} is supposed to have been created earlier by odsopen in the
## same octave session. It is only referred to, not changed.
##
## Erroneous data and empty cells turn up empty in @var{rawarr}.
## Date/time values in OpenOffice.org are returned as numerical values
## with base 1-1-0000 (same as octave). But beware that Excel spreadsheets
## rewritten by OpenOffice.org into .ods format may have numerical date
## cells with base 01-01-1900 (same as MS-Excel).
##
## Be aware that ods2oct trims @var{rawarr} from empty outer rows & columns, 
## so any returned cell array may turn out to be smaller than requested
## in @var{range}.
##
## When reading from merged cells, all array elements NOT corresponding 
## to the leftmost or upper OpenOffice.org cell will be treated as if the
## "corresponding" cells are empty.
##
## Examples:
##
## @example
##   A = ods2oct (ods1, '2nd_sheet', 'C3:ABS40000');
##   (which returns the numeric contents in range C3:ABS40000 in worksheet
##   '2nd_sheet' from a spreadsheet file pointed to in pointer struct ods1,
##   into numeric array A) 
## @end example
##
## @example
##   [An, ods2, status] = ods2oct (ods2, 'Third_sheet');
## @end example
##
## @seealso odsopen, odsclose, parsecell, odsread, odsfinfo
##
## @end deftypefn

## Author: Philip Nienhuis
## Created: 2009-12-13
## Latest update of ods2oct: 2009-12-30
## Latest update of functions below: 2010-01-05

function [ rawarr, ods, rstatus ] = ods2oct (ods, wsh=1, datrange=[])

	if (strcmp (ods.xtype, 'OTK'))
		# Read xls file tru Java & ODF toolkit
		[rawarr, ods, rstatus] = ods2jotk2oct (ods, wsh, datrange);
		
	elseif (strcmp (ods.xtype, 'JOD'))
		[rawarr, ods, rstatus] = ods2jod2oct (ods, wsh, datrange);
		
#	elseif ---- < Other interfaces here >

	else
		error (sprintf ("ods2oct: unknown OpenOffice.org .ods interface - %s.", xls.xtype));

	endif

endfunction


#=====================================================================

## Copyright (C) 2009 Philip Nienhuis <prnienhuis _at- users.sf.net>
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

## odf2jotk2oct - read ODS spreadsheet data using Java & odftoolkit
## You need proper java-for-octave & odfdom.jar + xercesImpl.jar
## in your javaclasspath.

## Author: Philip Nenhuis <pr.nienhuis at users.sf.net>
## Created: 2009-12-24
## Last update: 2010-01-05

function [ rawarr, ods, rstatus ] = ods2jotk2oct (ods, wsh=1, crange = [])

	# Parts after user gfterry in
	# http://www.oooforum.org/forum/viewtopic.phtml?t=69060
	
	rstatus = 0;

	# Get contents and table stuff from the workbook
	odfcont = ods.workbook;		# Use a local copy just to be sure. octave 
								# makes physical copies only when needed (?)
	xpath = ods.app.getXPath;
	
	# AFAICS ODS spreadsheets have the following hierarchy:
	# <table:table> - table nodes, the actual worksheets;
	# <table:table-row> - row nodes, the rows in a worksheet;
	# <table:table-cell> - cell nodes, the cells in a row;
	# Styles (formatting) are defined in a section "settings" outside the
	# contents proper but are referenced in the nodes.
	
	# Create an instance of type NODESET for use in subsequent statement
	NODESET = java_get ('javax.xml.xpath.XPathConstants', 'NODESET');
	# Parse sheets ("tables") from ODS file
	sheets = xpath.evaluate ("//table:table", odfcont, NODESET);
	nr_of_sheets = sheets.getLength ();

	# Check user input & find sheet pointer (1-based), using ugly hacks
	if (~isnumeric (wsh))
		# Search in sheet names, match sheet name to sheet number
		ii = 0;
		while (++ii <= nr_of_sheets && ischar (wsh))	
			# Look in first part of the sheet nodeset
			sh_name = sheets.item(ii-1).getTableNameAttribute ();
			if (strcmp (sh_name, wsh))
				# Convert local copy of wsh into a number (pointer)
				wsh = ii + i;
			endif
		endwhile
		if (ischar (wsh)) error (sprintf ("No worksheet '%s' found in file %s", wsh, ods.filename)); endif
	elseif (wsh > nr_of_sheets || wsh < 1)
		# We already have a numeric sheet pointer. If it's not in range:
		error (sprintf ("Worksheet no. %d out of range (1 - %d)", wsh, nr_of_sheets));
	endif

	# Get table-rows in sheet no. wsh. Sheet count = 1-based (!)
	str = sprintf ("//table:table[%d]/table:table-row", wsh);
	sh = xpath.evaluate (str, odfcont, NODESET);
	nr_of_rows = sh.getLength(); 
	# Create storage for data content. We can't know max row length yet so expect the worst
	rawarr = cell (nr_of_rows, 1024);

	# Either parse (given cell range) or prepare (unknown range) help variables 
	if (isempty (crange))
		trow = 1;				# Top row
		brow = nr_of_rows;		# Bottom row (ODS max = 65535, Xpath's guess = better)
		nrows = brow;			# Number of rows to be read
		lcol = 1;				# Leftmost column of range
		rcol = 1024;			# Rightmost columns (1024 on ODS)
		ncols = rcol;			# Number of columns to be read
	else
		[dummy, nrows, ncols, trow, lcol] = parse_sp_range (crange);
		brow = min (trow + nrows - 1, nr_of_rows);
		# Check ODS column limits
		if (lcol > 1024 || trow > 65536) error ("ods2oct: invalid range; max 1024 columns & 65536 rows."); endif
		# Truncate range silently if needed
		rcol = min (lcol + ncols - 1, 1024);
		ncols = min (ncols, 1024 - lcol + 1);
		nrows = min (nrows, 65536 - trow + 1);
	endif

	# Read from worksheet row by row. Row numbers are 0-based
	rightmcol = 0;		# Used to find actual rightmost column
	ii = trow - 1;		# Spreadsheet row counter
	rowcnt = ii;		# xpath row counter (multiple rows may be condensed in one!)
	while (++ii <= brow)
		row = sh.item(rowcnt++);
		nr_of_cells = min (row.getLength (), rcol);
		rightmcol = max (rightmcol, nr_of_cells);	# Keep track of max row length
		
		# Read column (cell, "table-cell" in ODS speak) by column
		jj = lcol; r_cols = 0;
		while (r_cols <= 1024 && jj <= rcol)
			tcell = row.getCellAt(jj-1); ++r_cols;
			if (~isempty (tcell)) 		# If empty it's possibly in columns-repeated/spanned
				if ~(index (char(tcell), 'text:p>Err:') || index (char(tcell), 'text:p>#DIV'))	

					# Get data from cell
					ctype = tcell.getOfficeValueTypeAttribute ();
					cvalue = tcell.getOfficeValueAttribute ();
					switch deblank (ctype)
						case  {'float', 'currency', 'percentage'}
							rawarr(ii, jj) = cvalue;
						case 'date'
							cvalue = tcell.getOfficeDateValueAttribute ();
							# Dates are returned as octave datenums, i.e. 0-0-0000 based
							yr = str2num (cvalue(1:4));
							mo = str2num (cvalue(6:7));
							dy = str2num (cvalue(9:10));
							if (index (cvalue, 'T'))
								hh = str2num (cvalue(12:13));
								mm = str2num (cvalue(15:16));
								ss = str2num (cvalue(18:19));
								rawarr(ii, jj) = datenum (yr, mo, dy, hh, mm, ss);
							else
								rawarr(ii, jj) = datenum (yr, mo, dy);
							endif
						case 'time'
							cvalue = tcell.getOfficeTimeValueAttribute ();
							if (index (cvalue, 'PT'))
								hh = str2num (cvalue(3:4));
								mm = str2num (cvalue(6:7));
								ss = str2num (cvalue(9:10));
								rawarr(ii, jj) = datenum (0, 0, 0, hh, mm, ss);
							endif
						case 'boolean'
							if (strcmp (deblank (cvalue), 'true'))
								rawarr(ii, jj) = true;
							else
								rawarr(ii, jj) = false;
							endif
						case 'string'
							tmp = char (tcell);
							# Get string value from between <text:p|r> </text:p|r> tags
							ist = index (tmp, '<text');
							if (ist)
								ist = ist + 8; ien = index (tmp(ist:end), '</text') + ist - 2;
								rawarr(ii, jj) = tmp(ist:ien);
							endif
						otherwise
							# Nothing
					endswitch
				endif
				# Check for repeated columns (often empty columns, viz. to right of data)
				# and add to column count
				r_cols = r_cols + tcell.getTableNumberColumnsRepeatedAttribute () - 1;
			endif
			++jj;						# Next cell
		endwhile

		# Check for repeated rows (i.e. condensed in one table-row)
		extrarows = row.getTableNumberRowsRepeatedAttribute () - 1;
		if (extrarows > 1 && (ii + extrarows) < 65535)
			# Expand rawarr cf. table-row
			nr_of_rows = nr_of_rows + extrarows;
			ii = ii + extrarows;
			nrows = min (65536, nrows + extrarows);
			brow = min (trow + nrows - 1, nr_of_rows);
			# Increase return argument size if needed
			tmp = cell (extrarows, 1024);
			rawarr = [rawarr; tmp];
		endif
		
	endwhile

	# Pre-crop rawarr from right (max was 1024) and bottom
	rawarr = rawarr (1:nr_of_rows, 1:rightmcol);

	# Crop rawarr from all empty outer rows & columns just like Excel does
	# & keep track of limits
	emptr = cellfun('isempty', rawarr);
	if (all (all (emptr)))
		rawarr = {};
		ods.limits= [];
	else
		irowt = 1;
		while (all (emptr(irowt, :))), irowt++; endwhile
		irowb = nr_of_rows;
		while (all (emptr(irowb, :))), irowb--; endwhile
		icoll = 1;
		while (all (emptr(:, icoll))), icoll++; endwhile
		icolr = rightmcol;
		while (all (emptr(:, icolr))), icolr--; endwhile
		# Crop textarray
		rawarr = rawarr(irowt:irowb, icoll:icolr);
		rstatus = 1;
		ods.limits = [lcol+icoll-1, lcol+icolr-1; trow+irowt-1, trow+irowb-1];
	endif

endfunction


#===========================================================================

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

function [ rawarr, ods, rstatus] = ods2jod2oct (ods, wsh, crange)

	persistent months;
	months = {"JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"};

	if (isempty (crange)) error ("Empty cell range not allowed w. jOpenDocument."); endif

	if (isnumeric(wsh)) wsh = max (wsh - 1, 1); endif	# Sheet COUNT starts at 0!
	sh	= ods.workbook.getSheet (wsh);
	
	[dummy, nrows, ncols, toprow, lcol] = parse_sp_range (crange);
	if (lcol > 1024 || toprow > 65536) error ("ods2oct: invalid range; max 1024 columns & 65536 rows."); endif
	# Truncate range silently if needed
	rcol = min (lcol + ncols - 1, 1024);
	ncols = min (ncols, 1024 - lcol + 1);
	nrows = min (nrows, 65536 - toprow + 1);

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
					rawarr(ii, jj) = val;
				elseif (isnumeric (val))
					# Boolean
					if (val) rawarr(ii, jj) = true; else; rawarr(ii, jj) = false; endif 
				else
					try
						val = sh.getCellAt (celladdress).getValue ().doubleValue ();
						rawarr(ii, jj) = val;
					catch
						val = char (val);
						if (isempty (val))
							# Probably empty Cell
						else
							# Maybe date / time value. Dirty hack to get values:
							mo = strmatch (toupper (val(5:7)), months);
							dd = str2num (val(9:10));
							yy = str2num (val(25:end));
							hh = str2num (val(12:13));
							mm = str2num (val(15:16));
							ss = str2num (val(18:19));
							rawarr(ii, jj) = datenum (yy, mo, dd, hh, mm,ss);
						endif
					end_try_catch
				endif
			endif
		endfor
	endfor
	
	ods.limits = [ lcol, lcol+ncols-1; toprow, toprow+nrows-1 ];
	
	rstatus = ~isempty (rawarr);

endfunction
