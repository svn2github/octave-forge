## Copyright (C) 2010 Philip Nienhuis, pr.nienhuis@users.sf.net
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
## @deftypefn {Function File} [ @var{toprow#}, @var{bottomrow#}, @var{leftcol#}, @var{rightcol#} ] = getusedrange (@var{spptr}, @var{shindex#})
## Find occupied data range in worksheet @var{shindex#} in a spreadsheet
## pointed to in struct @var{spptr} (either MS-Excel or
## OpenOffice Calc).
##
## @var{shindex#} must be numeric. @var{spptr} can either refer to an
## MS-Excel spreadsheet (spptr returned by xlsopen) or an OpenOffice.org
## Calc spreadsheet (sptr returned by odsopen).
##
## Be aware that especially for OpenOffice.org Calc (ODS) spreadsheets 
## the results can only be obtained by counting all cells in all rows;
## this can be fairly time-consuming.
## The ActiveX (COM interface) doesn't allow (AFAIK) returning this info.
##
## Examples:
##
## @example
##   [trow, brow, lcol, rcol] = getusedrange (ods2, 3);
##   (which returns the outermost row & column numbers of the rectangle
##    enveloping the occupied cells in the third sheet of an OpenOffice.org
##    Calc spreadsheet pointedto in struct ods2)
## @end example
##
## @example
##   [trow, brow, lcol, rcol] = getusedrange (xls3, 3);
##   (which returns the outermost row & column numbers of the rectangle
##    enveloping the occupied cells in the third sheet of an Excel
##    spreadsheet pointed to in struct xls3)
## @end example
##
## @seealso xlsopen, xlsclose, odsopen, odsclose, xlsfinfo, odsfinfo
##
## @end deftypefn


## Author: Philip Nienhuis <philip@JVC741>
## Created: 2010-03-18 (First usable version) for ODS (java/OTK)
## Updates:
## 2010-03-20 Added Excel support (Java/POI)
## 2010-05-23 Added in support for jOpenDocument ODS
## 2010-05-31 Fixed bugs in getusedrange_jod.m

function [ trow, lrow, lcol, rcol ] = getusedrange (spptr, ii)

	if (strcmp (spptr.xtype, 'OTK'))
		[ trow, lrow, lcol, rcol ] = getusedrange_otk (spptr, ii);
	elseif (strcmp (spptr.xtype, 'JOD'))
		[ trow, lrow, lcol, rcol ] = getusedrange_jod (spptr, ii);
	elseif (strcmp (spptr.xtype, 'POI'))
		[ trow, lrow, lcol, rcol ] = getusedrange_poi (spptr, ii);
	elseif (strcmp (spptr.xtype, 'JXL'))
		[ trow, lrow, lcol, rcol ] = getusedrange_jxl (spptr, ii);
	else
		error ('Only OTK, JOD, POI and JXL interface implemented');
	endif

endfunction


## Copyright (C) 2010 Philip Nienhuis, pr.nienhuis -at- users.sf.net
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

## getusedrange_otk - get used range from ODS spreadsheet using ODF Toolkit

## Author: Philip Nienhuis <philip@JVC741>
## Created: 2010-03-18 (First usable version)
## Updates:

function [ trow, lrow, lcol, rcol ] = getusedrange_otk (ods, ii)

	odfcont = ods.workbook;		# Local copy just in case
	xpath = ods.app.getXPath;
	# Create an instance of type NODESET for use in subsequent statement
	NODESET = java_get ('javax.xml.xpath.XPathConstants', 'NODESET');

	# Get table-rows in sheet no. wsh. Sheet count = 1-based (!)
	str = sprintf ("//table:table[%d]/table:table-row", ii);
	sh = xpath.evaluate (str, odfcont, NODESET);
	nr_of_trows = sh.getLength();

	jj = 0; 										# Table row counter
	trow = 0; drows = 0; 							# Top data row, actual data row range
	nrows = 0; reprows = 0; 						# Scratch counter
	rcol = 0; lcol = 1024;							# Rightmost and leftmost data column
	while jj < nr_of_trows
		row = sh.item(jj);
		# Check for data rows
		rw_char = char (row) (1:min(500, length (char (row))));
		if (findstr ('office:value-type', rw_char))
			++drows;
			# Check for uppermost data row
			if (~trow) 
				trow = nrows + 1;
				nrows = 0;
			else
				drows = drows + reprows;
				reprows = 0;
			endif

			# Get leftmost cell column number
			lcell = row.getFirstChild ();
			cl_char = char (lcell);
			if isempty (findstr ('office:value-type', cl_char))
				lcol = min (lcol, lcell.getTableNumberColumnsRepeatedAttribute () + 1);
			else
				lcol = 1;
			endif
			
			# if rcol is already 1024 no more exploring for rightmost column is needed
			if ~(rcol == 1024)
				# Get rightmost cell column number by counting....
				rc = 0;
				for kk=1:row.getLength()
					lcell = row.item(kk - 1);
					rc = rc + lcell.getTableNumberColumnsRepeatedAttribute ();
				endfor
				# Watch out for filler tablecells
				if isempty (findstr ('office:value-type', char (lcell)))
					rc = rc - lcell.getTableNumberColumnsRepeatedAttribute ();
				endif
				rcol = max (rcol, rc);
			endif
		else
			# Check for repeated tablerows
			nrows = nrows + row.getTableNumberRowsRepeatedAttribute ();
			if (trow)
				reprows = reprows + row.getTableNumberRowsRepeatedAttribute ();
			endif
		endif
		++jj;
	endwhile

	if (trow)
		lrow = trow + drows - 1;
	else
		# Empty sheet
		lrow = 0; lcol = 0; rcol = 0;
	endif
	
endfunction

## Copyright (C) 2010 Philip Nienhuis <prnienhuis -aT- users.sf.net>
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

## getusedrange_jod

## Author: Philip <Philip@DESKPRN>
## Created: 2010-05-25
## Last updates:
## 2010-05-31 Fixed ignoring table-covered-cells; fixed count of sheets comprising just A1:A1
##            Added option for wsh being a string argument 

function [ trow, brow, lcol, rcol ] = getusedrange_jod (ods, wsh)

	# This function works by virtue of sheets in JOD actually being a Java string.
	# It works outside of the Java memory/heap space which is an added benefit.

	if (isnumeric (wsh))
		sh = char (ods.workbook.getSheet (wsh - 1));
	else
		sh = char (ods.workbook.getSheet (wsh));
	endif

	# Get table-row pointers
	id_trow = strfind (sh, '<table:table-row');
	id = strfind (sh, '</table:table>') - 1;
	id_trow = [id_trow id];

#	brow = length (id_trow) - 1;
	trow = rcol = 0;
	lcol = 1024; brow = 0;
	if (~isempty (id))
		# Loop over all table-rows
		rowrepcnt = 0;
		for irow = 1:length (id_trow)-1
			# Isolate single table-row
			tablerow = sh(id_trow(irow):id_trow(irow+1)-1);
			# Search table-cells. table-c covers both table-cell & table-covered-cell
			id_tcell = strfind (tablerow, '<table:table-c'); 
			id_tcell = [id_tcell id];
			rowl = length (tablerow);
			if (isempty (id_tcell(1:end-1)))
				rowend = rowl;
			else
				rowend = id_tcell(1);
			endif
			# Add in table-number-rows-repeated attribute values
			rowrept = strfind (tablerow(1:rowend), 'number-rows-repeated');
			if (~isempty (rowrept))
				[st, en] = regexp (tablerow(rowrept:min (rowend, rowrept+30)), '\d+');
				rowrepcnt += str2num (rowrept+st-1:min (rowend, rowrept+en-1)) - 1;
			endif

			# Search table-cells. table-c is a table-covered-cell that is considered empty
			id_tcell = strfind (tablerow, '<table:table-c');
			if (~isempty (id_tcell))
				# OK, this row has a value cell. Now table-covered-cells must be included.
				id_tcell2 = strfind (tablerow, '<table:covered-t');
				if (~isempty (id_tcell2)) id_tcell = sort ([id_tcell id_tcell2]); endif
				id_tcell = [id_tcell rowl];
				# Search for non-empty cells (i.e., with an office:value-type)
				id_valtcell = strfind (tablerow, 'office:value-type=');
				id_valtcell = [id_valtcell rowl];
				if (~isempty (id_valtcell(1:end-1)))
					brow = irow + rowrepcnt;
					# First set trow if it hadn't already been found
					if (~trow) trow = irow; endif
					# Search for repeated table-cells
					id_reptcell = strfind (tablerow, 'number-columns-repeated');
					id_reptcell = [id_reptcell rowl];
					# Search for leftmost non-empty table-cell. llcol = counter for this table-row
					llcol = 1;
					while (id_tcell (llcol) < id_valtcell(1) && llcol <= length (id_tcell) - 1)
						++llcol;
					endwhile
					--llcol;
					# Compensate for repeated cells. First count all repeats left of llcol
					ii = 1;
					repcnt = 0;
					if (~isempty (id_reptcell(1:end-1)))
						# First try lcol
						while (ii <= length (id_reptcell) - 1 && id_reptcell(ii) < id_valtcell(1))
							# Add all repeat counts left of leftmost data tcell minus 1 for each
							[st, en] = regexp (tablerow(id_reptcell(ii):id_reptcell(ii)+30), '\d+');
							repcnt += str2num (tablerow(id_reptcell(ii)+st-1:id_reptcell(ii)+en-1)) - 1;
							++ii;
						endwhile
						# Next, add current repcnt value to llcol and update lcol
						lcol = min (lcol, llcol + repcnt);
						# Get last value table-cell in table-cell idx
						jj = 1;
						while (id_tcell (jj) < id_valtcell(length (id_valtcell)-1))
							++jj;
						endwhile

						# Get rest of column repeat counts in value table-cell range
						while (ii < length (id_reptcell) && id_reptcell(ii) < id_tcell(jj))
							# Add all repeat counts minus 1 for each tcell in value tcell range
							[st, en] = regexp (tablerow(id_reptcell(ii):id_reptcell(ii)+30), '\d+');
							repcnt += str2num (tablerow(id_reptcell(ii)+st-1:id_reptcell(ii)+en-1)) - 1;
							++ii;
						endwhile
					else
						# In case left column = A
						lcol = min (lcol, llcol);
					endif
					# Count all table-cells in value table-cell-range
					ii = 1; 			# Indexes cannot be negative
					while (ii < length (id_tcell) && id_tcell(ii) < id_valtcell(length (id_valtcell) - 1))
						++ii;
					endwhile
					--ii;
					rcol = max (rcol, ii + repcnt);
				endif
			endif
		endfor
	else
		# No data found, empty sheet
		lcol = rcol = brow = trow = 0;
	endif

endfunction


## Copyright (C) 2010 Philip Nienhuis, prnienhuis at users.sf.net
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

## getusedrange_poi - get range of occupied data cells from Excel using java/POI

## Author: Philip <Philip@DESKPRN>
## Created: 2010-03-20

function [ trow, brow, lcol, rcol ] = getusedrange_poi (xls, ii)

	persistent cblnk; cblnk = java_get ('org.apache.poi.ss.usermodel.Cell', 'CELL_TYPE_BLANK');

	sh = xls.workbook.getSheetAt (ii-1);         # Java POI starts counting at 0 

	trow = sh.getFirstRowNum ();
	brow = sh.getLastRowNum ();
	# Get column range
	lcol = 1048577;  # OOXML (xlsx) max. + 1
	rcol = 0;
	botrow = brow;
	for jj=trow:brow
		irow = sh.getRow (jj);
		if (~isempty (irow))
			scol = (irow.getFirstCellNum).intValue ();
			lcol = min (lcol, scol);
			ecol = (irow.getLastCellNum).intValue () - 1;
			rcol = max (rcol, ecol);
			# Keep track of lowermost non-empty row as getLastRowNum() is unreliable
			if ~(irow.getCell(scol).getCellType () == cblnk && irow.getCell(ecol).getCellType () == cblnk)
				botrow = jj;
			endif
		endif
	endfor
	if (lcol > 1048576)
		# Empty sheet
		trow = 0; brow = 0; lcol = 0; rcol = 0;
	else
		brow = min (brow, botrow) + 1; ++trow; ++lcol; ++rcol;
	endif

endfunction


## Copyright (C) 2010 Philip Nienhuis, prnienhuis at users.sf.net
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

## getusedrange_jxl - get occupied data cell range from Excel sheet
## using java/JExcelAPI

## Author: Philip <Philip@DESKPRN>
## Created: 2010-03-20

function [ trow, brow, lcol, rcol ] = getusedrange_jxl (xls, wsh)

	persistent emptycell = (java_get ('jxl.CellType', 'EMPTY')).toString ();

	sh = xls.workbook.getSheet (wsh - 1);			# POI sheet count 0-based

	brow = sh.getRows ();
	rcol = sh.getColumns ();
	
	if (brow == 0 || rcol == 0)
		# Empty sheet
		trow = 0; lcol = 0;
	else
		trow = brow + 1;
		lcol = rcol + 1;
		for ii=0:brow-1		# For loop coz we must check ALL rows for leftmost column
			emptyrow = 1;
			jj = 0;
			while (jj < rcol && emptyrow)   # While loop => only til first non-empty cell
				cell = sh.getCell (jj, ii);
				if ~(strcmp (char (cell.getType ()), emptycell))
					lcol = min (lcol, jj + 1);
					emptyrow = 0;
				endif
				++jj;
			endwhile
			if ~(emptyrow) trow = min (trow, ii + 1); endif
		endfor
	endif

endfunction
