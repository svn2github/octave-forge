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
## @deftypefnx {Function File} [ @var{ods}, @var{rstatus} ] = oct2ods (@var{arr}, @var{ods}, @var{wsh}, @var{range}, @var(options))
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
## If omitted, @var{range} is initially supposed to be 'A1:AMJ65536';
## only a top left cell address can be specified as well. In these cases
## the actual range to be used is determined by the size of @var{arr}.
## Be aware that data array sizes > 2.10^5 elements may exhaust the
## java shared memory space for the default java memory settings.
## For larger arrays appropriate memory settings are needed in the file
## java.opts; then the maximum array size for the java-based spreadsheet
## options is about 5-6.10^5 elements.
##
## Optional argument @var{options}, a structure, can be used to specify
## various write modes.
## Currently the only option field is "formulas_as_text", which -if set
## to 1 or TRUE- specifies that formula strings (i.e., text strings
## starting with "=" and ending in a ")" ) should be entered as litteral
## text strings rather than as spreadsheet formulas (the latter is the
## default). As jOpenDocument doesn't support formula I/O at all yet,
## this option is ignored for the JOD interface.
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
##   [ods, status] = ods2oct (arr, ods, 'Newsheet1', 'AA31:GH165');
##   Write array arr into sheet Newsheet1 with upperleft cell at AA31
## @end example
##
## @example
##   [ods, status] = ods2oct ({'String'}, ods, 'Oldsheet3', 'B15:B15');
##   Put a character string into cell B15 in sheet Oldsheet3
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
## 2010-06-01 Almost complete support for upcoming jOpenDocument 1.2b4. 1.2b3 still lacks a bit
## 2010-07-05 Added example for writng character strings
## 2010-07-29 Added option for entering / reading back spreadsheet formulas
##
## Last update of subfunctions below: 2010-08-01

function [ ods, rstatus ] = oct2ods (c_arr, ods, wsh=1, crange=[], spsh_opts=[])

	if isempty (spsh_opts)
		spsh_opts.formulas_as_text = 0;
		# Other options here
	endif

	if (strcmp (ods.xtype, 'OTK'))
		# Write ods file tru Java & ODF toolkit.
		[ ods, rstatus ] = oct2jotk2ods (c_arr, ods, wsh, crange, spsh_opts);
		
	elseif (strcmp (ods.xtype, 'JOD'))
		# Write ods file tru Java & jOpenDocument. API still leaves lots to be wished...
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
## 2010-04-11 Changed all references to "cell" to "scell" to avoid reserved keyword
##            Small bugfix for cases with empty left columns (wrong cell reference)
## 2010-04-13 Fixed bug with stray cell copies beyond added data rectangle
## 2010-07-29 Added formula input support (based on xls patch by Benjamin Lindner)
## 2010-08-01 Added try-catch around formula input
##     "      Changed range arg to also allow just topleft cell
## 2010-08-03 Moved range checks and type array parsing to separate functions

function [ ods, rstatus ] = oct2jotk2ods (c_arr, ods, wsh, crange, spsh_opts)

	persistent ctype;
	if (isempty (ctype))
		# Number, Boolean, String, Formula, Empty, Date, Time
		ctype = [1, 2, 3, 4, 5, 6, 7];
	endif

	rstatus = 0; changed = 0; f_errs = 0;

#	# ODS' current row and column capacity
#	ROW_CAP = 65536; COL_CAP = 1024;

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
	[topleft, nrows, ncols, trow, lcol] = spsh_chkrange (crange, nr, nc, ods.xtype, ods.filename);
	--trow; --lcol;									# Zero-based row # & col #
	if (nrows < nr || ncols < nc)
		warning ("Array truncated to fit in range");
		obj = obj(1:nrows, 1:ncols);
	endif
	
# Parse data array, setup typarr and throw out NaNs  to speed up writing;
	typearr = spsh_prstype (c_arr, nrows, ncols, ctype, spsh_opts, 0);
	if ~(spsh_opts.formulas_as_text)
		# Find formulas (designated by a string starting with "=" and ending in ")")
		fptr = cellfun (@(x) ischar (x) && strncmp (x, "=", 1) && strncmp (x(end:end), ")", 1), c_arr);
		typearr(fptr) = ctype(4);					# FORMULA
	endif

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

	# Build up the complete row & cell structure to cover the data array.
	# This will speed up processing later

		# 1. Build empty table row template
		row = java_new ('org.odftoolkit.odfdom.doc.table.OdfTableRow', odfcont);
		# Create an empty tablecell & append it to the row
		scell = java_new ('org.odftoolkit.odfdom.doc.table.OdfTableCell', odfcont);
		scell = row.appendCell (scell);
		scell.setTableNumberColumnsRepeatedAttribute (1024);
		# 2. If needed add empty filler row above the data rows & if needed add repeat count
		if (trow > 0)				
			sh.appendRow (row);
			if (trow > 1) row.setTableNumberRowsRepeatedAttribute (trow); endif
		endif
		# 3. Add data rows; first one serves as a template
		drow = java_new ('org.odftoolkit.odfdom.doc.table.OdfTableRow', odfcont);
		if (lcol > 0) 
			scell = java_new ('org.odftoolkit.odfdom.doc.table.OdfTableCell', odfcont);
			drow.appendCell (scell);
			if (lcol > 1) scell.setTableNumberColumnsRepeatedAttribute (lcol); endif
		endif
		# 4. Add data cell placeholders
		scell = java_new ('org.odftoolkit.odfdom.doc.table.OdfTableCell', odfcont);
		drow.appendCell (scell);
		for jj=2:ncols
			dcell = scell.cloneNode (1);		# Deep copy
			drow.appendCell (dcell);
		endfor
		# 5. Last cell is remaining column counter
		rest = max (1024 - lcol - ncols);
		if (rest)
			dcell = scell.cloneNode (1);		# Deep copy
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
			# Count rows & table-rows UNTIL we reach trow
			++trowcnt;								# Nr of table-rows
			row = drow;
			drow = row.getNextSibling ();
			repcnt = row.getTableNumberRowsRepeatedAttribute();
			rowcnt = rowcnt + repcnt;				# Nr of spreadsheet rows
		endwhile
		rsplit = rowcnt - trow;
		if (rsplit > 0)
			# Apparently a nr-rows-repeated top table-row must be split, as the
			# first data row seems to be projected in it (1st while condition above!)
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
			scell = java_new ('org.odftoolkit.odfdom.doc.table.OdfTableCell', odfcont);
			dcell = scell.cloneNode (1);
			scell.setTableNumberColumnsRepeatedAttribute (COL_CAP);	# Filler cell
			row.appendCell (scell);
			sh.appendRow (row);
			drow.appendCell (dcell);
			sh.appendRow (drow);
			changed = 1;
		endif
	endif

# For each row, for each cell, add the data. Expand row/column-repeated nodes

	row = drow;			# Start row; pointer still exists from above stanzas
	for ii=1:nrows
		if (~newsh)		# Only for existing sheets the next checks should be made
			# While processing next data rows, fix table-rows if needed
			if (isempty (row) || (row.getLength () < 1))
				# Append an empty row with just one empty cell
				row = java_new ('org.odftoolkit.odfdom.doc.table.OdfTableRow', odfcont);
				scell = java_new ('org.odftoolkit.odfdom.doc.table.OdfTableCell', odfcont);
				scell.setTableNumberColumnsRepeatedAttribute (lcol + 1);
				row.appendCell (scell);
				sh.appendRow (row);
				changed = 1;
			else
				# If needed expand nr-rows-repeated
				repcnt = row.getTableNumberRowsRepeatedAttribute ();
				if (repcnt > 1)
					row.removeAttribute ('table:number-rows-repeated');
					changed = 1;
					# Insert new table-rows above row until our new data space is complete.
					# Keep handle of upper new table-row as that's where data are added 1st
					drow = row.cloneNode (1);
					sh.insertBefore (drow, row);
					for kk=1:min (repcnt, nrows-ii)
						nrow = row.cloneNode (1);
						sh.insertBefore (nrow, row);
					endfor
					if (repcnt > nrows-ii+1)
						row.setTableNumberRowsRepeatedAttribute (repcnt - nrows +ii - 1);
					endif
					row = drow;
				endif
			endif

			# Check if leftmost cell ends up in nr-cols-repeated cell
			colcnt = 0; tcellcnt = 0; rcellcnt = row.getLength();
			dcell = row.getCellAt (0);
			while (colcnt < lcol && tcellcnt < rcellcnt)
				# Count columns UNTIL we hit lcol
				++tcellcnt;						# Nr of table-cells counted
				scell = dcell;
				dcell = scell.getNextSibling ();
				repcnt = scell.getTableNumberColumnsRepeatedAttribute ();
				colcnt = colcnt + repcnt;		# Nr of spreadsheet cell counted
			endwhile
			csplit = colcnt - lcol;
			if (csplit > 0)
				# Apparently a nr-columns-repeated cell must be split
				scell.removeAttribute ('table:number-columns-repeated');
				changed = 1;
				ncell = scell.cloneNode (1);
				if (repcnt > 1)
					scell.setTableNumberColumnsRepeatedAttribute (repcnt - csplit);
				else
					scell.removeAttribute ('table:number-columns-repeated');
				endif
				rcell = scell.getNextSibling ();
				row.insertBefore (ncell, rcell);
				for jj=2:csplit
					ncell = ncell.cloneNode (1);
					row.insertBefore (ncell, rcell);
				endfor
			elseif (csplit < 0)
				# New cells to be added beyond current last cell & table-cell in row
				dcell = java_new ('org.odftoolkit.odfdom.doc.table.OdfTableCell', odfcont);
				scell = dcell.cloneNode (1);
				dcell.setTableNumberColumnsRepeatedAttribute (-csplit);
				row.appendCell (dcell);
				changed = 1;
				row.appendCell (scell);
			endif
		endif

	# Write a row of data from data array, column by column
	
		for jj=1:ncols
			scell = row.getCellAt (lcol + jj - 1);
			if (~newsh)
				if (isempty (scell))
					# Apparently end of row encountered. Add cell
					scell = java_new ('org.odftoolkit.odfdom.doc.table.OdfTableCell', odfcont);
					scell = row.appendCell (scell);
					changed = 1;
				else
					# If needed expand nr-cols-repeated
					repcnt = scell.getTableNumberColumnsRepeatedAttribute ();
					if (repcnt > 1)
						scell.removeAttribute ('table:number-columns-repeated');
						changed = 1;
						for kk=2:repcnt
							ncell = scell.cloneNode (1);
							row.insertBefore (ncell, scell.getNextSibling ());
						endfor
					endif
				endif
				# Clear text contents
				while (scell.hasChildNodes ())
					tmp = scell.getFirstChild ();
					scell.removeChild (tmp);
					changed = 1;
				endwhile
				scell.removeAttribute ('table:formula');
			endif

			# Empty cell count stuff done. At last we can add the data
			switch (typearr (ii, jj))
				case 1	# float
					scell.setOfficeValueTypeAttribute ('float');
					scell.setOfficeValueAttribute (c_arr{ii, jj});
				case 2		# boolean
					# Beware, for unpatched-for-booleans java-1.2.7- we must resort to floats
					try
						# First try the preferred java-boolean way
						scell.setOfficeValueTypeAttribute ('boolean');
						scell.removeAttribute ('office:value');
						if (c_arr{ii, jj})
							scell.setOfficeBooleanValueAttribute (1);
						else
							scell.setOfficeBooleanValueAttribute (0);
						endif
					catch
						# Unpatched java package. Fall back to transferring a float
						scell.setOfficeValueTypeAttribute ('float');
						if (c_arr{ii, jj})
							scell.setOfficeValueAttribute (1);
						else
							scell.setOfficeValueAttribute (0);
						endif
					end_try_catch
				case 3	# string
					scell.setOfficeValueTypeAttribute ('string');
					pe = java_new ('org.odftoolkit.odfdom.doc.text.OdfTextParagraph', odfcont,'', c_arr{ii, jj});
					scell.appendChild (pe);
				case 4  # Formula.  
					# As we don't know the result type, simply remove previous type info.
					# Once OOo Calc reads it, it'll add the missing attributes
					scell.removeAttribute ('office:value');
					scell.removeAttribute ('office:value-type');
					# Try-catch not strictly needed, there's no formula validator yet
					try
						scell.setTableFormulaAttribute (c_arr{ii, jj});
						scell.setOfficeValueTypeAttribute ('string');
						pe = java_new ('org.odftoolkit.odfdom.doc.text.OdfTextParagraph', odfcont,'', '#Recalc Formula#');
						scell.appendChild (pe);
					catch
						++f_errs;
						scell.setOfficeValueTypeAttribute ('string');
						pe = java_new ('org.odftoolkit.odfdom.doc.text.OdfTextParagraph', odfcont,'', c_arr{ii, jj});
						scell.appendChild (pe);
					end_try_catch
				case {0 5}	# Empty. Clear value attributes
					if (~newsh)
						scell.removeAttribute ('office:value-type');
						scell.removeAttribute ('office:value');
					endif
				case 6	# Date (implemented but Octave has no "date" data type - yet?)
					scell.setOfficeValueTypeAttribute ('date');
					[hh mo dd hh mi ss] = datevec (c_arr{ii,jj});
					str = sprintf ("%4d-%2d-%2dT%2d:%2d:%2d", yy, mo, dd, hh, mi, ss);
					scell.setOfficeDateValueAttribute (str);
				case 7	# Time (implemented but Octave has no "time" data type)
					scell.setOfficeValueTypeAttribute ('time');
					[hh mo dd hh mi ss] = datevec (c_arr{ii,jj});
					str = sprintf ("PT%2d:%2d:%2d", hh, mi, ss);
					scell.setOfficeTimeValuettribute (str);
				otherwise
					# Nothing
			endswitch
			changed = 1;

			scell = scell.getNextSibling ();

		endfor

		row = row.getNextSibling ();

	endfor

	if (f_errs) 
		printf ("%d formula errors encountered - please check input array\n", f_errs); 
	endif
	if (changed)	
		ods.changed = 1;
		rstatus = 1;
	endif
	
endfunction


#=============================================================================

## Copyright (C) 2009-2010 Philip Nienhuis <pr.nienhuis at users.sf.net>
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
##
## Author: Philip Nienhuis
## Created: 2009-12-13
## First usable version: 2010-01-14
## Updates:
## 2010-03-17 Adapted to simplified calccelladdress argument list
## 2010-04-24 Added ensureColumnCount & ensureRowCount
##            Fixed a few bugs with top row & left column indexes
##            Fixed a number of other stupid bugs
##            Added check on NaN before assigning data value to sprdsh-cell
## 2010-06-01 Checked logic. AFAICS all should work with upcoming jOpenDocument 1.2b4;
##            in 1.2b3 adding a newsheet always leaves an incomplete upper row;
##            supposedly (hopefully) that will be fixed in 1.2b4.
##      "     Added check for jOpenDocument version. Adding sheets only works for
##            1.2b3+ (barring bug above)
## 2010-06-02 Fixed first sheet remaining in new spreadsheets
## 2010-08-01 Added option for crange to be only topleft cell address
##     "      Code cleanup

function [ ods, rstatus ] = oct2jod2ods (c_arr, ods, wsh, crange)

	# Check jOpenDocument version
	sh = ods.workbook.getSheet (0);
	cl = sh.getCellAt (0, 0);
	try
		# 1.2b3 has public getValueType ()
		cl.getValueType ();
		ver = 3;
	catch
		# 1.2b2 has not
		ver = 2;
	end_try_catch

	rstatus = 0; sh = []; changed = 0;

	# Get worksheet. Use first one if none given
	if (isempty (wsh) || ods.changed == 2) wsh = 1; endif
	sh_cnt = ods.workbook.getSheetCount ();
	if (isnumeric (wsh))
		if (wsh > 1024)
			error ("Sheet number out of range of ODS specification (>1024)");
		elseif (wsh > sh_cnt)
			error ("Sheet number (%d) larger than number of sheets in file (%d)\n", wsh, sh_cnt);
		else
			wsh = wsh - 1;
			sh = ods.workbook.getSheet (wsh);
			if (isempty (sh))
				# Sheet number wsh didn't exist yet
				wsh = sprintf ("Sheet%d", wsh+1);
			elseif (ods.changed == 2)
				sh.setName ('Sheet1');
				ods.changed = 0;
			endif
		endif
	endif
	# wsh is now either a 0-based sheet no. or a string. In latter case:
	if (isempty (sh) && ischar (wsh))
		sh = ods.workbook.getSheet (wsh);
		if (isempty (sh))
			# Still doesn't exist. Create sheet
			if (ver == 3)
				if (ods.changed == 2)
					# 1st "new" -unnamed- sheet has already been made when creating the spreadsheet
					sh.setName = wsh;
					ods.changed = 0;
				else
					# For existing spreadsheets
					printf ("Adding sheet '%s'\n", wsh);
					sh = ods.workbook.addSheet (sh_cnt, wsh);
				endif
			else
				error ("jOpenDocument v. 1.2b2 does not support adding sheets - upgrade to v. 1.2b3\n");
			endif
		endif
	endif

	[nr, nc] = size (c_arr);
	if (isempty (crange))
		trow = 0;
		lcol = 0;
		nrows = nr;
		ncols = nc;
	elseif (isempty (strfind (deblank (crange), ':'))) 
		[dummy1, dummy2, dummy3, trow, lcol] = parse_sp_range (crange);
		nrows = nr;
		ncols = nc;
		# Row/col = 0 based in jOpenDocument
		trow = trow - 1; lcol = lcol - 1;
	else
		[dummy, nrows, ncols, trow, lcol] = parse_sp_range (crange);
		# Row/col = 0 based in jOpenDocument
		trow = trow - 1; lcol = lcol - 1;
	endif

	if (trow > 65535 || lcol > 1023)
		error ("Topleft cell beyond spreadsheet limits (AMJ65536).");
	endif
	# Check spreadsheet capacity beyond requested topleft cell
	nrows = min (nrows, 65536 - trow);		# Remember, lcol & trow are zero-based
	ncols = min (ncols, 1024 - lcol);
	# Check array size and requested range
	nrows = min (nrows, nr);
	ncols = min (ncols, nc);
	if (nrows < nr || ncols < nc) warning ("Array truncated to fit in range"); endif

	if (isnumeric (c_arr)) c_arr = num2cell (c_arr); endif

	# Ensure sheet capacity is large enough to contain new data
	try		# try-catch needed to work around bug in jOpenDocument v 1.2b3 and earlier
		sh.ensureColumnCount (lcol + ncols);	# Remember, lcol & trow are zero-based
	catch	# catch is needed for new empty sheets (first ensureColCnt() hits null ptr)
		sh.ensureColumnCount (lcol + ncols);
		# Kludge needed because upper row is defective (NPE jOpenDocument bug). Fixed in 1.2b4?
		if (trow == 0)
			# Shift rows one down to avoid defective upper row
			++trow;
			printf ("Info: empy upper row above data added to avoid JOD bug.\n");
		endif
	end_try_catch
	sh.ensureRowCount (trow + nrows);

	# Write data to worksheet
	for ii = 1 : nrows
		for jj = 1 : ncols
			val = c_arr {ii, jj};
			if ((isnumeric (val) && ~isnan (val)) || ischar (val) || islogical (val))
				try
					jcell = sh.getCellAt (jj + lcol - 1, ii + trow - 1).setValue (val);
					changed = 1;
				catch
					# No panic, probably a merged cell
				#	printf (sprintf ("Cell skipped at (%d, %d)\n", ii+lcol-1, jj+trow-1));
				end_try_catch
			endif
		endfor
	endfor

#	if (changed && (ods.changed < 1))     # Why ?
	if (changed)
		ods.changed = 1; 
		rstatus = 1;
	endif

endfunction
