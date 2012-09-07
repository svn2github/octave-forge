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
## @deftypefn {Function File} [ @var{rawarr}, @var{ods}, @var{rstatus} ] = ods2oct (@var{ods})
## @deftypefnx {Function File} [ @var{rawarr}, @var{ods}, @var{rstatus} ] = ods2oct (@var{ods}, @var{wsh})
## @deftypefnx {Function File} [ @var{rawarr}, @var{ods}, @var{rstatus} ] = ods2oct (@var{ods}, @var{wsh}, @var{range})
## @deftypefnx {Function File} [ @var{rawarr}, @var{ods}, @var{rstatus} ] = ods2oct (@var{ods}, @var{wsh}, @var{range}, @var{options})
##
## Read data contained within cell range @var{range} from worksheet @var{wsh}
## in an OpenOffice_org Calc spreadsheet file pointed to in struct @var{ods}.
##
## @var{ods} is supposed to have been created earlier by odsopen in the
## same octave session.
##
## @var{wsh} is either numerical or text, in the latter case it is 
## case-sensitive.
## Note that in case of a numerical @var{wsh} this number refers to the
## position in the worksheet stack, counted from the left in a Calc
## window. The default is numerical 1, i.e. the leftmost worksheet
## in the ODS file.
##
## @var{range} is expected to be a regular spreadsheet range format,
## or "" (empty string, indicating all data in a worksheet).
## If no range is specified the occupied cell range will have to be
## determined behind the scenes first; this can take some time.
##
## Optional argument @var{options}, a structure, can be used to
## specify various read modes by setting option fields in the struct
## to true (1) or false (0). Currently recognized option fields are:
##
## @table @asis
## @item "formulas_as_text"
## If set to TRUE or 1, spreadsheet formulas (if at all present)
## are read as formula strings rather than the evaluated formula
## result values. This only works for the OTK and UNO interfaces.
## The default value is 0 (FALSE).
##
## @item 'strip_array'
## Set the value of this field set to TRUE or 1 to strip the returned
## output array @var{rawarr} from empty outer columns and rows. The
## spreadsheet cell rectangle limits from where the data actually
## came will be updated. The default value is FALSE or 0 (no cropping).
## @end table
##
## If only the first argument @var{ods} is specified, ods2oct will
## try to read all contents from the first = leftmost (or the only)
## worksheet (as if a range of @'' (empty string) was specified).
## 
## If only two arguments are specified, ods2oct assumes the second
## argument to be @var{wsh}. In that case ods2oct will try to read
## all data contained in that worksheet.
##
## Return argument @var{rawarr} contains the raw spreadsheet cell data.
## Use parsecell() to separate numeric and text values from @var{rawarr}.
##
## Optional return argument @var{ods} contains the pointer struct. Field
## @var{ods}.limits contains the outermost column and row numbers of the
## actually read cell range.
##
## Optional return argument @var{rstatus} will be set to 1 if the
## requested data have been read successfully, 0 otherwise.
##
## Erroneous data and empty cells turn up empty in @var{rawarr}.
## Date/time values in OpenOffice.org are returned as numerical values
## with base 1-1-0000 (same as octave). But beware that Excel spreadsheets
## rewritten by OpenOffice.org into .ods format may have numerical date
## cells with base 01-01-1900 (same as MS-Excel).
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
## @seealso {odsopen, odsclose, parsecell, odsread, odsfinfo, oct2ods, odswrite}
##
## @end deftypefn

## Author: Philip Nienhuis
## Created: 2009-12-13
## Updates:
## 2009-12-30 First working version
## 2010-03-19 Added check for odfdom version (should be 0.7.5 until further notice)
## 2010-03-20 Works for odfdom v 0.8 too. Added subfunction ods3jotk2oct for that
## 2010-04-06 Benchmarked odfdom versions. v0.7.5 is up to 7 times faster than v0.8!
##            So I added a warning for users using odfdom 0.8.
## 2010-04-11 Removed support for odfdom-0.8 - it's painfully slow and unreliable
## 2010-05-31 Updated help text (delay i.c.o. empty range due to getusedrange call)
## 2010-08-03 Added support for reading back formulas (works only in OTK)
## 2010-08-12 Added explicit support for jOpenDocument v 1.2b3+
## 2010-08-25 Improved helptext (moved some text around)
## 2010-08-27 Added ods3jotk2oct - internal function for odfdom-0.8.6.jar
##     ''     Extended check on spsh_opts (must be a struct) 
## 2010-10-27 Moved cropping rawarr from empty outer rows & columns to here
## 2011-05-06 Experimental UNO support
## 2011-09-18 Set rstatus var here
## 2012-01-26 Fixed "seealso" help string
## 2012-02-25 Added 0.8.7 to supported odfdom versions in L.155
## 2012-02-26 Updated texinfo header help text
## 2012-06-08 Support for odfdom-incubator 0.8.8
##     ''     Replaced tabs by double space
##
## (Latest update of subfunctions below: 2012-06-08)

function [ rawarr, ods, rstatus ] = ods2oct (ods, wsh=1, datrange=[], spsh_opts=[])

  # Check if ods struct pointer seems valid
  if (~isstruct (ods)), error ("File ptr struct expected for arg @ 1"); endif
  test1 = ~isfield (ods, "xtype");
  test1 = test1 || ~isfield (ods, "workbook");
  test1 = test1 || isempty (ods.workbook);
  test1 = test1 || isempty (ods.app);
  if (test1)
    error ("Arg #1 is an invalid ods file struct");
  endif
  # Check worksheet ptr
  if (~(ischar (wsh) || isnumeric (wsh))), error ("Integer (index) or text (wsh name) expected for arg # 2"); endif
  # Check range
  if (~(isempty (datrange) || ischar (datrange))), error ("Character string (range) expected for arg # 3"); endif
  # Check & setup options struct
  if (nargin < 4 || isempty (spsh_opts))
    spsh_opts.formulas_as_text = 0;
    spsh_opts.strip_array = 1;
    # Other options here
  elseif (~isstruct (spsh_opts))
    error ("struct expected for OPTIONS argument (# 4)");
  else
    if (~isfield (spsh_opts, 'formulas_as_text')), spsh_opts.formulas_as_text = 0; endif
    if (~isfield (spsh_opts, 'strip_array')), spsh_opts.strip_array = 1; endif
    % Future options:
  endif

  # Select the proper interfaces
  if (strcmp (ods.xtype, 'OTK'))
    # Read ods file tru Java & ODF toolkit
    switch ods.odfvsn
      case '0.7.5'
        [rawarr, ods] = ods2jotk2oct (ods, wsh, datrange, spsh_opts);
      case {'0.8.6', '0.8.7', '0.8.8'}
        [rawarr, ods] = ods3jotk2oct (ods, wsh, datrange, spsh_opts);
      otherwise
        error ("Unsupported odfdom version or invalid ods file pointer.");
    endswitch
  elseif (strcmp (ods.xtype, 'JOD'))
    # Read ods file tru Java & jOpenDocument. JOD doesn't know about formulas :-(
    [rawarr, ods] = ods2jod2oct  (ods, wsh, datrange);
  elseif (strcmp (ods.xtype, 'UNO'))
    # Read ods file tru Java & UNO
    [rawarr, ods] = ods2uno2oct (ods, wsh, datrange, spsh_opts);
#  elseif 
  #  ---- < Other interfaces here >
  else
    error (sprintf ("ods2oct: unknown OpenOffice.org .ods interface - %s.", ods.xtype));
  endif

  rstatus = ~isempty (rawarr);

  # Optionally strip empty outer rows and columns & keep track of original data location
  if (spsh_opts.strip_array && rstatus)
    emptr = cellfun ('isempty', rawarr);
    if (all (all (emptr)))
      rawarr = {};
      ods.limits= [];
    else
      nrows = size (rawarr, 1); ncols = size (rawarr, 2);
      irowt = 1;
      while (all (emptr(irowt, :))), irowt++; endwhile
      irowb = nrows;
      while (all (emptr(irowb, :))), irowb--; endwhile
      icoll = 1;
      while (all (emptr(:, icoll))), icoll++; endwhile
      icolr = ncols;
      while (all (emptr(:, icolr))), icolr--; endwhile

      # Crop outer rows and columns and update limits
      rawarr = rawarr(irowt:irowb, icoll:icolr);
      ods.limits = ods.limits + [icoll-1, icolr-ncols; irowt-1, irowb-nrows];
    endif
  endif

endfunction


#=====================================================================

## Copyright (C) 2009,2010,2011,2012 Philip Nienhuis <prnienhuis _at- users.sf.net>
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

## odf2jotk2oct - read ODS spreadsheet data using Java & odftoolkit
## You need proper java-for-octave & odfdom.jar + xercesImpl.jar
## in your javaclasspath.

## Author: Philip Nenhuis <pr.nienhuis at users.sf.net>
## Created: 2009-12-24
## Updates:
## 2010-01-08 First working version
## 2010-03-18 Fixed many bugs with wrong row references in case of empty upper rows
##     ""     Fixed reference to upper row in case of nr-rows-repeated top tablerow
##     ""     Tamed down memory usage for rawarr when desired data range is given
##     ""     Added call to getusedrange() for cases when no range was specified
## 2010-03-19 More code cleanup & fixes for bugs introduced 18/3/2010 8-()
## 2010-08-03 Added preliminary support for reading back formulas as text strings
## 2010-10-27 Moved cropping rawarr from empty outer rows & columns to caller
## 2011-09-18 Remove rstatus var (now set in caller)

function [ rawarr, ods ] = ods2jotk2oct (ods, wsh, crange, spsh_opts)

  # Parts after user gfterry in
  # http://www.oooforum.org/forum/viewtopic.phtml?t=69060
  
  # Get contents and table stuff from the workbook
  odfcont = ods.workbook;    # Use a local copy just to be sure. octave 
                            # makes physical copies only when needed (?)
  xpath = ods.app.getXPath;
  
  # AFAICS ODS spreadsheets have the following hierarchy (after Xpath processing):
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
        wsh = ii;
      endif
    endwhile
    if (ischar (wsh))
      error (sprintf ("No worksheet '%s' found in file %s", wsh, ods.filename));
    endif
  elseif (wsh > nr_of_sheets || wsh < 1)
    # We already have a numeric sheet pointer. If it's not in range:
    error (sprintf ("Worksheet no. %d out of range (1 - %d)", wsh, nr_of_sheets));
  endif

  # Get table-rows in sheet no. wsh. Sheet count = 1-based (!)
  str = sprintf ("//table:table[%d]/table:table-row", wsh);
  sh = xpath.evaluate (str, odfcont, NODESET);
  nr_of_rows = sh.getLength (); 

  # Either parse (given cell range) or prepare (unknown range) help variables 
  if (isempty (crange))
    [ trow, brow, lcol, rcol ] = getusedrange (ods, wsh);
    nrows = brow - trow + 1;  # Number of rows to be read
    ncols = rcol - lcol + 1;  # Number of columns to be read
  else
    [dummy, nrows, ncols, trow, lcol] = parse_sp_range (crange);
    brow = min (trow + nrows - 1, nr_of_rows);
    # Check ODS column limits
    if (lcol > 1024 || trow > 65536) 
      error ("ods2oct: invalid range; max 1024 columns & 65536 rows."); 
    endif
    # Truncate range silently if needed
    rcol = min (lcol + ncols - 1, 1024);
    ncols = min (ncols, 1024 - lcol + 1);
    nrows = min (nrows, 65536 - trow + 1);
  endif
  # Create storage for data content
  rawarr = cell (nrows, ncols);

  # Prepare reading sheet row by row
  rightmcol = 0;    # Used to find actual rightmost column
  ii = trow - 1;    # Spreadsheet row counter
  rowcnt = 0;
  # Find uppermost requested *tablerow*. It may be influenced by nr-rows-repeated
  if (ii >= 1)
    tfillrows = 0;
    while (tfillrows < ii)
      row = sh.item(tfillrows);
      extrarows = row.getTableNumberRowsRepeatedAttribute ();
      tfillrows = tfillrows + extrarows;
      ++rowcnt;
    endwhile
    # Desired top row may be in a nr-rows-repeated tablerow....
    if (tfillrows > ii); ii = tfillrows; endif
  endif

  # Read from worksheet row by row. Row numbers are 0-based
  while (ii < brow)
    row = sh.item(rowcnt++);
    nr_of_cells = min (row.getLength (), rcol);
    rightmcol = max (rightmcol, nr_of_cells);  # Keep track of max row length
    # Read column (cell, "table-cell" in ODS speak) by column
    jj = lcol; 
    while (jj <= rcol)
      tcell = row.getCellAt(jj-1);
      form = 0;
      if (~isempty (tcell))     # If empty it's possibly in columns-repeated/spanned
        if (spsh_opts.formulas_as_text)   # Get spreadsheet formula rather than value
          # Check for formula attribute
          tmp = tcell.getTableFormulaAttribute ();
          if isempty (tmp)
            form = 0;
          else
            if (strcmp (tolower (tmp(1:3)), 'of:'))
              tmp (1:end-3) = tmp(4:end);
            endif
            rawarr(ii-trow+2, jj-lcol+1) = tmp;
            form = 1;
          endif
        endif
        if ~(form || index (char(tcell), 'text:p>Err:') || index (char(tcell), 'text:p>#DIV'))  
          # Get data from cell
          ctype = tcell.getOfficeValueTypeAttribute ();
          cvalue = tcell.getOfficeValueAttribute ();
          switch deblank (ctype)
            case  {'float', 'currency', 'percentage'}
              rawarr(ii-trow+2, jj-lcol+1) = cvalue;
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
                rawarr(ii-trow+2, jj-lcol+1) = datenum (yr, mo, dy, hh, mm, ss);
              else
                rawarr(ii-trow+2, jj-lcol+1) = datenum (yr, mo, dy);
              endif
            case 'time'
              cvalue = tcell.getOfficeTimeValueAttribute ();
              if (index (cvalue, 'PT'))
                hh = str2num (cvalue(3:4));
                mm = str2num (cvalue(6:7));
                ss = str2num (cvalue(9:10));
                rawarr(ii-trow+2, jj-lcol+1) = datenum (0, 0, 0, hh, mm, ss);
              endif
            case 'boolean'
              cvalue = tcell.getOfficeBooleanValueAttribute ();
              rawarr(ii-trow+2, jj-lcol+1) = cvalue; 
            case 'string'
              cvalue = tcell.getOfficeStringValueAttribute ();
              if (isempty (cvalue))     # Happens with e.g., hyperlinks
                tmp = char (tcell);
                # Hack string value from between <text:p|r> </text:p|r> tags
                ist = findstr (tmp, '<text:');
                if (ist)
                  ist = ist (length (ist));
                  ist = ist + 8;
                  ien = index (tmp(ist:end), '</text') + ist - 2;
                  tmp (ist:ien);
                  cvalue = tmp(ist:ien);
                endif
              endif
              rawarr(ii-trow+2, jj-lcol+1)= cvalue;
            otherwise
              # Nothing
          endswitch
        endif
      endif
      ++jj;            # Next cell
    endwhile

    # Check for repeated rows (i.e. condensed in one table-row)
    extrarows = row.getTableNumberRowsRepeatedAttribute () - 1;
    if (extrarows > 0 && (ii + extrarows) < 65535)
      # Expand rawarr cf. table-row
      nr_of_rows = nr_of_rows + extrarows;
      ii = ii + extrarows;
    endif
    ++ii;
  endwhile

  # Keep track of data rectangle limits
  ods.limits = [lcol, rcol; trow, brow];

endfunction


#===========================================================================

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

## ods3jotk2oct: internal function for reading odf files using odfdom-0.8.6

## Author: Philip Nienhuis <Philip@DESKPRN>
## Created: 2010-08-24. First workable version Aug 27, 2010
## Updates:
## 2010-10-27 Moved cropping rawarr from empty outer rows & columns to caller
## 2010-11-13 Added workaround for reading text cells in files made by jOpenDocument 1.2bx
## 2011-09-18 Comment out workaround for jOpenDocument bug (no OfficeValueAttr set)
##            because this casts all numeric cells to string type for properly written ODS1.2
##     ''     Remove rstatus var (now set in caller)

function [ rawarr, ods ] = ods3jotk2oct (ods, wsh, crange, spsh_opts)

  # Get contents and table stuff from the workbook
  odfcont = ods.workbook;  # Use a local copy just to be sure. octave 
                           # makes physical copies only when needed (?)
  
  # Parse sheets ("tables") from ODS file
  sheets = ods.app.getTableList();
  nr_of_sheets = sheets.size ();

  # Check user input & find sheet pointer (1-based)
  if (~isnumeric (wsh))
    try
      sh = ods.app.getTableByName (wsh);
      sh_err = isempty (sh);
    catch
      sh_err = 1;
    end_try_catch
    if (sh_err)
      error (sprintf ("Sheet %s not found in file %s\n", wsh, ods.filename)); 
    endif
  elseif (wsh > nr_of_sheets || wsh < 1)
    # We already have a numeric sheet pointer. If it's not in range:
    error (sprintf ("Worksheet no. %d out of range (1 - %d)", wsh, nr_of_sheets));
  else
    sh = sheets.get (wsh - 1);
  endif

  # Either parse (given cell range) or prepare (unknown range) help variables 
  if (isempty (crange))
    if ~isnumeric (wsh)
      # Get sheet index
      jj = nr_of_sheets;
      while jj-- >= 0
        if (strcmp (wsh, sheets.get(jj).getTableName()) == 1)
          wsh = jj +1;
          jj = -1;
        endif
      endwhile
    endif
    [ trow, brow, lcol, rcol ] = getusedrange (ods, wsh);
    nrows = brow - trow + 1;  # Number of rows to be read
    ncols = rcol - lcol + 1;  # Number of columns to be read
  else
    [dummy, nrows, ncols, trow, lcol] = parse_sp_range (crange);
    # Check ODS row/column limits
    if (lcol > 1024 || trow > 65536) 
      error ("ods2oct: invalid range; max 1024 columns & 65536 rows."); 
    endif
    # Truncate range silently if needed
    rcol = min (lcol + ncols - 1, 1024);
    ncols = min (ncols, 1024 - lcol + 1);
    nrows = min (nrows, 65536 - trow + 1);
    brow = trow + nrows - 1;
  endif

  # Create storage for data content
  rawarr = cell (nrows, ncols);

  # Read from worksheet row by row. Row numbers are 0-based
  for ii=trow:nrows+trow-1
    row = sh.getRowByIndex (ii-1);
    for jj=lcol:ncols+lcol-1;
      ocell = row.getCellByIndex (jj-1);
      if ~isempty (ocell)
        otype = deblank (tolower (ocell.getValueType ()));
         if (spsh_opts.formulas_as_text)
          if ~isempty (ocell.getFormula ())
            otype = 'formula';
          endif
        endif
#        # Provisions for catching jOpenDocument 1.2b bug where text cells
#        # haven't been assigned an <office:value-type='string'> attribute
#        if (~isempty (ocell))
#          if (findstr ('<text:', char (ocell.getOdfElement ()))), otype = 'string'; endif
#        endif
        # At last, read the data
        switch otype
          case  {'float', 'currency', 'percentage'}
            rawarr(ii-trow+1, jj-lcol+1) = ocell.getDoubleValue ();
          case 'date'
            # Dive into TableTable API
            tvalue = ocell.getOdfElement ().getOfficeDateValueAttribute ();
            # Dates are returned as octave datenums, i.e. 0-0-0000 based
            yr = str2num (tvalue(1:4));
            mo = str2num (tvalue(6:7));
            dy = str2num (tvalue(9:10));
            if (index (tvalue, 'T'))
              hh = str2num (tvalue(12:13));
              mm = str2num (tvalue(15:16));
              ss = str2num (tvalue(18:19));
              rawarr(ii-trow+1, jj-lcol+1) = datenum (yr, mo, dy, hh, mm, ss);
            else
              rawarr(ii-trow+1, jj-lcol+1) = datenum (yr, mo, dy);
            endif
          case 'time'
            # Dive into TableTable API
            tvalue = ocell.getOdfElement ().getOfficeTimeValueAttribute ();
            if (index (tvalue, 'PT'))
              hh = str2num (tvalue(3:4));
              mm = str2num (tvalue(6:7));
              ss = str2num (tvalue(9:10));
              rawarr(ii-trow+1, jj-lcol+1) = datenum (0, 0, 0, hh, mm, ss);
            endif
          case 'boolean'
            rawarr(ii-trow+1, jj-lcol+1) = ocell.getBooleanValue ();
          case 'string'
            rawarr(ii-trow+1, jj-lcol+1) = ocell.getStringValue ();
#            # Code left in for in case odfdom 0.8.6+ has similar bug
#            # as 0.7.5
#            cvalue = tcell.getOfficeStringValueAttribute ();
#            if (isempty (cvalue))     # Happens with e.g., hyperlinks
#              tmp = char (tcell);
#              # Hack string value from between <text:p|r> </text:p|r> tags
#              ist = findstr (tmp, '<text:');
#              if (ist)
#                ist = ist (length (ist));
#                ist = ist + 8;
#                ien = index (tmp(ist:end), '</text') + ist - 2;
#                tmp (ist:ien);
#                cvalue = tmp(ist:ien);
#              endif
#            endif
#            rawarr(ii-trow+1, jj-lcol+1)= cvalue;
          case 'formula'
            rawarr(ii-trow+1, jj-lcol+1) = ocell.getFormula ();
          otherwise
            # Nothing.
        endswitch
      endif
    endfor
  endfor

  # Keep track of data rectangle limits
  ods.limits = [lcol, rcol; trow, brow];

endfunction


#===========================================================================

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

## ods2oct - get data out of an ODS spreadsheet into octave using jOpenDocument.
## Watch out, no error checks, and spreadsheet formula error results
## are conveyed as 0 (zero).
##
## Author: Philip Nienhuis
## Created: 2009-12-13
## Last updates:

## 2010-08-12 Added separate stanzas for jOpenDocument v 1.2b3 and up. This version
##            allows better cell type parsing and is therefore more reliable
## 2010-10-27 Moved cropping rawarr from empty outer rows & columns to here
## 2010-11-13 Added workaround for reading text cells in files made by jOpenDocument 1.2bx
## 2011-09-18 Comment out workaround for jOpenDocument bug (no OfficeValueAttr set)
##            because this casts all numeric cells to string type for properly written ODS1.2
##     ''     Remove rstatus var (now set in caller)
## 2012-02-25 Fix reading string values written by JOD itself (no text attribue!!). But
##            the cntents could be BOOLEAN as well (JOD doesn't write OffVal attr either)
## 2012-02-26 Further workaround for reading strings (actually: cells w/o OfficeValueAttr)

function [ rawarr, ods] = ods2jod2oct (ods, wsh, crange)

  persistent months;
  months = {"JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"};

  # Check jOpenDocument version
  sh = ods.workbook.getSheet (0);
  cl = sh.getCellAt (0, 0);
  if (ods.odfvsn == 3)
    # 1.2b3+ has public getValueType ()
    persistent ctype;
    if (isempty (ctype))
      BOOLEAN    = char (java_get ('org.jopendocument.dom.ODValueType', 'BOOLEAN'));
      CURRENCY   = char (java_get ('org.jopendocument.dom.ODValueType', 'CURRENCY'));
      DATE       = char (java_get ('org.jopendocument.dom.ODValueType', 'DATE'));
      FLOAT      = char (java_get ('org.jopendocument.dom.ODValueType', 'FLOAT'));
      PERCENTAGE = char (java_get ('org.jopendocument.dom.ODValueType', 'PERCENTAGE'));
      STRING     = char (java_get ('org.jopendocument.dom.ODValueType', 'STRING'));
      TIME       = char (java_get ('org.jopendocument.dom.ODValueType', 'TIME'));
    endif
#  else
#    # 1.2b2 has not
#    ver = 2;
  endif

  if (isnumeric (wsh)) wsh = wsh - 1; endif   # Sheet INDEX starts at 0
  # Check if sheet exists. If wsh = numeric, nonexistent sheets throw errors.
  try
    sh  = ods.workbook.getSheet (wsh);
  catch
    error ("Illegal sheet number (%d) requested for file %s\n", wsh+1, ods.filename);
  end_try_catch
  # If wsh = string, nonexistent sheets yield empty results
  if (isempty (sh))
    error ("No sheet called '%s' present in file %s\n", wsh, ods.filename);
  endif

  # Either parse (given cell range) or prepare (unknown range) help variables 
  if (isempty (crange))
    if (ods.odfvsn < 3)
      error ("No empty read range allowed in jOpenDocument version 1.2b2")
    else
      if (isnumeric (wsh)) wsh = wsh + 1; endif
      [ trow, brow, lcol, rcol ] = getusedrange (ods, wsh);
      nrows = brow - trow + 1;  # Number of rows to be read
      ncols = rcol - lcol + 1;  # Number of columns to be read
    endif
  else
    [dummy, nrows, ncols, trow, lcol] = parse_sp_range (crange);
    # Check ODS column limits
    if (lcol > 1024 || trow > 65536) 
      error ("ods2oct: invalid range; max 1024 columns & 65536 rows."); 
    endif
    # Truncate range silently if needed
    rcol = min (lcol + ncols - 1, 1024);
    ncols = min (ncols, 1024 - lcol + 1);
    nrows = min (nrows, 65536 - trow + 1);
    brow= trow + nrows - 1;
  endif
  # Create storage for data content
  rawarr = cell (nrows, ncols);

  if (ods.odfvsn >= 3) 
    # Version 1.2b3+
    for ii=1:nrows
      for jj = 1:ncols
        try
          scell = sh.getCellAt (lcol+jj-2, trow+ii-2);
          sctype = char (scell.getValueType ());
          switch sctype
            case { FLOAT, CURRENCY, PERCENTAGE }
              rawarr{ii, jj} = scell.getValue ().doubleValue ();
            case BOOLEAN
              rawarr {ii, jj} = scell.getValue () == 1;
            case STRING
              rawarr{ii, jj} = scell.getValue();
            case DATE
              tmp = strsplit (char (scell.getValue ()), ' ');
              yy = str2num (tmp{6});
              mo = find (ismember (months, toupper (tmp{2})) == 1);
              dd = str2num (tmp{3});
              hh = str2num (tmp{4}(1:2));
              mi = str2num (tmp{4}(4:5));
              ss = str2num (tmp{4}(7:8));
              rawarr{ii, jj} = datenum (yy, mo, dd, hh, mi, ss);
            case TIME
              tmp = strsplit (char (scell.getValue ().getTime ()), ' ');
              hh = str2num (tmp{4}(1:2)) /    24.0;
              mi = str2num (tmp{4}(4:5)) /  1440.0;
              ss = str2num (tmp{4}(7:8)) / 86600.0;
              rawarr {ii, jj} = hh + mi + ss;
            otherwise
              # Workaround for sheets written by jOpenDocument (no value-type attrb):
              if (~isempty (scell.getValue) )
                # FIXME Assume cell contains string if there's a text attr. But it could be BOOLEAN too...
                if (findstr ('<text:', char (scell))), sctype = STRING; endif
                rawarr{ii, jj} = scell.getValue();
              endif
              # Nothing
          endswitch
        catch
          # Probably a merged cell, just skip
          # printf ("Error in row %d, col %d (addr. %s)\n", ii, jj, calccelladdress (lcol+jj-2, trow+ii-2));
        end_try_catch
      endfor
    endfor
  else  # ods.odfvsn == 3
    # 1.2b2
    for ii=1:nrows
      for jj = 1:ncols
        celladdress = calccelladdress (trow+ii-1, lcol+jj-1);
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

  endif  

  # Keep track of data rectangle limits
  ods.limits = [lcol, rcol; trow, brow];

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

## ods2uno2oct

## Author: Philip Nienhuis <prnienhuis@users.sf.net>
## Created: 2011-05-05
## Updates:
## 2011-09-18 Adapted sh_names type to LO 3.4.1
##     ''     Remove default 2 last sheets (LibreOffice 3.4.+)
##     ''     Remove rstatus var (now set in caller)
## 2011-09-19 Try to decipher if formulas return numeric or string values

function [rawarr, ods] = ods2uno2oct  (ods, wsh, datrange, spsh_opts)

  sheets = ods.workbook.getSheets ();
  sh_names = sheets.getElementNames ();
  if (! iscell (sh_names))
    # Java array (LibreOffice 3.4.+); convert to cellstr
    sh_names = char (sh_names);
  else
    sh_names = {sh_names};
  endif

  # Check sheet pointer
  if (isnumeric (wsh))
    if (wsh < 1 || wsh > numel (sh_names))
      error ("Sheet index %d out of range 1-%d", wsh, numel (sh_names));
    endif
  else
    ii = strmatch (wsh, sh_names);
    if (isempty (ii)), error ("Sheet '%s' not found", wsh); endif
    wsh = ii;
  endif
  unotmp = java_new ('com.sun.star.uno.Type', 'com.sun.star.sheet.XSpreadsheet');
  sh = sheets.getByName (sh_names{wsh}).getObject.queryInterface (unotmp);

  unotmp = java_new ('com.sun.star.uno.Type', 'com.sun.star.sheet.XCellRangesQuery');
  xRQ = sh.queryInterface (unotmp);
  # Get cell ranges of all rectangles containing data. Type values:
  #java_get ('com.sun.star.sheet.CellFlags', 'VALUE')  ans =  1
  #java_get ('com.sun.star.sheet.CellFlags', 'DATETIME')  ans =  2
  #java_get ('com.sun.star.sheet.CellFlags', 'STRING')  ans =  4
  #java_get ('com.sun.star.sheet.CellFlags', 'FORMULA')  ans =  16
  # Yep, boolean is lacking...
  Cellflgs = javaObject ("java.lang.Short", "23");
  ccells = xRQ.queryContentCells (Cellflgs);
  addrs = ccells.getRangeAddressesAsString ();

  # Strip sheet name from addresses
  adrblks = strsplit (addrs, ',');
  if (isempty (adrblks))
    warning ('Sheet %s contains no data', sh_names{wsh});
    return
  endif

  # Either parse (given cell range) or prepare (unknown range) help variables.
  # As OpenOffice knows the occupied range, we need the limits anyway to avoid
  # out-of-range errors
  [ trow, brow, lcol, rcol ] = getusedrange (ods, wsh);
  if (isempty (datrange))
    nrows = brow - trow + 1;  # Number of rows to be read
    ncols = rcol - lcol + 1;  # Number of columns to be read
  else
    [dummy, nrows, ncols, srow, scol] = parse_sp_range (datrange);
    # Truncate range silently if needed
    brow = min (srow + nrows - 1, brow);
    rcol = min (scol + ncols - 1, rcol);
    trow = max (trow, srow);
    lcol = max (lcol, scol);
    nrows = min (brow - trow + 1, nrows);  # Number of rows to be read
    ncols = min (rcol - lcol + 1, ncols);  # Number of columns to be read
  endif
  # Create storage for data at Octave side
  rawarr = cell (nrows, ncols);

  # Get data. Apparently row & column indices are 0-based in UNO
  for ii=trow-1:brow-1
    for jj=lcol-1:rcol-1
      XCell = sh.getCellByPosition (jj, ii);
      cType = XCell.getType().getValue ();
      switch cType
        case 1  # Value
          rawarr{ii-trow+2, jj-lcol+2} = XCell.getValue ();
        case 2  # String
          unotmp = java_new ('com.sun.star.uno.Type', 'com.sun.star.text.XText');
          rawarr{ii-trow+2, jj-lcol+2} = XCell.queryInterface (unotmp).getString ();
        case 3  # Formula
          if (spsh_opts.formulas_as_text)
            rawarr{ii-trow+2, jj-lcol+2} = XCell.getFormula ();
          else
            # Unfortunately OOo gives no clue as to the type of formula result
            unotmp = java_new ('com.sun.star.uno.Type', 'com.sun.star.text.XText');
            rawarr{ii-trow+2, jj-lcol+2} = XCell.queryInterface (unotmp).getString ();
            tmp = str2double (rawarr{ii-trow+2, jj-lcol+2});
            # If the string happens to contain just a number we'll assume it is numeric
            if (~isnan (tmp)); rawarr{ii-trow+2, jj-lcol+2} = tmp; endif
          endif
        otherwise
          # Empty cell
      endswitch
    endfor
  endfor 

  # Keep track of data rectangle limits
  ods.limits = [lcol, rcol; trow, brow];

endfunction
