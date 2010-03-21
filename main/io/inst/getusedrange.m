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

## getusedrange - get used range from a spreadsheet

## Author: Philip Nienhuis <philip@JVC741>
## Created: 2010-03-18 (First usable version) for ODS (java/OTK)
## Updates:
## 2010-03-20 Added Excel support (Java/POI)

function [ trow, lrow, lcol, rcol ] = getusedrange (spptr, ii)

	if (strcmp (spptr.xtype, 'OTK'))
		[ trow, lrow, lcol, rcol ] = getusedrange_otk (spptr, ii);
	elseif (strcmp (spptr.xtype, 'JOD'))
		error ('jOpenDocument not supported yet by getusedrange'); 
#		[ trow, lrow, lcol, rcol ] = getusedrange_jod (spptr, ii);
	elseif (strcmp (spptr.xtype, 'POI'))
		[ trow, lrow, lcol, rcol ] = getusedrange_poi (spptr, ii);
	elseif (strcmp (spptr.xtype, 'JXL'))
		[ trow, lrow, lcol, rcol ] = getusedrange_jxl (spptr, ii);
	else
		error ('Only OTK, JOD, POI and JXL interface implemented');
	endif

endfunction


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
