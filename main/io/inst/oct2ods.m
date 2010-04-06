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
## @deftypefn {Function File} [ @var{ods}, @var{rstatus} ] = oct2ods (@var{arr}, @var{ods})
## @deftypefnx {Function File} [ @var{ods}, @var{rstatus} ] = oct2ods (@var{arr}, @var{ods}, @var{wsh})
## @deftypefnx {Function File} [ @var{ods}, @var{rstatus} ] = oct2ods (@var{arr}, @var{ods}, @var{wsh}, @var{range})
##
## Transfer data to an OpenOffice_org Calc spreadsheet previously opened
## by odsopen().
##
## Data in 1D/2D array @var{arr} are transferred into a cell range
## @var{range} in sheet @var{wsh}. @var{ods} must have been made earlier
## by odsopen(). Return argument @var{ods} should be the same as supplied
## argument @var{ods} and is updated by oct2ods. A subsequent call to
## odsclose is needed to write the updated spreadsheet to disk (and
## -if needed- close the Java invocation holding the file pointer).
##
## @var{arr} can be any array type save complex. Mixed numeric/text arrays
## can only be cell arrays.
##
## @var{ods} must be a valid pointer struct created earlier by odsopen.
##
## @var{wsh} can be a number or string.
## In case of a yet non-existing Calc file, the first sheet will be
## used & named according to @var{wsh}.
## In case of existing files, some checks are made for existing sheet
## names or numbers.
## When new sheets are to be added to the Calc file, they are
## inserted to the right of all existing sheets. The pointer to the
## "active" sheet (shown when Calc opens the file) remains untouched.
##
## If omitted, @var{range} is initially supposed to be 'A1:AMJ65536'.
## The actual range to be used is determined by the size of @var{arr}.
## Be aware that data array sizes > 2.10^5 elements may exhaust the
## java shared memory space for the default java memory settings.
## For larger arrays appropriate memory settings are needed in the file
## java.opts; then the maximum array size for the java-based spreadsheet
## options is about 5-6.10^5 elements.
##
## Data are added to the sheet, ignoring other data already present;
## existing data in the range to be used will be overwritten.
##
## If @var{range} contains merged cells, also the elements of @var{arr}
## not corresponding to the top or left Calc cells of those merged cells
## will be written, however they won't be shown until in Calc the merge is
## undone.
##
## Examples:
##
## @example
##   [ods, status] = ods2oct ('arr', ods, 'Newsheet1', 'AA31:GH165');
## @end example
##
## @seealso ods2oct, odsopen, odsclose, odsread, odswrite, odsfinfo
##
## @end deftypefn

## Author: Philip Nienhuis
## Created: 2009-12-13
## Updates:
## 2010-01-15 Updated texinfo header
## 2010-03-14 Updated help text (a.o. on java memory usage)
## 2010-03-25 see oct2jotk2ods
## 2010-03-28 Added basic support for ofdom v.0.8. Everything works except adding cols/rows
## 2010-03-29 Removed odfdom-0.8 support, it's simply too buggy :-( Added a warning instead

function [ ods, rstatus ] = oct2ods (c_arr, ods, wsh=1, crange=[])

	if (strcmp (ods.xtype, 'OTK'))
		# Write ods file tru Java & ODF toolkit.
		# Get odf toolkit .jar version. Versions 0.7.5. & 0.8 have a different API...
		versn = java_invoke ('org.odftoolkit.odfdom.Version', 'getApplicationVersion');
		# Each odfdom version has a different subfunction to avoid performance issues
		# due to many "if .... else .... endif" statements
		if (strcmp (versn, '0.7.5'))
			# ... and only odfdom version 0.7.5. works sufficiently reliably.
			[ ods, rstatus ] = oct2jotk2ods (c_arr, ods, wsh, crange);
		elseif (strcmp (versn, '0.8'))
			# 2010-03-28 ... while odfdom-0.8 is still too buggy to use :-(
			printf ("Writing ODS not supported using odfdom 0.8 - please use odfdom 0.7.5\n");
			printf ("Nothing done..\n");
			# Below call & subfunction only included for reference. It works badly....
#			[ ods, rstatus ] = oct3jotk2ods (c_arr, ods, wsh, crange);
		else
			error ('Unsupported ODF Toolkit version - only odfdom 0.7.5 works for writing ODS');
		endif
		
	elseif (strcmp (ods.xtype, 'JOD'))
		# Write ods file tru Java & jOpenDocument. API still leaves lots to be wished...
		warning ("oct2ods: unreliable writing tru jOpenDocument interface.");
		[ ods, rstatus ] = oct2jod2ods (c_arr, ods, wsh, crange);
		
#	elseif ---- < Other interfaces here >

	else
		error (sprintf ("ods2oct: unknown OpenOffice.org .ods interface - %s.", ods.xtype));

	endif

endfunction


#=============================================================================

## Copyright (C) 2010 Philip Nienhuis <prnienhuis@users.sf.net>
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

## oct2jotk2ods
## write data array to an ODS spreadsheet using Java & ODFtoolkit

## I'm truly sorry that oct2jotk2ods is so ridiculously complex,
## and therefore so slow; but there's a good reason for that:
## Writing to ODS is already fairly complicated when just making a
## new sheet ("table"); but it really becomes a headache when
## writing to an existing sheet. In that case one should beware of
## table-number-columns-repeated, table-number-rows-repeated,
## covered (merged) cells, incomplete tables and rows, etc.
## ODF toolkit does nothing to hide this from the user; you may
## sort it out all by yourself.

## Author: Philip Nienhuis <prnienhuis@users.sf.net>
## Created: 2010-01-07
## Updates: 
## 2010-01-14 (finally seems to work OK)
## 2010-03-08 Some comment lines adapted
## 2010-03-25 Try-catch added f unpatched-for-booleans java-1.2.6 / 1.2.7 package

function [ ods, rstatus ] = oct2jotk2ods (c_arr, ods, wsh=1, crange=[])

	persistent ctype;
	if (isempty (ctype))
		# Number, String, Boolean, Date, Time, Empty
		ctype = [1, 2, 3, 4, 5, 6];
	endif

	rstatus = 0; changed = 0;

	# ODS' current row and column capacity
	ROW_CAP = 65536; COL_CAP = 1024;

	if (isnumeric (c_arr))
		c_arr = num2cell (c_arr);
	elseif (~iscell (c_arr))
		error ("oct2ods: input array neither cell nor numeric array");
	endif

	# Get some basic spreadsheet data from the pointer using ODFtoolkit
	odfcont = ods.workbook;
	xpath = ods.app.getXPath ();
	offsprdsh = ods.app.getContentRoot();
	autostyles = odfcont.getOrCreateAutomaticStyles();
	officestyles = ods.app.getOrCreateDocumentStyles();

	# Create an instance of type NODESET for use in subsequent statements
	NODESET = java_get ('javax.xml.xpath.XPathConstants', 'NODESET');

# Check user input & find sheet pointer (1-based)

	# Parse sheets ("tables") from ODS file
	sheets = xpath.evaluate ("//table:table", odfcont, NODESET);
	nr_of_sheets = sheets.getLength ();
	newsh = 0;								# Assume existing sheet

	if (~isnumeric (wsh))					# Sheet name specified
		# Search in sheet names, match sheet name to sheet number.
		# Beware, 0-based index, 1-based count!
		ii = 0;
		while (++ii <= nr_of_sheets && ischar (wsh))	
			# Look in first part of the sheet nodeset
			sh_name = sheets.item(ii-1).getTableNameAttribute ();
			if (strcmp (sh_name, wsh))
				# Convert local copy of wsh into a number (pointer)
				wsh = ii - 1;
			endif
		endwhile
		if (ischar (wsh) && nr_of_sheets < 256) newsh = 1; endif
	else										# Sheet index specified
		if (wsh > nr_of_sheets && wsh < 256)	# Max nr of sheets = 256
			# Create a new sheet
			newsh = 1;
		elseif (wsh <=nr_of_sheets && wsh > 0)
			# Existing sheet. Count = 1-based, index = 0-based
			--wsh; sh = sheets.item(wsh);
			printf ("Writing to sheet %s\n", sh.getTableNameAttribute());
		else
			error ("oct2ods: illegal sheet number.");
		endif
	endif

# Check size of data array & range / capacity of worksheet & prepare vars

	[nr, nc] = size (c_arr);
	if (isempty (crange))
		trow = 0;
		lcol = 0;
		nrows = nr;
		ncols = nc;
	else
		[dummy, nrows, ncols, trow, lcol] = parse_sp_range (crange);
		# Row/col = 0 based in ODFtoolkit
		trow = trow - 1; lcol = lcol - 1;
	endif
	if (trow > ROW_CAP || lcol > COL_CAP)
		celladd = calccelladdress (lcol, trow, 1, 1);
		error (sprintf ("Topleft cell (%s) beyond spreadsheet limits (AMJ65536).", celladd));
	endif
	# Check spreadsheet capacity beyond requested topleft cell
	nrows = min (nrows, ROW_CAP - trow + 1);
	ncols = min (ncols, COL_CAP - lcol + 1);
	# Check array size and requested range
	nrows = min (nrows, nr);
	ncols = min (ncols, nc);
	if (nrows < nr || ncols < nc) warning ("Array truncated to fit in range"); endif
	
# Parse data array, setup typarr and throw out NaNs  to speed up writing;
# 			1Number, 2String, 3Boolean, 4Date, 5Time, 0Empty

	typearr = ones (nrows, ncols);					# type "NUMERIC", provisionally
	obj2 = cell (size (c_arr));						# Temporary storage for strings

	txtptr = cellfun ('isclass', c_arr, 'char');	# type "STRING" replaced by "NUMERIC"
	obj2(txtptr) = c_arr(txtptr); c_arr(txtptr) = 2;# Save strings in a safe place

	emptr = cellfun ("isempty", c_arr);
	c_arr(emptr) = 0;								# Set empty cells to NUMERIC

	lptr = cellfun ("islogical" , c_arr);			# Find logicals...
	obj2(lptr) = c_arr(lptr);						# .. and set them to BOOLEAN

	ptr = cellfun ("isnan", c_arr);					# Find NaNs & set to BLANK
	typearr(ptr) = 0; 								# All other cells are now numeric

	c_arr(txtptr) = obj2(txtptr);					# Copy strings back into place
	c_arr(lptr) = obj2(lptr);
	typearr(txtptr) = 2;							# ...and clean up 
	typearr(emptr) = 0;
	typearr(lptr) = 3;								# BOOLEAN

# Prepare worksheet for writing. If needed create new sheet

	if (newsh)
		# Create a new sheet. First the basics
		sh = java_new ('org.odftoolkit.odfdom.doc.table.OdfTable', odfcont);
		changed = 1;
		# Append sheet to spreadsheet ( contentRoot)
		offsprdsh.appendChild (sh);
		# Rebuild sheets nodes
		sheets = xpath.evaluate ("//table:table", odfcont, NODESET);
		if (isnumeric (wsh))
			# Give sheet a name
			str = sprintf ("Sheet%d", wsh);
			sh.setTableNameAttribute (str);
		else
			# Assign name to sheet and change wsh into numeric pointer
			sh.setTableNameAttribute (wsh);
			wsh = sheets.getLength () - 1;
		endif
		# Add table-column entry for style etc
		col = sh.addTableColumn ();
		col.setTableDefaultCellStyleNameAttribute ("Default");
		col.setTableNumberColumnsRepeatedAttribute (lcol + ncols + 1);
		col.setTableStyleNameAttribute ("co1");

	# Build up the complete row & cell structure to cover the data array
	# This will speed up processing later

		# 1. Build empty table row template
		row = java_new ('org.odftoolkit.odfdom.doc.table.OdfTableRow', odfcont);
		# Create an empty tablecell & append it to the row
		cell = java_new ('org.odftoolkit.odfdom.doc.table.OdfTableCell', odfcont);
		cell = row.appendCell (cell);
		cell.setTableNumberColumnsRepeatedAttribute (1024);
		# 2. If needed add empty filler row above the data rows & if needed add repeat count
		if (trow > 0)				
			sh.appendRow (row);
			if (trow > 1) row.setTableNumberRowsRepeatedAttribute (trow); endif
		endif
		# 3. Add data rows; first one serves as a template
		drow = java_new ('org.odftoolkit.odfdom.doc.table.OdfTableRow', odfcont);
		if (lcol > 0) 
			cell = java_new ('org.odftoolkit.odfdom.doc.table.OdfTableCell', odfcont);
			cell = drow.appendCell (cell);
			if (lcol > 1) cell.setTableNumberColumnsRepeatedAttribute (lcol); endif
		endif
		# 4. Add data cell placeholders
		cell = java_new ('org.odftoolkit.odfdom.doc.table.OdfTableCell', odfcont);
		drow.appendCell (cell);
		for jj=2:ncols
			dcell = cell.cloneNode (1);		# Deep copy
			drow.appendCell (dcell);
		endfor
		# 5. Last cell is remaining column counter
		rest = max (1024 - lcol - ncols);
		if (rest)
			dcell = cell.cloneNode (1);		# Deep copy
			drow.appendCell (dcell);
			if (rest > 1) dcell.setTableNumberColumnsRepeatedAttribute (rest); endif
		endif
		# Only now add drow as otherwise for each cell an empty table-column is
		# inserted above the rows (odftoolkit bug?)
		sh.appendRow (drow);
		# 6. Row template ready. Copy row template down to cover future array
		for ii=2:nrows
			nrow = drow.cloneNode (1);	# Deep copy
			sh.appendRow (nrow);
		endfor

	else
		# Existing sheet. We must be prepared for all situations, incomplete rows,
		# number-rows/columns-repeated, merged (spanning) cells, you name it.
		# First explore row buildup of existing sheet using an XPath
		sh = sheets.item(wsh);											# 0 - based
		str = sprintf ("//table:table[%d]/table:table-row", wsh + 1);	# 1 - based 
		trows = xpath.evaluate (str, odfcont, NODESET);
		nr_of_trows = trows.getLength(); 	# Nr. of existing table-rows, not data rows!

		# For the first rows we do some preprocessing here. Similar stuff for cells
		# i.e. table-cells (columns) is done in the loops below.
		# Make sure the upper data array row doesn't end up in a nr-rows-repeated row

		# Provisionally! set start table-row in case "while" & "if" (split) are skipped
		drow = trows.item(0);	
		rowcnt = 0; trowcnt = 0;					# Spreadsheet/ table-rows, resp;
		while (rowcnt < trow && trowcnt < nr_of_trows)
			++trowcnt;								# Nr of table-rows
			row = drow;
			drow = row.getNextSibling ();
			repcnt = row.getTableNumberRowsRepeatedAttribute();
			rowcnt = rowcnt + repcnt;				# Nr of spreadsheet rows
		endwhile
		rsplit = rowcnt - trow;
		if (rsplit > 0)
			# Apparently a nr-rows-repeated top table-row must be split, as the
			# first data row seems to be projected in it.
			row.removeAttribute ('table:number-rows-repeated');
			changed = 1;
			row.getCellAt (0).removeAttribute ('table:number-columns-repeated');
			nrow = row.cloneNode (1);
			drow = nrow;							# Future upper data array row
			if (repcnt > 1)
				row.setTableNumberRowsRepeatedAttribute (repcnt - rsplit);
			else
				row.removeAttribute ('table:number-rows-repeated');
			endif
			rrow = row.getNextSibling ();
			sh.insertBefore (nrow, rrow);
			for jj=2:rsplit
				nrow = nrow.cloneNode (1);
				sh.insertBefore (nrow, rrow);
			endfor
		elseif (rsplit < 0)
			# New data rows to be added below existing data & table(!) rows, i.e.
			# beyond lower end of the current sheet. Add filler row and 1st data row
			row = java_new ('org.odftoolkit.odfdom.doc.table.OdfTableRow', odfcont);
			drow = row.cloneNode (1);								# First data row
			row.setTableNumberRowsRepeatedAttribute (-rsplit);		# Filler row
			cell = java_new ('org.odftoolkit.odfdom.doc.table.OdfTableCell', odfcont);
			dcell = cell.cloneNode (1);
			cell.setTableNumberColumnsRepeatedAttribute (COL_CAP);	# Filler cell
			row.appendCell (cell);
			sh.appendRow (row);
			drow.appendCell (dcell);
			sh.appendRow (drow);
			changed = 1;
		endif
	endif

# For each row, for each cell, add the data. Expand row/column-repeated nodes

	row = drow;			# Start row; pointer still exists from above stanzas
	for ii=1:nrows
		if (~newsh)
			# While processing next data rows, fix table-rows if needed
			if (isempty (row) || (row.getLength () < 1))
				# Append an empty row with just one empty cell
				row = java_new ('org.odftoolkit.odfdom.doc.table.OdfTableRow', odfcont);
				cell = java_new ('org.odftoolkit.odfdom.doc.table.OdfTableCell', odfcont);
				cell.setTableNumberColumnsRepeatedAttribute (lcol + 1);
				row.appendCell (cell);
				sh.appendRow (row);
				changed = 1;
			else
				# If needed expand nr-rows-repeated
				repcnt = row.getTableNumberRowsRepeatedAttribute ();
				if (repcnt > 1)
					row.removeAttribute ('table:number-rows-repeated');
					changed = 1;
					for kk=2:repcnt
						nrow = row.cloneNode (1);
						sh.insertBefore (nrow, row.getNextSibling ());
					endfor
				endif
			endif

			# Check if leftmost cell ends up in nr-cols-repeated cell
			colcnt = 0; tcellcnt = 0; rcellcnt = row.getLength();
			dcell = row.getCellAt (0);
			while (colcnt < lcol && tcellcnt < rcellcnt)
				++tcellcnt;						# Nr of table-cells counted
				cell = dcell;
				dcell = cell.getNextSibling ();
				repcnt = cell.getTableNumberColumnsRepeatedAttribute ();
				colcnt = colcnt + repcnt;		# Nr of spreadsheet cell counted
			endwhile
			csplit = colcnt - lcol;
			if (csplit > 0)
				# Apparently a nr-columns-repeated cell must be split
				cell.removeAttribute ('table:number-columns-repeated');
				changed = 1;
				ncell = cell.cloneNode (1);
	#			dcell = ncell;				# Future left data array column
				if (repcnt > 1)
					cell.setTableNumberColumnsRepeatedAttribute (repcnt - csplit);
				else
					cell.removeAttribute ('table:number-columns-repeated');
				endif
				rcell = cell.getNextSibling ();
				row.insertBefore (ncell, rcell);
				for jj=2:csplit
					ncell = ncell.cloneNode (1);
					row.insertBefore (ncell, rcell);
				endfor
			elseif (csplit < 0)
				# New cells to be added beyond current last cell & table-cell in row
				dcell = java_new ('org.odftoolkit.odfdom.doc.table.OdfTableCell', odfcont);
				cell = cell.cloneNode (1);
				dcell.setTableNumberColumnsRepeatedAttribute (-csplit);
				row.appendCell (dcell);
				changed = 1;
				drow.appendCell (cell);
			endif
		endif

	# Write a row of data from data array, column by column
	
		for jj=1:ncols
			cell = row.getCellAt (lcol + jj - 1);
			if (~newsh)
				if (isempty (cell))
					# Apparently end of row encountered. Add cell
					cell = java_new ('org.odftoolkit.odfdom.doc.table.OdfTableCell', odfcont);
					cell = row.appendCell (cell);
					changed = 1;
				else
					# If needed expand nr-cols-repeated
					repcnt = cell.getTableNumberColumnsRepeatedAttribute ();
					if (repcnt > 1)
						cell.removeAttribute ('table:number-columns-repeated');
						changed = 1;
						for kk=2:repcnt
							ncell = cell.cloneNode (1);
							row.insertBefore (ncell, cell.getNextSibling ());
						endfor
					endif
				endif
				# Clear text contents
				while (cell.hasChildNodes ())
					tmp = cell.getFirstChild ();
					cell.removeChild (tmp);
					changed = 1;
				endwhile
			endif
			# Empty cell count stuff done. At last we can add the data
			switch (typearr (ii, jj))
				case 1	# float
					cell.setOfficeValueTypeAttribute ('float');
					cell.setOfficeValueAttribute (c_arr{ii, jj});
				case 2	# string
					cell.setOfficeValueTypeAttribute ('string');
					pe = java_new ('org.odftoolkit.odfdom.doc.text.OdfTextParagraph', odfcont,'', c_arr{ii, jj});
					cell.appendChild (pe);
				case 3		# boolean
					# Beware, for unpatched-for-booleans java-1.2.7 we must resort to floats
					try
						# First try the preferred java-boolean way
						cell.setOfficeValueTypeAttribute ('boolean');
						cell.removeAttribute ('office:value');
						if (c_arr{ii, jj})
							cell.setOfficeBooleanValueAttribute (1);
						else
							cell.setOfficeBooleanValueAttribute (0);
						endif
					catch
						# Unpatched java package. Fall back to transferring a float
						cell.setOfficeValueTypeAttribute ('float');
						if (c_arr{ii, jj})
							cell.setOfficeValueAttribute (1);
						else
							cell.setOfficeValueAttribute (0);
						endif
					end_try_catch
				case 4	# Date (implemented but Octave has no "date" data type - yet?)
					cell.setOfficeValueTypeAttribute ('date');
					[hh mo dd hh mi ss] = datevec (c_arr{ii,jj});
					str = sprintf ("%4d-%2d-%2dT%2d:%2d:%2d", yy, mo, dd, hh, mi, ss);
					cell.setOfficeDateValueAttribute (str);
				case 5	# Time (implemented but Octave has no "time" data type)
					cell.setOfficeValueTypeAttribute ('time');
					[hh mo dd hh mi ss] = datevec (c_arr{ii,jj});
					str = sprintf ("PT%2d:%2d:%2d", hh, mi, ss);
					cell.setOfficeTimeValuettribute (str);
				case 0	# Empty. Clear value attributes
					if (~newsh)
						cell.removeAttribute ('office:value-type');
						cell.removeAttribute ('office:value');
					endif
				otherwise
					# Nothing
			endswitch
			changed = 1;

			cell = cell.getNextSibling ();

		endfor

		row = row.getNextSibling ();

	endfor

	if (changed)	
		ods.changed = 1;
		rstatus = 1;
	endif
	
endfunction


#=============================================================================

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

## odf3jotk2oct - read ODS spreadsheet data using Java & odftoolkit v 0-8.
## You need proper java-for-octave & odfdom.jar 0.8 + xercesImpl.jar
## in your javaclasspath. For reliable writing odfdom-0.8 is still
## too buggy :-(  Please use 0.7.5
##
## Author: Philip Nenhuis <pr.nienhuis at users.sf.net>
## Created: 2010-03-16, after oct2jotk2ods()
## Updates:
## 2010-03-17 Rebuild for odfdom-0.8
## 2010-03-19 Showstopper bug in odfdom-0.8 - getCellByPosition(<address>)
##            crashes on rows #10 !!! Rest seems to work OK, however
## 2010-03-22 First somewhat usable version for odfdom 0.8
## 2010-03-29 Gave up. Writing a new empty sheet works, appending
##            data to an existing one can crash virtually anywhere.
##            The wait is for odfdom-0.8.+ ....
##            Included only for reference (who knows, someone may know
##            how to get it working properly

function [ ods, rstatus ] = oct3jotk2ods (c_arr, ods, wsh=1, crange=[])

	persistent ctype;
	if (isempty (ctype))
		# Number, String, Boolean, Date, Time, Empty
		ctype = [1, 2, 3, 4, 5, 6];
	endif

	rstatus = 0; changed = 0; newsh = 0;

	# ODS' current row and column capacity
	ROW_CAP = 65536; COL_CAP = 1024;

	if (isnumeric (c_arr))
		c_arr = num2cell (c_arr);
	elseif (~iscell (c_arr))
		error ("oct2ods: input array neither cell nor numeric array");
	endif

	# Get contents and table stuff from the workbook
	odfcont = ods.workbook;		# Use a local copy just to be sure. octave 
								# makes physical copies only when needed (?)
	odfroot = odfcont.getRootElement ();
	offsprdsh = ods.app.getContentRoot();
	xpath = ods.app.getXPath ();
	# Get some basic spreadsheet data from the pointer using ODFtoolkit
	autostyles = odfcont.getOrCreateAutomaticStyles();
	officestyles = ods.app.getOrCreateDocumentStyles();
	# Create an instance of type NODESET for use in subsequent statement
	NODESET = java_get ('javax.xml.xpath.XPathConstants', 'NODESET');
	# Parse sheets ("tables") from ODS file
	sheets = xpath.evaluate ("//table:table", odfcont, NODESET);
	nr_of_sheets = sheets.getLength ();

	# Check user input & find sheet pointer
	if (~isnumeric (wsh))
		try
			sh = ods.app.getTableByName (wsh);
			# We do need a sheet index number...
			ii = 0;
			while (ischar (wsh) && ii < nr_of_sheets) 
				sh_nm = sheets.item(ii).getTableNameAttribute ();
				if (strcmp (sh_nm, wsh)) wsh = ii + 1; else ++ii; endif
			endwhile
		catch
			newsh = 1;
		end_try_catch
		if isempty (sh) newsh = 1; endif
	elseif (wsh > nr_of_sheets + 1 || wsh < 1)
		# We already have a numeric sheet pointer. If it's not in range:
		error (sprintf ("Worksheet no. %d out of range (1 - %d)", wsh, nr_of_sheets));
	elseif (wsh == nr_of_sheets + 1)
		newsh = 1;
	else
		sh = sheets.item(wsh - 1);
		sh = ods.app.getTableByName (sh.getTableNameAttribute ());
	endif

	# Get nr of row & columns to be read
	[nr, nc] = size (c_arr);
	# Either parse (given cell range) or prepare (unknown range) help variables 
	if (isempty (crange))
		trow = 0;
		lcol = 0;
		nrows = nr;
		ncols = nc;
	else
		[dummy, nrows, ncols, trow, lcol] = parse_sp_range (crange);
		# Row/col = 0 based in ODFtoolkit
		trow = trow - 1; lcol = lcol - 1;
	endif
	# Check if requested range is wholly within spreadsheet size limits at all
	if (trow > ROW_CAP || lcol > COL_CAP)
		celladd = calccelladdress (lcol, trow, 1, 1);
		error (sprintf ("Requested topleft cell (%s) beyond spreadsheet limits (AMJ65536).", celladd));
	endif
	# Check spreadsheet capacity beyond requested topleft cell
	nrows = min (nrows, ROW_CAP - trow + 1);
	ncols = min (ncols, COL_CAP - lcol + 1);
	# Check array size and requested range
	nrows = min (nrows, nr);
	ncols = min (ncols, nc);
	if (nrows < nr || ncols < nc) warning ("Array truncated to fit in range"); endif

# Parse data array, setup typarr and throw out NaNs  to speed up writing;
# 			1Number, 2String, 3Boolean, 4Date, 5Time, 0Empty

	typearr = ones (nrows, ncols);					# type "NUMERIC", provisionally
	obj2 = cell (size (c_arr));						# Temporary storage for strings

	txtptr = cellfun ('isclass', c_arr, 'char');	# type "STRING" replaced by "NUMERIC"
	obj2(txtptr) = c_arr(txtptr); c_arr(txtptr) = 2; # Save strings in a safe place

	emptr = cellfun ("isempty", c_arr);
	c_arr(emptr) = 0;								# Set empty cells to NUMERIC

	lptr = cellfun ("islogical" , c_arr);			# Find logicals...
	obj2(lptr) = c_arr(lptr);						# .. and set them to BOOLEAN

	ptr = cellfun ("isnan", c_arr);					# Find NaNs & set to BLANK
	typearr(ptr) = 6; 								# All other cells are now numeric

	c_arr(txtptr) = obj2(txtptr);					# Copy strings back into place
	c_arr(lptr) = obj2(lptr);
	typearr(txtptr) = 2;							# ...and clean up 
	typearr(emptr) = 0;
	typearr(lptr) = 3;								# BOOLEAN

# Prepare spreadsheet for writing (size, etc.). If needed create new sheet
	if (newsh)
		# Create a new sheet using DOM API. This part works OK.
		sh = offsprdsh.newTableTableElement ();
		changed = 1;
		# Rebuild sheet nodes xpath
		sheets = xpath.evaluate ("//table:table", odfcont, NODESET);
		if (isnumeric (wsh))
			# Give sheet a name
			str = sprintf ("Sheet%d", wsh);
			sh.setTableNameAttribute (str);
			wsh = str;
		else
			# Assign name to sheet and change wsh into numeric pointer
			sh.setTableNameAttribute (wsh);
		endif
		printf ("Sheet %s added to spreadsheet.\n", wsh);
		# Add columns & style (but styles don't work properly yet)
		nwcol = sh.newTableTableColumnElement ();
		nwcol.setTableNumberColumnsRepeatedAttribute(lcol + ncols); # lcol = 0-based now
		nwcol.setTableDefaultCellStyleNameAttribute ("Default");
		nwcol.setTableStyleNameAttribute ("co1");
		# Switch to OdfElement API & add rows
		sh = ods.app.getTableByName (wsh);
		if (trow)
			# Empty upper rows
			row = sh.appendRow ();
			row.getOdfElement ().setTableNumberRowsRepeatedAttribute (trow+nrows);
			for ii=1:sh.getColumnCount ()
				row.getCellByIndex (ii-1).getOdfElement ().setTableStyleNameAttribute ("co1");
			endfor
		endif
		
	else
		# Add spreadsheet data columns if needed. Compute nr of extra columns & rows.
		# FIXME Unfortunately, odfdom-0.8 calls may crash on some otherwise valid sheets
		ii = max (0, lcol + ncols - sh.getColumnCount())
		jj = max (0, trow + nrows - sh.getRowCount())
# keyboard
		if (ii > 0)
			col = sh.appendColumn();
#			col = sh.getOdfElement ().newTableTableColumnElement ();
#			col = sh.getColumnByIndex (sh.getColumnCount () - 1);
			try
			 for kk=0:sh.getRowCount () -1
			  try
				ncell = col.getCellByIndex (kk);
				ncell.setColumnsRepeatedNumber (ii);
			  catch
# 'error w col'
# keyboard
			  end_try_catch
			 endfor
			catch
			 end_try_catch
		endif
		changed = 1;
# 'cols'
# keyboard
		# Add spreadsheet rows if needed
		if (jj > 0)
			row = sh.appendRow ();
			if (jj > 1) row.getOdfElement ().setTableNumberRowsRepeatedAttribute (jj); endif
# keyboard
			tblrow = row.getOdfElement ();
			for kk=0:tblrow.getLength()-1
				# Remove bogus attributes introduced by buggy odfdom-0.8 calls
				tblrow.item(kk).removeAttribute ('office:value');
				tblrow.item(kk).removeAttribute ('office:value-type');
			endfor
			changed = 1;
		endif
	endif
# 'ready f writing'
# keyboard

	# Transfer array data to sheet
	for ii=1:nrows
		for jj=1:ncols
			ocell = sh.getCellByPosition (jj+lcol-1, ii+trow-1);
			if ~(isempty (ocell ) || typearr(ii, jj) == 6) # Might be spanned (merged), hidden, ....
				# Number, String, Boolean, Date, Time, Empty
				switch typearr (ii, jj)
					case 1	# Numeric
						ocell.setDoubleValue (c_arr{ii, jj}); 
					case 2	# String
						ocell.setStringValue (c_arr{ii, jj});
					case 3	# Logical / Boolean
						ocell.setBooleanValue (c_arr{ii, jj});
					otherwise
						# The above is all octave has to offer & java can accept...
				endswitch
				changed = 1;
			endif
		endfor
	endfor

	if (changed)	
		ods.changed = 1;
		rstatus = 1;
	endif

endfunction


#=============================================================================

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

## ods2oct - write data from octave to an ODS spreadsheet using the
## jOpenDocument interface.
## Watch out, no error checks. Sheet WSH must exist. Data can only be
## modified, not added.
##
## Author: Philip Nienhuis
## Created: 2009-12-13
## First usable version: 2010-01-14
## Updates:
## 2010-03-17 Adapted to simplified calccelladdress argument list

function [ ods, rstatus ] = oct2jod2ods (c_arr, ods, wsh=1, crange=[])

	# jOpenDocument version

	rstatus = 0;

	# Get worksheet. Use first one if none given
	if (isempty (wsh)) wsh = 1; endif
	if (isnumeric (wsh)) wsh = wsh - 1; endif	# Sheet nos. 0-based
	sh = ods.workbook.getSheet (wsh);			# Either numeric or char string
	if (isempty (sh)) error ("Requested sheet does not exist in file."); endif

	[nr, nc] = size (c_arr);
	if (isempty (crange))
		trow = 0;
		lcol = 0;
		nrows = nr;
		ncols = nc;
	else
		[dummy, nrows, ncols, trow, lcol] = parse_sp_range (crange);
		# Row/col = 0 based in jOpenDocument
		trow = trow - 1; lcol = lcol - 1;
	endif
	if (trow >65536 || lcol> 1024)
		celladd = calccelladdress (lcol, trow);
		error (sprintf ("Topleft cell (%s) beyond spreadsheet limits (AMJ65536).", celladd));
	endif
	# Check spreadsheet capacity beyond requested topleft cell
	nrows = min (nrows, 65536 - trow + 1);
	ncols = min (ncols, 1024 - lcol + 1);
	# Check array size and requested range
	nrows = min (nrows, nr);
	ncols = min (ncols, nc);
	if (nrows < nc || ncols < nc) warning ("Array truncated to fit in range"); endif

	if (isnumeric (c_arr)) c_arr = num2cell (c_arr); endif

	# Write data to worksheet
	changed = 0;
	for ii = 1 : min (nrows, nr)
		for jj = 1 : min (ncols, nc)
			val = c_arr {ii, jj};
			if (isnumeric (val) || ischar (val) || islogical (val))
				try
					jcell = sh.getCellAt (ii + lcol - 1, jj + trow - 1).setValue (val);
					changed = 1;
				catch
					# No panic, probably a merged cell
					printf (sprintf ("Cell skipped at (%d, %d)\n", ii+lcol-1, jj+trow-1));
				end_try_catch
			endif
		endfor
	endfor

	if (changed && (ods.changed < 1)) 
		ods.changed = 1; 
		rstatus = 1;
	endif

endfunction
