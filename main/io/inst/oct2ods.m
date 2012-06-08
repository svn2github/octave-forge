## Copyright (C) 2009,2010,2011,2012 Philip Nienhuis <pr.nienhuis at users.sf.net>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} [ @var{ods}, @var{rstatus} ] = oct2ods (@var{arr}, @var{ods})
## @deftypefnx {Function File} [ @var{ods}, @var{rstatus} ] = oct2ods (@var{arr}, @var{ods}, @var{wsh})
## @deftypefnx {Function File} [ @var{ods}, @var{rstatus} ] = oct2ods (@var{arr}, @var{ods}, @var{wsh}, @var{range})
## @deftypefnx {Function File} [ @var{ods}, @var{rstatus} ] = oct2ods (@var{arr}, @var{ods}, @var{wsh}, @var{range}, @var{options})
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
## @var{arr} can be any 1D or 2D array containing numerical or character
## data (cellstr) except complex. Mixed numeric/text arrays can only be
## cell arrays.
##
## @var{ods} must be a valid pointer struct created earlier by odsopen.
##
## @var{wsh} can be a number (sheet name) or string (sheet number).
## In case of a yet non-existing Calc file, the first sheet will be
## used & named according to @var{wsh}.
## In case of existing files, some checks are made for existing sheet
## names or numbers.
## When new sheets are to be added to the Calc file, they are
## inserted to the right of all existing sheets. The pointer to the
## "active" sheet (shown when Calc opens the file) remains untouched.
##
## If @var{range} omitted, the top left cell where the data will be put
## is supposed to be 'A1'; only a top left cell address can be specified
## as well. In these cases the actual range to be used is determined by
## the size of @var{arr}.
## Be aware that large data array sizes may exhaust the java shared
## memory space. For larger arrays, appropriate memory settings are
## needed in the file java.opts; then the maximum array size for the
## java-based spreadsheet options can be in the order of perhaps 10^6
## elements.
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
##   [ods, status] = ods2oct (@{'String'@}, ods, 'Oldsheet3', 'B15:B15');
##   Put a character string into cell B15 in sheet Oldsheet3
## @end example
##
## @seealso {ods2oct, odsopen, odsclose, odsread, odswrite, odsfinfo}
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
## 2010-08-14 Moved check on input cell array to main function
## 2010-08-15 Texinfo header edits
## 2010-08-16 Added check on presence of output argument
## 2010-08-23 Added check on validity of ods file ptr
##    ''      Experimental support for odfdom 0.8.6 (in separate subfunc, to be integrated later)
## 2010-08-25 Improved help text (java memory, ranges)
## 2010-10-27 Improved file change tracking tru ods.changed
## 2010-11-12 Better input argument checks
## 2010-11-13 Reset ods.limits when read was successful
## 2010-11-13 Added check for 2-D input array
## 2011-03-23 First try of odfdom 0.8.7
## 2011-05-15 Experimental UNO support added
## 2011-11-18 Fixed bug in test for range parameter being character string
## 2012-01-26 Fixed "seealso" help string
## 2012-02-20 Fixed range parameter to be default empty string rather than empty numeral
## 2012-02-27 More range arg fixes
## 2012-03-07 Updated texinfo help text
## 2012-06-08 Support for odfdom-incubator-0.8.8
##     ''     Tabs replaced by double space
##
## Last update of subfunctions below: 2012-06-08

function [ ods, rstatus ] = oct2ods (c_arr, ods, wsh=1, crange='', spsh_opts=[])

  if (nargin < 2) error ("oct2xls needs a minimum of 2 arguments."); endif
  
  # Check if input array is cell
  if (isempty (c_arr))
    warning ("Request to write empty matrix - ignored."); 
    rstatus = 1;
    return;
  elseif (isnumeric (c_arr))
    c_arr = num2cell (c_arr);
  elseif (ischar(c_arr))
    c_arr = {c_arr};
    printf ("(oct2ods: input character array converted to 1x1 cell)\n");
  elseif (~iscell (c_arr))
    error ("oct2ods: input array neither cell nor numeric array");
  endif
  if (ndims (c_arr) > 2), error ("Only 2-dimensional arrays can be written to spreadsheet"); endif

  # Check ods file pointer struct
  test1 = ~isfield (ods, "xtype");
  test1 = test1 || ~isfield (ods, "workbook");
  test1 = test1 || isempty (ods.workbook);
  test1 = test1 || isempty (ods.app);
  if test1
    error ("Arg #2: Invalid ods file pointer struct");
  endif

  # Check worksheet ptr
  if (~(ischar (wsh) || isnumeric (wsh))), error ("Integer (index) or text (wsh name) expected for arg # 3"); endif

  # Check range
  if (~isempty (crange) && ~ischar (crange))
    error ("Character string (range) expected for arg # 4");
  elseif (isempty (crange))
    crange = '';
  endif

  # Various options 
  if (isempty (spsh_opts))
    spsh_opts.formulas_as_text = 0;
    # other options to be implemented here
  elseif (isstruct (spsh_opts))
    if (~isfield (spsh_opts, 'formulas_as_text')), spsh_opts.formulas_as_text = 0; endif
    # other options to be implemented here
  else
    error ("Structure expected for arg # 5");
  endif
  
  if (nargout < 1) printf ("Warning: no output spreadsheet file pointer specified.\n"); endif

  if (strcmp (ods.xtype, 'OTK'))
    # Write ods file tru Java & ODF toolkit.
    switch ods.odfvsn
      case "0.7.5"
        [ ods, rstatus ] = oct2jotk2ods (c_arr, ods, wsh, crange, spsh_opts);
      case {"0.8.6", "0.8.7", "0.8.8"}
        [ ods, rstatus ] = oct3jotk2ods (c_arr, ods, wsh, crange, spsh_opts);
      otherwise
        error ("Unsupported odfdom version");
    endswitch

  elseif (strcmp (ods.xtype, 'JOD'))
    # Write ods file tru Java & jOpenDocument. API still leaves lots to be wished...
    [ ods, rstatus ] = oct2jod2ods (c_arr, ods, wsh, crange);

  elseif (strcmp (ods.xtype, 'UNO'))
    # Write ods file tru Java & UNO bridge (OpenOffice.org & clones)
    [ ods, rstatus ] = oct2uno2ods (c_arr, ods, wsh, crange, spsh_opts);

#  elseif 
    # ---- < Other interfaces here >

  else
    error (sprintf ("ods2oct: unknown OpenOffice.org .ods interface - %s.", ods.xtype));
  endif

  if (rstatus), ods.limits = []; endif

endfunction


#=============================================================================

## Copyright (C) 2010,2011,2012 Philip Nienhuis <prnienhuis@users.sf.net>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## oct2jotk2ods
## write data array to an ODS spreadsheet using Java & ODFtoolkit 0.7.5

## I'm truly sorry that oct2jotk2ods is so ridiculously complex,
## and therefore so slow; but there's a good reason for that:
## Writing to ODS is already fairly complicated when just making a
## new sheet ("table"); but it really becomes a headache when
## writing to an existing sheet. In that case one should beware of
## table-number-columns-repeated, table-number-rows-repeated,
## covered (merged) cells, incomplete tables and rows, etc.
## ODF toolkit v. 0.7.5 does nothing to hide this from the user;
## you may sort it out all by yourself.

## Author: Philip Nienhuis <prnienhuis@users.sf.net>
## Created: 2010-01-07
## Updates: 
## 2010-01-14 (finally seems to work OK)
## 2010-03-08 Some comment lines adapted
## 2010-03-25 Try-catch added f. unpatched-for-booleans java-1.2.6 / 1.2.7 package
## 2010-04-11 Changed all references to "cell" to "scell" to avoid reserved keyword
##     ''     Small bugfix for cases with empty left columns (wrong cell reference)
## 2010-04-13 Fixed bug with stray cell copies beyond added data rectangle
## 2010-07-29 Added formula input support (based on xls patch by Benjamin Lindner)
## 2010-08-01 Added try-catch around formula input
##     ''     Changed range arg to also allow just topleft cell
## 2010-08-03 Moved range checks and type array parsing to separate functions
## 2010-08-13 Fixed empty Sheet1 in case of new spreadsheets, fix input text sheet name
## 2010-10-27 Improved file change tracking tru ods.changed
## 2010-11-12 Improved file change tracking tru ods.changed

function [ ods, rstatus ] = oct2jotk2ods (c_arr, ods, wsh, crange, spsh_opts)

  persistent ctype;
  if (isempty (ctype))
    # Number, Boolean, String, Formula, Empty, Date, Time (last 2 are ignored)
    ctype = [1, 2, 3, 4, 5, 6, 7];
  endif

  rstatus = 0; f_errs = 0;

  # Get some basic spreadsheet data from the pointer using ODFtoolkit
  odfcont = ods.workbook;
  xpath = ods.app.getXPath ();
  offsprdsh = ods.app.getContentRoot();
  autostyles = odfcont.getOrCreateAutomaticStyles();
  officestyles = ods.app.getOrCreateDocumentStyles();

  # Create an instance of type NODESET for use in subsequent statements
  NODESET = java_get ('javax.xml.xpath.XPathConstants', 'NODESET');

  # Parse sheets ("tables") from ODS file
  sheets = xpath.evaluate ("//table:table", odfcont, NODESET);
  nr_of_sheets = sheets.getLength ();
  newsh = 0;                # Assume existing sheet
  if isempty (wsh) wsh = 1; endif
  if (~isnumeric (wsh))          # Sheet name specified
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
  else                    # Sheet index specified
    if ((ods.changed > 2) || (wsh > nr_of_sheets && wsh < 256))  # Max nr of sheets = 256
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
  --trow; --lcol;                  # Zero-based row # & col #
  if (nrows < nr || ncols < nc)
    warning ("Array truncated to fit in range");
    c_arr = c_arr(1:nrows, 1:ncols);
  endif
  
# Parse data array, setup typarr and throw out NaNs  to speed up writing;
  typearr = spsh_prstype (c_arr, nrows, ncols, ctype, spsh_opts, 0);
  if ~(spsh_opts.formulas_as_text)
    # Find formulas (designated by a string starting with "=" and ending in ")")
    fptr = cellfun (@(x) ischar (x) && strncmp (x, "=", 1) && strncmp (x(end:end), ")", 1), c_arr);
    typearr(fptr) = ctype(4);          # FORMULA
  endif

# Prepare worksheet for writing. If needed create new sheet
  if (newsh)
    if (ods.changed > 2)
      # New spreadsheet. Prepare to use the default 1x1 first sheet.
      sh = sheets.item(0);
    else
      # Other sheets exist, create a new sheet. First the basics
      sh = java_new ('org.odftoolkit.odfdom.doc.table.OdfTable', odfcont);
      # Append sheet to spreadsheet ( contentRoot)
      offsprdsh.appendChild (sh);
      # Rebuild sheets nodes
      sheets = xpath.evaluate ("//table:table", odfcont, NODESET);
    endif 

    # Sheet name
    if (isnumeric (wsh))
      # Give sheet a name
      str = sprintf ("Sheet%d", wsh);
      sh.setTableNameAttribute (str);
    else
      # Assign name to sheet and change wsh into numeric pointer
      sh.setTableNameAttribute (wsh);
      wsh = sheets.getLength () - 1;
    endif
    # Fixup wsh pointer in case of new spreadsheet
    if (ods.changed > 2) wsh = 0; endif

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
      dcell = scell.cloneNode (1);    # Deep copy
      drow.appendCell (dcell);
    endfor
    # 5. Last cell is remaining column counter
    rest = max (1024 - lcol - ncols);
    if (rest)
      dcell = scell.cloneNode (1);    # Deep copy
      drow.appendCell (dcell);
      if (rest > 1) dcell.setTableNumberColumnsRepeatedAttribute (rest); endif
    endif
    # Only now add drow as otherwise for each cell an empty table-column is
    # inserted above the rows (odftoolkit bug?)
    sh.appendRow (drow);
    if (ods.changed > 2)
      # In case of a completely new spreadsheet, delete the first initial 1-cell row
      # But check if it *is* a row...
      try
        sh.removeChild (drow.getPreviousRow ());
      catch
        # Nothing. Apparently there was only the just appended row.
      end_try_catch
    endif
    # 6. Row template ready. Copy row template down to cover future array
    for ii=2:nrows
      nrow = drow.cloneNode (1);  # Deep copy
      sh.appendRow (nrow);
    endfor
    ods.changed = min (ods.changed, 2);    # Keep 2 for new spshsht, 1 for existing + changed

  else
    # Existing sheet. We must be prepared for all situations, incomplete rows,
    # number-rows/columns-repeated, merged (spanning) cells, you name it.
    # First explore row buildup of existing sheet using an XPath
    sh = sheets.item(wsh);                      # 0 - based
    str = sprintf ("//table:table[%d]/table:table-row", wsh + 1);  # 1 - based 
    trows = xpath.evaluate (str, odfcont, NODESET);
    nr_of_trows = trows.getLength();   # Nr. of existing table-rows, not data rows!

    # For the first rows we do some preprocessing here. Similar stuff for cells
    # i.e. table-cells (columns) is done in the loops below.
    # Make sure the upper data array row doesn't end up in a nr-rows-repeated row

    # Provisionally! set start table-row in case "while" & "if" (split) are skipped
    drow = trows.item(0);  
    rowcnt = 0; trowcnt = 0;          # Spreadsheet/ table-rows, resp;
    while (rowcnt < trow && trowcnt < nr_of_trows)
      # Count rows & table-rows UNTIL we reach trow
      ++trowcnt;                # Nr of table-rows
      row = drow;
      drow = row.getNextSibling ();
      repcnt = row.getTableNumberRowsRepeatedAttribute();
      rowcnt = rowcnt + repcnt;        # Nr of spreadsheet rows
    endwhile
    rsplit = rowcnt - trow;
    if (rsplit > 0)
      # Apparently a nr-rows-repeated top table-row must be split, as the
      # first data row seems to be projected in it (1st while condition above!)
      row.removeAttribute ('table:number-rows-repeated');
      row.getCellAt (0).removeAttribute ('table:number-columns-repeated');
      nrow = row.cloneNode (1);
      drow = nrow;              # Future upper data array row
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
      drow = row.cloneNode (1);                # First data row
      row.setTableNumberRowsRepeatedAttribute (-rsplit);    # Filler row
      scell = java_new ('org.odftoolkit.odfdom.doc.table.OdfTableCell', odfcont);
      dcell = scell.cloneNode (1);
      scell.setTableNumberColumnsRepeatedAttribute (COL_CAP);  # Filler cell
      row.appendCell (scell);
      sh.appendRow (row);
      drow.appendCell (dcell);
      sh.appendRow (drow);
    endif
  endif

# For each row, for each cell, add the data. Expand row/column-repeated nodes

  row = drow;      # Start row; pointer still exists from above stanzas
  for ii=1:nrows
    if (~newsh)    # Only for existing sheets the next checks should be made
      # While processing next data rows, fix table-rows if needed
      if (isempty (row) || (row.getLength () < 1))
        # Append an empty row with just one empty cell
        row = java_new ('org.odftoolkit.odfdom.doc.table.OdfTableRow', odfcont);
        scell = java_new ('org.odftoolkit.odfdom.doc.table.OdfTableCell', odfcont);
        scell.setTableNumberColumnsRepeatedAttribute (lcol + 1);
        row.appendCell (scell);
        sh.appendRow (row);
      else
        # If needed expand nr-rows-repeated
        repcnt = row.getTableNumberRowsRepeatedAttribute ();
        if (repcnt > 1)
          row.removeAttribute ('table:number-rows-repeated');
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
        ++tcellcnt;            # Nr of table-cells counted
        scell = dcell;
        dcell = scell.getNextSibling ();
        repcnt = scell.getTableNumberColumnsRepeatedAttribute ();
        colcnt = colcnt + repcnt;    # Nr of spreadsheet cell counted
      endwhile
      csplit = colcnt - lcol;
      if (csplit > 0)
        # Apparently a nr-columns-repeated cell must be split
        scell.removeAttribute ('table:number-columns-repeated');
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
        else
          # If needed expand nr-cols-repeated
          repcnt = scell.getTableNumberColumnsRepeatedAttribute ();
          if (repcnt > 1)
            scell.removeAttribute ('table:number-columns-repeated');
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
        endwhile
        scell.removeAttribute ('table:formula');
      endif

      # Empty cell count stuff done. At last we can add the data
      switch (typearr (ii, jj))
        case 1  # float
          scell.setOfficeValueTypeAttribute ('float');
          scell.setOfficeValueAttribute (c_arr{ii, jj});
        case 2    # boolean
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
        case 3  # string
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
        case {0 5}  # Empty. Clear value attributes
          if (~newsh)
            scell.removeAttribute ('office:value-type');
            scell.removeAttribute ('office:value');
          endif
        case 6  # Date (implemented but Octave has no "date" data type - yet?)
          scell.setOfficeValueTypeAttribute ('date');
          [hh mo dd hh mi ss] = datevec (c_arr{ii,jj});
          str = sprintf ("%4d-%2d-%2dT%2d:%2d:%2d", yy, mo, dd, hh, mi, ss);
          scell.setOfficeDateValueAttribute (str);
        case 7  # Time (implemented but Octave has no "time" data type)
          scell.setOfficeValueTypeAttribute ('time');
          [hh mo dd hh mi ss] = datevec (c_arr{ii,jj});
          str = sprintf ("PT%2d:%2d:%2d", hh, mi, ss);
          scell.setOfficeTimeValuettribute (str);
        otherwise
          # Nothing
      endswitch

      scell = scell.getNextSibling ();

    endfor

    row = row.getNextSibling ();

  endfor

  if (f_errs) 
    printf ("%d formula errors encountered - please check input array\n", f_errs); 
  endif
  ods.changed = max (min (ods.changed, 2), changed);  # Preserve 2 (new file), 1 (existing)
  rstatus = 1;
  
endfunction


#=============================================================================

## Copyright (C) 2010,2011,2012 Philip Nienhuis <prnienhuis _at- users.sf.net>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## odf3jotk2oct - read ODS spreadsheet data using Java & odftoolkit v 0.8.6+.
## You need proper java-for-octave & odfdom.jar 0.8.6+ & xercesImpl.jar 2.9.1
## in your javaclasspath. For reliable writing odfdom-0.8.6+ is still
## experimental :-(  v. 0.7.5 has been tested much more
##
## Author: Philip Nenhuis <pr.nienhuis at users.sf.net>
## Created: 2010-03-16, after oct2jotk2ods()
## Updates:
## 2010-03-17 Rebuild for odfdom-0.8
## 2010-03-19 Showstopper bug in odfdom-0.8 - getCellByPosition(<address>)
##            crashes on rows > #10 !!! Rest seems to work OK, however
## 2010-03-22 First somewhat usable version for odfdom 0.8
## 2010-03-29 Gave up. Writing a new empty sheet works, appending
##            data to an existing one can crash virtually anywhere.
##            The wait is for odfdom-0.8.+ ....
## 2010-06-05 odfdom 0.8.5 is there, next try....
## 2010-06-## odfdom 0.8.5 dropped, too buggy
## 2010-08-22 odfdom 0.8.6 is there... seems to work with just one bug, easily worked around
## 2010-10-27 Improved file change tracking tru ods.changed
## 2010-11-12 Improved file change tracking tru ods.changed
## 2010-12-08 Bugfixes (obj -> arg L.715; removed stray arg in call to spsh_prstype L.719)
## 2011-03-23 First try of odfdom 0.8.7
## 2012-06-08 Support for odfdom-incubator-0.8.8

function [ ods, rstatus ] = oct3jotk2ods (c_arr, ods, wsh, crange, spsh_opts)

  persistent ctype;
  if (isempty (ctype))
    # Number, Boolean, String, Formula, Empty; Date, Time - last two aren't used
    ctype = [1, 2, 3, 4, 5, 6, 7];
  endif

  rstatus = 0; changed = 0; newsh = 0;

  # Get contents and table stuff from the workbook
  odfcont = ods.workbook;    # Use a local copy just to be sure. octave 
                # makes physical copies only when needed (?)
  odfroot = odfcont.getRootElement ();
  offsprdsh = ods.app.getContentRoot();
  if (strcmp (ods.odfvsn, '0.8.7') || strfind (ods.odfvsn, "0.8.8"))
    spsh = odfcont.getDocument ();
  else
    spsh = odfcont.getOdfDocument ();
  endif

  # Get some basic spreadsheet data from the pointer using ODFtoolkit
  autostyles = odfcont.getOrCreateAutomaticStyles();
  officestyles = ods.app.getOrCreateDocumentStyles();

  # Parse sheets ("tables") from ODS file
  sheets = ods.app.getTableList();
  nr_of_sheets = sheets.size ();
  # Check user input & find sheet pointer
  if (~isnumeric (wsh))
    try
      sh = ods.app.getTableByName (wsh);
      # We do need a sheet index number...
      ii = 0;
      while (ischar (wsh) && ii < nr_of_sheets) 
        sh_nm = sh.getTableName ();
        if (strcmp (sh_nm, wsh)) wsh = ii + 1; else ++ii; endif
      endwhile
    catch
      newsh = 1;
    end_try_catch
    if isempty (sh) newsh = 1; endif
  elseif (wsh < 1)
    # Negative sheet number:
    error (sprintf ("Illegal worksheet nr. %d\n", wsh));
  elseif (wsh > nr_of_sheets)
    newsh = 1;
  else
    sh = sheets.get (wsh - 1);
  endif

  # Check size of data array & range / capacity of worksheet & prepare vars
  [nr, nc] = size (c_arr);
  [topleft, nrows, ncols, trow, lcol] = spsh_chkrange (crange, nr, nc, ods.xtype, ods.filename);
  --trow; --lcol;                  # Zero-based row # & col #
  if (nrows < nr || ncols < nc)
    warning ("Array truncated to fit in range");
    c_arr = c_arr(1:nrows, 1:ncols);
  endif
  
# Parse data array, setup typarr and throw out NaNs  to speed up writing;
  typearr = spsh_prstype (c_arr, nrows, ncols, ctype, spsh_opts);
  if ~(spsh_opts.formulas_as_text)
    # Find formulas (designated by a string starting with "=" and ending in ")")
    fptr = cellfun (@(x) ischar (x) && strncmp (x, "=", 1) && strncmp (x(end:end), ")", 1), c_arr);
    typearr(fptr) = ctype(4);          # FORMULA
  endif

# Prepare spreadsheet for writing (size, etc.). If needed create new sheet
  if (newsh)
    if (ods.changed > 2)
      # New spreadsheet, use default first sheet
      sh = sheets.get (0);
    else
      # Create a new sheet using DOM API. This part works OK.
      sh = sheets.get (nr_of_sheets - 1).newTable (spsh, nrows, ncols);
    endif
    changed = 1;
    if (isnumeric (wsh))
      # Give sheet a name
      str = sprintf ("Sheet%d", wsh);
      sh.setTableName (str);
      wsh = str;
    else
      # Assign name to sheet and change wsh into numeric pointer
      sh.setTableName (wsh);
    endif
    printf ("Sheet %s added to spreadsheet.\n", wsh);
    
  else
    # Add "physical" rows & columns. Spreadsheet max. capacity checks have been done above
    # Add spreadsheet data columns if needed. Compute nr of extra columns & rows.
    curr_ncols = sh.getColumnCount ();
    ii = max (0, lcol + ncols - curr_ncols);
    if (ii == 1)
      nwcols = sh.appendColumn ();
    else
      nwcols = sh.appendColumns (ii);
    endif

    # Add spreadsheet rows if needed
    curr_nrows = sh.getRowCount ();
    ii = max (0, trow + nrows - curr_nrows);
    if (ii == 1)
      nwrows = sh.appendRow ();
    else
      nwrows = sh.appendRows (ii);
    endif
  endif
 
  # Transfer array data to sheet
  for ii=1:nrows
    for jj=1:ncols
      ocell = sh.getCellByPosition (jj+lcol-1, ii+trow-1);
      if ~(isempty (ocell )) # Might be spanned (merged), hidden, ....
        # Number, String, Boolean, Date, Time
        try
          switch typearr (ii, jj)
            case {1, 6, 7}  # Numeric, Date, Time
              ocell.setDoubleValue (c_arr{ii, jj}); 
            case 2  # Logical / Boolean
              # ocell.setBooleanValue (c_arr{ii, jj}); # Doesn't work, bug in odfdom 0.8.6
              # Bug workaround: 1. Remove all cell contents
              ocell.removeContent ();
              # 2. Switch to TableTableElement API
              tocell = ocell.getOdfElement ();
              tocell.setAttributeNS ('office', 'office:value-type', 'boolean');
              # 3. Add boolean-value attribute. 
              # This is only accepted in TTE API with a NS tag (actual bug, IMO)
              if (c_arr {ii,jj})
                tocell.setAttributeNS ('office', 'office:boolean-value', 'true');
              else
                tocell.setAttributeNS ('office', 'office:boolean-value', 'false');
              endif
            case 3  # String
              ocell.setStringValue (c_arr{ii, jj});
            case 4  # Formula
              ocell.setFormula (c_arr{ii, jj});
            otherwise     # 5, empty and catch-all
              # The above is all octave has to offer & java can accept...
          endswitch
          changed = 1;
        catch
          printf ("\n");
        end_try_catch
      endif
    endfor
  endfor

  if (changed)  
    ods.changed = max (min (ods.changed, 2), changed);  # Preserve 2 (new file), 1 (existing)
    rstatus = 1;
  endif

endfunction


#=============================================================================

## Copyright (C) 2009,2010,2011,2012 Philip Nienhuis <pr.nienhuis at users.sf.net>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

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
##     ''     Added check for jOpenDocument version. Adding sheets only works for
##            1.2b3+ (barring bug above)
## 2010-06-02 Fixed first sheet remaining in new spreadsheets
## 2010-08-01 Added option for crange to be only topleft cell address
##     ''     Code cleanup
## 2010-08-13 Fixed bug of ignoring text sheet name in case of new spreadsheet
## 2010-08-15 Fixed bug with invalid first sheet in new spreadsheets
## 2010-10-27 Improved file change tracking tru ods.changed
## 2010-11-12 Improved file change tracking tru ods.changed
## 2012-02-26 Write logicals as doubles (bug in jOpenDocument, would write as text)

function [ ods, rstatus ] = oct2jod2ods (c_arr, ods, wsh, crange)

  rstatus = 0; sh = []; changed = 0;

  # Get worksheet. Use first one if none given
  if (isempty (wsh)) wsh = 1; endif
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
      elseif (ods.changed > 2)
        sh.setName ('Sheet1');
        changed = 1;
      endif
    endif
  endif
  # wsh is now either a 0-based sheet no. or a string. In latter case:
  if (isempty (sh) && ischar (wsh))
    sh = ods.workbook.getSheet (wsh);
    if (isempty (sh))
      # Still doesn't exist. Create sheet
      if (ods.odfvsn == 3)
        if (ods.changed > 2)
          # 1st "new" -unnamed- sheet has already been made when creating the spreadsheet
          sh = ods.workbook.getSheet (0);
          sh.setName (wsh);
          changed = 1;
        else
          # For existing spreadsheets
          printf ("Adding sheet '%s'\n", wsh);
          sh = ods.workbook.addSheet (sh_cnt, wsh);
          changed = 1;
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
  nrows = min (nrows, 65536 - trow);    # Remember, lcol & trow are zero-based
  ncols = min (ncols, 1024 - lcol);
  # Check array size and requested range
  nrows = min (nrows, nr);
  ncols = min (ncols, nc);
  if (nrows < nr || ncols < nc) warning ("Array truncated to fit in range"); endif

  if (isnumeric (c_arr)) c_arr = num2cell (c_arr); endif

  # Ensure sheet capacity is large enough to contain new data
  try    # try-catch needed to work around bug in jOpenDocument v 1.2b3 and earlier
    sh.ensureColumnCount (lcol + ncols);  # Remember, lcol & trow are zero-based
  catch  # catch is needed for new empty sheets (first ensureColCnt() hits null ptr)
    sh.ensureColumnCount (lcol + ncols);
    # Kludge needed because upper row is defective (NPE jOpenDocument bug). ?Fixed in 1.2b4?
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
        # FIXME: jOpenDocument doesn't really support writing booleans (doesn't set OffValAttr)
        if (islogical (val)); val = double (val); endif
        try
          sh.getCellAt (jj + lcol - 1, ii + trow - 1).clearValue();
          jcell = sh.getCellAt (jj + lcol - 1, ii + trow - 1).setValue (val);
          changed = 1;
        catch
          # No panic, probably a merged cell
        #  printf (sprintf ("Cell skipped at (%d, %d)\n", ii+lcol-1, jj+trow-1));
        end_try_catch
      endif
    endfor
  endfor

  if (changed)
    ods.changed = max (min (ods.changed, 2), changed);  # Preserve 2 (new file), 1 (existing)
    rstatus = 1;
  endif

endfunction


## Copyright (C) 2011,2012 Philip Nienhuis <prnienhuis@users.sf.net>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## oct2uno2ods - transfer data to ods or xls file using Java/UNO bridge
## with OpenOffice_org & clones

## Author: Philip Nienhuis <prnienhuis@users.sf.net>
## Created: 2011-05-15
## Updates:
## 2011-summer <many many improvements>
## 2011-09-08 Stylistic changes
## 2011-09-18 Adapted sh_names type to LO 3.4.1
## 2011-09-23 Removed stray debug statements
## 2012-02-25 Work around LO3.5rc1 Java Runtime Exception bug L.1043+
## 2012-02-26 Bug fix when adding sheets near L.1101 (wrong if-else-end construct).

function [ ods, rstatus ] = oct2uno2ods (c_arr, ods, wsh, crange, spsh_opts)

  changed = 0;
  newsh = 0;
  ctype = [1, 2, 3, 4, 5];  # Float, Logical, String, Formula, Empty

  # Get handle to sheet, create a new one if needed
  sheets = ods.workbook.getSheets ();
  sh_names = sheets.getElementNames ();
  if (! iscell (sh_names))
    # Java array (LibreOffice 3.4.+); convert to cellstr
    sh_names = char (sh_names);
  else
    sh_names = {sh_names};
  endif

  # Clear default 2 last sheets in case of a new spreadsheet file
  if (ods.changed > 2)
    ii = numel (sh_names);
    while (ii > 1)
      shnm = sh_names{ii};
      # Work around LibreOffice 3.5.rc1 bug (Java Runtime Exception)
      try
        sheets.removeByName (shnm);
      end_try_catch
      --ii;
    endwhile
    # Give remaining sheet a name
    unotmp = java_new ('com.sun.star.uno.Type', 'com.sun.star.sheet.XSpreadsheet');
    sh = sheets.getByName (sh_names{1}).getObject.queryInterface (unotmp);
    if (isnumeric (wsh)); wsh = sprintf ("Sheet%d", wsh); endif
    unotmp = java_new ('com.sun.star.uno.Type', 'com.sun.star.container.XNamed');
    sh.queryInterface (unotmp).setName (wsh);
  else

    # Check sheet pointer
    # FIXME sheet capacity check needed. How many can fit in an OOo sprsh.file?
    if (isnumeric (wsh))
      if (wsh < 1)
        error ("Illegal sheet index: %d", wsh);
      elseif (wsh > numel (sh_names))
        # New sheet to be added. First create sheet name but check if it already exists
        shname = sprintf ("Sheet%d", numel (sh_names) + 1);
        jj = strmatch (wsh, sh_names);
        if (~isempty (jj))
          # New sheet name already in file, try to create a unique & reasonable one
          ii = 1; filler = ''; maxtry = 5;
          while (ii <= maxtry)
            shname = sprintf ("Sheet%s%d", [filler "_"], numel (sh_names + 1));
            if (isempty (strmatch (wsh, sh_names)))
              ii = 10;
            else
              ++ii;
            endif
          endwhile
          if (ii > maxtry + 1)
            error ("Could not add sheet with a unique name to file %s");
          endif
        endif
        wsh = shname;
        newsh = 1;
      else
        # turn wsh index into the associated sheet name
        wsh = sh_names (wsh);
      endif
    else
      # wsh is a sheet name. See if it exists already
      if (isempty (strmatch (wsh, sh_names)))
        # Not found. New sheet to be added
        newsh = 1;
      endif
    endif
    if (newsh)
      # Add a new sheet. Sheet index MUST be a Java Short object
      shptr = java_new ("java.lang.Short", sprintf ("%d", numel (sh_names) + 1));
      sh = sheets.insertNewByName (wsh, shptr);
    endif
    # At this point we have a valid sheet name. Use it to get a sheet handle
    unotmp = java_new ('com.sun.star.uno.Type', 'com.sun.star.sheet.XSpreadsheet');
    sh = sheets.getByName (wsh).getObject.queryInterface (unotmp);
  endif

  # Check size of data array & range / capacity of worksheet & prepare vars
  [nr, nc] = size (c_arr);
  [topleft, nrows, ncols, trow, lcol] = spsh_chkrange (crange, nr, nc, ods.xtype, ods.filename);
  --trow; --lcol;                      # Zero-based row # & col #
  if (nrows < nr || ncols < nc)
    warning ("Array truncated to fit in range");
    c_arr = c_arr(1:nrows, 1:ncols);
  endif
  
  # Parse data array, setup typarr and throw out NaNs  to speed up writing;
  typearr = spsh_prstype (c_arr, nrows, ncols, ctype, spsh_opts, 0);
  if ~(spsh_opts.formulas_as_text)
    # Find formulas (designated by a string starting with "=" and ending in ")")
    fptr = cellfun (@(x) ischar (x) && strncmp (x, "=", 1), c_arr);
    typearr(fptr) = ctype(4);          # FORMULA
  endif

  # Transfer data to sheet
  for ii=1:nrows
    for jj=1:ncols
      try
        XCell = sh.getCellByPosition (lcol+jj-1, trow+ii-1);
        switch typearr(ii, jj)
          case 1  # Float
            XCell.setValue (c_arr{ii, jj});
          case 2  # Logical. Convert to float
            XCell.setValue (double (c_arr{ii, jj}));
          case 3  # String
            unotmp = java_new ('com.sun.star.uno.Type', 'com.sun.star.text.XText');
            XCell.queryInterface (unotmp).setString (c_arr{ii, jj});
          case 4  # Formula
            if (spsh_opts.formulas_as_text)
              unotmp = java_new ('com.sun.star.uno.Type', 'com.sun.star.text.XText');
              XCell.queryInterface (unotmp).setString (c_arr{ii, jj});
            else
              XCell.setFormula (c_arr{ii, jj});
            endif
          otherwise
            # Empty cell
        endswitch
        changed = 1;
      catch
        printf ("Error writing cell %s (typearr() = %d)\n", calccelladdress(trow+ii, lcol+jj), typearr(ii, jj));
      end_try_catch
    endfor
  endfor

  if (changed)  
    ods.changed = max (min (ods.changed, 2), changed);  # Preserve 2 (new file), 1 (existing)
    rstatus = 1;
  endif

endfunction
