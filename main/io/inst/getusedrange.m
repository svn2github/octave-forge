## Copyright (C) 2010,2011,2012 Philip Nienhuis <pr.nienhuis@users.sf.net>
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
    ## @deftypefn {Function File} [ @var{toprow#}, @var{bottomrow#}, @var{leftcol#}, @var{rightcol#} ] = getusedrange (@var{spptr}, @var{shindex#})
    ## Find occupied data range in worksheet @var{shindex#} in a spreadsheet
    ## pointed to in struct @var{spptr} (either MS-Excel or
    ## OpenOffice_org Calc).
    ##
    ## @var{shindex#} must be numeric and is 1-based. @var{spptr} can either
    ## refer to an MS-Excel spreadsheet (spptr returned by xlsopen) or an
    ## OpenOffice.org Calc spreadsheet (spptr returned by odsopen).
    ## None of these inputs are checked!
    ##
    ## Be aware that especially for OpenOffice.org Calc (ODS) spreadsheets 
    ## the results can only be obtained by counting all cells in all rows;
    ## this can be fairly time-consuming. Reliable ods data size results can
    ## only be obtained using UNO interface.
    ## For the ActiveX (COM) interface the underlying Visual Basic call relies
    ## on cached range values and counts empty cells with only formatting too,
    ## so COM returns only approximate (but then usually too big) range values.
    ##
    ## Examples:
    ##
    ## @example
    ##   [trow, brow, lcol, rcol] = getusedrange (ods2, 3);
    ##   (which returns the outermost row & column numbers of the rectangle
    ##    enveloping the occupied cells in the third sheet of an OpenOffice_org
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
    ## @seealso {xlsopen, xlsclose, odsopen, odsclose, xlsfinfo, odsfinfo}
    ##
    ## @end deftypefn
    
    ## Author: Philip Nienhuis <philip@JVC741>
    ## Created: 2010-03-18 (First usable version) for ODS (java/OTK)
    ## Updates:
    ## 2010-03-20 Added Excel support (Java/POI)
    ## 2010-05-23 Added in support for jOpenDocument ODS
    ## 2010-05-31 Fixed bugs in getusedrange_jod.m
    ## 2010-08-24 Added support for odfdom 0.8.6 (ODF Toolkit)
    ## 2010-08-27 Added checks for input arguments
    ##     ''     Indentation changed from tab to doublespace
    ## 2010-10-07 Added COM support (at last!)
    ## 2011-05-06 Experimental support for Java/UNO bridge
    ## 2011-06-13 OpenXLS support added
    ## 2011-09-08 Style & layout updates
    ## 2012-01-26 Fixed "seealso" help string
    ## 2012-06-08 Replaced tabs by double space
    ##     ''     Added COM and OXS to message about supported interfaces
    ##
    ## Last subfunc update: 2012-06-08 (OTK)
    
    function [ trow, lrow, lcol, rcol ] = getusedrange (spptr, ii)
    
      # Some checks
      if ~isstruct (spptr), error ("Illegal spreadsheet pointer argument"); endif
    
      if (strcmp (spptr.xtype, 'OTK'))
        [ trow, lrow, lcol, rcol ] = getusedrange_otk (spptr, ii);
      elseif (strcmp (spptr.xtype, 'JOD'))
        [ trow, lrow, lcol, rcol ] = getusedrange_jod (spptr, ii);
      elseif (strcmp (spptr.xtype, 'UNO'))
        [ trow, lrow, lcol, rcol ] = getusedrange_uno (spptr, ii);
      elseif (strcmp (spptr.xtype, 'COM'))
        [ trow, lrow, lcol, rcol ] = getusedrange_com (spptr, ii);
      elseif (strcmp (spptr.xtype, 'POI'))
        [ trow, lrow, lcol, rcol ] = getusedrange_poi (spptr, ii);
      elseif (strcmp (spptr.xtype, 'JXL'))
        [ trow, lrow, lcol, rcol ] = getusedrange_jxl (spptr, ii);
      elseif (strcmp (spptr.xtype, 'OXS'))
        [ trow, lrow, lcol, rcol ] = getusedrange_oxs (spptr, ii);
      else
        error ("Only OTK, JOD, COM, POI, JXL and OXS interface implemented");
      endif
    
    endfunction
    
    
    ## Copyright (C) 2010,2011,2012 Philip Nienhuis, pr.nienhuis -at- users.sf.net
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
    
    ## getusedrange_otk - get used range from ODS spreadsheet using ODF Toolkit
    
    ## Author: Philip Nienhuis <philip@JVC741>
    ## Created: 2010-03-18 (First usable version)
    ## Updates:
    ## 2010-08-24 Support for odfdom (ODF Toolkit) 0.8.6 checked; we still need 
    ##            => TableTable API because 0.8.6 is fooled by empty lowermost
    ##            filler rows comprising number-rows-repeated table attribute :-(
    ##     ''     Indentation changed from tab to double space
    ## 2010-11-13 Catched jOpenDocument bug (1.2bx) where string cells have no office:value-type
    ##            attrib set (by JOD). Somehow OTK is more robust as it catches these cells;
    ##            Currently this fix is just commented.
    ## 2011-06-06 Fixed wrong if clause for finding last filler cells (L.160 & L.176)
    ## 2011-09-12 Support for odfdom-0.8.7 added (API change for XPATH)
    ## 2012-06-08 Support for odsfdom-0.8.8-incubator
    
    function [ trow, lrow, lcol, rcol ] = getusedrange_otk (ods, ii)
    
      odfcont = ods.workbook;  # Local copy just in case
    
      if (isfield (ods, 'odfvsn'))
        if (strcmp (ods.odfvsn, '0.8.6') || strcmp (ods.odfvsn, '0.7.5'))
          xpath = ods.app.getXPath;
        else
          # API changed in odfdom-0.8.7
          xpath = ods.workbook.getXPath;
        endif
      else
        error ("ODS file ptr struct for OTK interface seems broken.");
      endif
      
      # Create an instance of type NODESET for use in subsequent statement
      NODESET = java_get ('javax.xml.xpath.XPathConstants', 'NODESET');
      # Get table-rows in sheet no. wsh. Sheet count = 1-based (!)
      str = sprintf ("//table:table[%d]/table:table-row", ii);
      sh = xpath.evaluate (str, odfcont, NODESET);
      nr_of_trows = sh.getLength();
    
      jj = 0;                  # Table row counter
      trow = 0; drows = 0;     # Top data row, actual data row range
      nrows = 0; reprows = 0;  # Scratch counter
      rcol = 0; lcol = 1024;   # Rightmost and leftmost data column
      while jj < nr_of_trows
        row = sh.item(jj);
        # Check for data rows
        rw_char = char (row) (1:min(500, length (char (row))));
        if (findstr ('office:value-type', rw_char) || findstr ('<text:', rw_char))
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
        # Swap the following lines into comment to catch a jOpenDocument bug which foobars OTK
        # (JOD doesn't set <office:value-type='string'> attribute when writing strings
          #if (isempty (findstr ('office:value-type', cl_char)) || isempty (findstr ('<text:', cl_char)))
          if (isempty (findstr ('office:value-type', cl_char)))
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
            if (isempty (findstr ('office:value-type', char (lcell))) || isempty (findstr ('<text:', char (lcell))))
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
    
    ## Copyright (C) 2010,2011,2012 Philip Nienhuis <prnienhuis -aT- users.sf.net>
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
    
    ## getusedrange_jod
    
    ## Author: Philip <Philip@DESKPRN>
    ## Created: 2010-05-25
    ## Last updates:
    ## 2010-05-31 Fixed ignoring table-covered-cells; fixed count of sheets comprising just A1:A1
    ##            Added option for wsh being a string argument 
    ## 2010-08-12 Little textual adaptations
    ## 2010-11-13 Catched jOpenDocument bug (1.2bx) where string cells have no office:value-type
    ##     ''     attrb set (by JOD). Somehow OTK is more robust as it catches these cells
    ## 2012-04-09 Fixed rowrepcnt (str2num not applied to tablerow)
    ## 2012-04-18 Added getUsedRange() method for JOD 1.3x and above 
    
    function [ trow, brow, lcol, rcol ] = getusedrange_jod (ods, wsh)
    
      # This function works by virtue of sheets in JOD actually being a Java string.
      # It works outside of the Java memory/heap space which is an added benefit...
      # (Read: this is one big dirty hack...... prone to crash Java on BIG spreadsheets)
    
      if (isnumeric (wsh))
        sh = char (ods.workbook.getSheet (wsh - 1));
      else
        sh = char (ods.workbook.getSheet (wsh));
      endif
    
      try
        # Let's see if we have JOD v. 1.3x. If not, next call fails & we'll fall back to the old hack
        sh_rng = char (sh.getUsedRange ());
        if (isempty (sh_rng))
          # Empty sheet
          trow = brow = lcol = rcol = 0;
        else
          # Strip sheet name
          sh_rng = sh_rng(length (sh.getName) + 2 : end);
          # Get rid of period
          sh_rng = strrep (sh_rng, '.', '');
          [~, nr, nc, trow, lcol] = parse_sp_range (sh_rng);
          brow = trow + nr - 1;
          rcol = lcol + nc - 1;
        endif
      
      catch
        # Fall back to the old hack :-(
        sh = char (sh);
    
        # 1. Get table-row pointers
        id_trow = strfind (sh, '<table:table-row');
        id = strfind (sh, '</table:table>') - 1;
        id_trow = [id_trow id];
    
        trow = rcol = 0;
        lcol = 1024; brow = 0;
        if (~isempty (id))
          # 2. Loop over all table-rows
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
              rowrepcnt += str2num (tablerow(rowrept+st-1:min (rowend, rowrept+en-1))) - 1;
            endif
    
            # 3. Search table-cells. table-c is a table-covered-cell that is considered empty
            id_tcell = strfind (tablerow, '<table:table-c');
            if (~isempty (id_tcell))
              # OK, this row has a value cell. Now table-covered-cells must be included.
              id_tcell2 = strfind (tablerow, '<table:covered-t');
              if (~isempty (id_tcell2)) id_tcell = sort ([id_tcell id_tcell2]); endif
              id_tcell = [id_tcell rowl];
              # Search for non-empty cells (i.e., with an office:value-type attribute). But:
              # jOpenDocument 1.2b3 has a bug: it often doesn't set this attr for string cells
              id_valtcell = strfind (tablerow, 'office:value-type=');
              id_textonlycell = strfind (tablerow, '<text:');
              id_valtcell = sort ([id_valtcell id_textonlycell]);
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
                ii = 1;       # Indexes cannot be negative
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
    
      end_try_catch
    
    endfunction
    
    
    ## Copyright (C) 2011,2012 Philip Nienhuis
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
    
    ## getusedrange_uno
    
    ## Author: Philip Nienhuis <prnienhuis@users.sf.net>
    ## Created: 2011-05-06
    ## Updates:
    ## 2011-06-29 Fixed wrong address range inference in case of sheet names containing period(s)
    ## 2012-03-02 Adapted code to assess nr of range blocks to ';' separator fo LO3.5+
    
    function [ srow, erow, scol, ecol ] = getusedrange_uno (ods, ii)
    
      # Get desired sheet
      sheets = ods.workbook.getSheets ();
      sh_names = sheets.getElementNames ();
      unotmp = java_new ('com.sun.star.uno.Type', 'com.sun.star.sheet.XSpreadsheet');
      sh = sheets.getByName(sh_names(ii)).getObject.queryInterface (unotmp);
    
      # Prepare cell range query
      unotmp = java_new ('com.sun.star.uno.Type', 'com.sun.star.sheet.XCellRangesQuery');
      xRQ = sh.queryInterface (unotmp);
      Cellflgs = javaObject ("java.lang.Short", "23");
      ccells = xRQ.queryContentCells (Cellflgs);
    
      # Get addresses of all blocks containing data
      addrs = ccells.getRangeAddressesAsString ();
    
      # Strip sheet name from addresses. Watch out, in LO3.5 they changed
      # the separator from ',' to ';' (without telling me!)
      # 1. Get nr of range blocks
      nblks = numel (strfind (addrs, sh_names(ii)));
      # 2. First try with ',' separator...
      adrblks = strsplit (addrs, ',');
      if (numel (adrblks) < nblks)
        # Apparently we have a ';' separator, so try with semicolon
        adrblks = strsplit (addrs, ';');
      endif
      if (isempty (adrblks))
        srow = erow = scol = ecol = 0;
        return
      endif
    
      # Find leftmost & rightmost columns, and highest and lowest row with data
      srow = scol = 1e10;
      erow = ecol = 0;
      for ii=1:numel (adrblks)
        # Check if address contains a sheet name in quotes (happens if name contains a period)
        if (int8 (adrblks{ii}(1)) == 39)
          # Strip sheet name part
          idx = findstr (adrblks{ii}, "'.");
          range = adrblks{ii}(idx+2 : end);
        else
          # Same, but tru strsplit()
          range = strsplit (adrblks{ii}, '.'){2};
        endif
        [dummy, nrows, ncols, trow, lcol] = parse_sp_range (range);
        brow = trow + nrows - 1;
        rcol = lcol + ncols - 1;
        srow = min (srow, trow);
        scol = min (scol, lcol);
        erow = max (erow, brow);
        ecol = max (ecol, rcol);
      endfor
    
    endfunction
    
    
    ## Copyright (C) 2010,2011,2012 Philip Nienhuis
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
    
    ## getusedrange_com
    
    ## Author: Philip Nienhuis <prnienhuis@users.sf.net>
    ## Created: 2010-10-07
    
    function [ trow, brow, lcol, rcol ] = getusedrange_com (xls, ii)
    
      sh = xls.workbook.Worksheets (ii);
      
      # Decipher used range. Beware, UsedRange() returns *cached* rectangle of
      # all spreadsheet cells containing *anything*, including just formatting
      # (i.e., empty cells are included too). ==> This is an approximation only
      allcells = sh.UsedRange;
      
      # Get top left cell as a Range object
      toplftcl = allcells.Columns(1).Rows(1);
      
      # Count number of rows & cols in virtual range from A1 to top left cell
      lcol = sh.Range ("A1", toplftcl).columns.Count;
      trow = sh.Range ("A1", toplftcl).rows.Count;
      
      # Add real occupied rows & cols to obtain end row & col
      brow = trow + allcells.rows.Count() - 1;
      rcol = lcol + allcells.columns.Count() - 1;
      
      # Check if there are real data
      if ((lcol == rcol) && (trow = brow))
        if (isempty (toplftcl.Value))
          trow = brow = lcol = rcol = 0;
        endif
      endif
    
    endfunction
    
    
    ## Copyright (C) 2010,2011,2012 Philip Nienhuis, prnienhuis at users.sf.net
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
    
    ## getusedrange_poi - get range of occupied data cells from Excel using java/POI
    
    ## Author: Philip <Philip@DESKPRN>
    ## Created: 2010-03-20
    
    function [ trow, brow, lcol, rcol ] = getusedrange_poi (xls, ii)
    
      persistent cblnk; cblnk = java_get ('org.apache.poi.ss.usermodel.Cell', 'CELL_TYPE_BLANK');
    
      sh = xls.workbook.getSheetAt (ii-1);         # Java POI starts counting at 0 
    
      trow = sh.getFirstRowNum ();                 # 0-based
      brow = sh.getLastRowNum ();                  # 0-based
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
        brow = min (brow, botrow) + 1; ++trow; ++lcol; ++rcol;    # 1-based return values
      endif
    
    endfunction
    
    
    ## Copyright (C) 2010,2011,2012 Philip Nienhuis, prnienhuis at users.sf.net
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
    
    ## getusedrange_jxl - get occupied data cell range from Excel sheet
    ## using java/JExcelAPI
    
    ## Author: Philip <Philip@DESKPRN>
    ## Created: 2010-03-20
    
    function [ trow, brow, lcol, rcol ] = getusedrange_jxl (xls, wsh)
    
      persistent emptycell = (java_get ('jxl.CellType', 'EMPTY')).toString ();
    
      sh = xls.workbook.getSheet (wsh - 1);      # JXL sheet count 0-based
    
      brow = sh.getRows ();
      rcol = sh.getColumns ();
      
      if (brow == 0 || rcol == 0)
        # Empty sheet
        trow = 0; lcol = 0; brow = 0; rcol = 0;
      else
        trow = brow + 1;
        lcol = rcol + 1;
        for ii=0:brow-1    # For loop coz we must check ALL rows for leftmost column
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
    
    
    ## Copyright (C) 2010,2011,2012 Philip Nienhuis, <prnienhuis at users.sf.net>
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
    
    ## getusedrange_oxs
    
    ## Author: Philip <Philip@DESKPRN>
    ## Created: 2011-06-13
    ## Updates:
    ## 2011-06-29 try-catch to be able to skip non-data (e.g., graph) sheets
    
    function [ trow, brow, lcol, rcol ] = getusedrange_oxs (xls, wsh)
    
      sh = xls.workbook.getWorkSheet (wsh - 1);
      try
        # Intriguing:  sh.getFirst<> is off by one, sh.getLast<> = OK.... 8-Z 
        trow = sh.getFirstRow () + 1;
        brow = sh.getLastRow ();
        lcol = sh.getFirstCol () + 1;
        rcol = sh.getLastCol ();
      catch
        # Might be an empty sheet
        trow = brow = lcol = rcol = 0;
      end_try_catch
      # Check for empty sheet
      if ((trow > brow) || (lcol > rcol)), trow = brow = lcol = rcol = 0; endif
    
    endfunction
    