## Copyright (C) 2009,2010,2011,12 Philip Nienhuis <prnienhuis at users.sf.net>
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
## @deftypefn {Function File} [ @var{rawarr}, @var{xls}, @var{rstatus} ] = xls2oct (@var{xls})
## @deftypefnx {Function File} [ @var{rawarr}, @var{xls}, @var{rstatus} ] = xls2oct (@var{xls}, @var{wsh})
## @deftypefnx {Function File} [ @var{rawarr}, @var{xls}, @var{rstatus} ] = xls2oct (@var{xls}, @var{wsh}, @var{range})
## @deftypefnx {Function File} [ @var{rawarr}, @var{xls}, @var{rstatus} ] = xls2oct (@var{xls}, @var{wsh}, @var{range}, @var{options})
##
## Read data contained within cell range @var{range} from worksheet @var{wsh}
## in an Excel spreadsheet file pointed to in struct @var{xls}.
##
## @var{xls} is supposed to have been created earlier by xlsopen in the
## same octave session.
##
## @var{wsh} is either numerical or text, in the latter case it is 
## case-sensitive and it may be max. 31 characters long.
## Note that in case of a numerical @var{wsh} this number refers to the
## position in the worksheet stack, counted from the left in an Excel
## window. The default is numerical 1, i.e. the leftmost worksheet
## in the Excel file.
##
## @var{range} is expected to be a regular spreadsheet range format,
## or "" (empty string, indicating all data in a worksheet).
## If no range is specified the occupied cell range will have to be
## determined behind the scenes first; this can take some time for the
## Java-based interfaces. Be aware that in Excel/ActiveX interface the
## used range can be outdated. The Java-based interfaces are more 
## reliable in this respect albeit much slower.
##
## Optional argument @var{options}, a structure, can be used to
## specify various read modes by setting option fields in the struct
## to true (1) or false (0). Currently recognized option fields are:
##
## @table @asis
## @item "formulas_as_text"
## If set to TRUE or 1, spreadsheet formulas (if at all present)
## are read as formula strings rather than the evaluated formula
## result values. This only works for the Java based interfaces
## POI, JXL and UNO. The default value is 0 (FALSE).
##
## @item 'strip_array'
## Set the value of this field set to TRUE or 1 to strip the returned
## output array @var{rawarr} from empty outer columns and rows. The
## spreadsheet cell rectangle limits from where the data actually
## came will be updated. The default value is FALSE or 0 (no cropping).
## When using the COM interface, the output array is always cropped.
## @end table
##
## If only the first argument @var{xls} is specified, xls2oct will try
## to read all contents from the first = leftmost (or the only)
## worksheet (as if a range of @'' (empty string) was specified).
## 
## If only two arguments are specified, xls2oct assumes the second
## argument to be @var{wsh}. In that case xls2oct will try to read
## all data contained in that worksheet.
##
## Return argument @var{rawarr} contains the raw spreadsheet cell data.
## Use parsecell() to separate numeric and text values from @var{rawarr}.
##
## Optional return argument @var{xls} contains the pointer struct,
## If any data have been read, field @var{xls}.limits contains the
## outermost column and row numbers of the actually returned cell range.
##
## Optional return argument @var{rstatus} will be set to 1 if the
## requested data have been read successfully, 0 otherwise. 
##
## Erroneous data and empty cells turn up empty in @var{rawarr}.
## Date/time values in Excel are returned as numerical values.
## Note that Excel and Octave have different date base values (1/1/1900 & 
## 1/1/0000, resp.)
## Be aware that Excel trims @var{rawarr} from empty outer rows & columns, 
## so any returned cell array may turn out to be smaller than requested
## in @var{range}, independent of field 'formulas_as_text' in @var{options}.
## When using COM, POI, or UNO interface, formulas in cells are evaluated; if
## that fails cached values are retrieved. These may be outdated depending
## on Excel's "Automatic calculation" settings when the spreadsheet was saved.
##
## When reading from merged cells, all array elements NOT corresponding 
## to the leftmost or upper Excel cell will be treated as if the
## "corresponding" Excel cells are empty.
##
## Beware: when the COM interface is used, hidden Excel invocations may be
## kept running silently in case of COM errors.
##
## Examples:
##
## @example
##   A = xls2oct (xls1, '2nd_sheet', 'C3:AB40');
##   (which returns the numeric contents in range C3:AB40 in worksheet
##   '2nd_sheet' from a spreadsheet file pointed to in pointer struct xls1,
##   into numeric array A) 
## @end example
##
## @example
##   [An, xls2, status] = xls2oct (xls2, 'Third_sheet');
## @end example
##
## @seealso {oct2xls, xlsopen, xlsclose, parsecell, xlsread, xlsfinfo, xlswrite }
##
## @end deftypefn

## Author: Philip Nienhuis
## Created: 2010-10-16
## Updates: 
## 2009-01-03 (added OOXML support & cleaned up code. Excel 
##             ADDRESS function still not implemented in Apache POI)
## 2010-03-14 Updated help text
## 2010-05-31 Updated help text (delay i.c.o. empty range due to getusedrange call)
## 2010-07-28 Added option to read formulas as text strings rather than evaluated value
## 2010-08-25 Small typo in help text
## 2010-10-20 Added option fornot stripping output arrays
## 2010-11-07 More rigorous input checks. 
## 2010-11-12 Moved pointer check into main func
## 2010-11-13 Catch empty sheets when no range was specified
## 2011-03-26 OpenXLS support added
## 2011-03-29 Test for proper input xls struct extended
## 2011-05-18 Experimental UNO support added
## 2011-09-08 Minor code layout
## 2012-01-26 Fixed "seealso" help string
## 2012-02-25 Fixed missing quotes in struct check L.149-153
## 2012-02-26 Updated texinfo header help text
## 2012-06-06 Implemented "formulas_as_text" option for COM
## 2012-06-07 Replaced all tabs by double space
##
## Latest subfunc update: 2012-06-06

function [ rawarr, xls, rstatus ] = xls2oct (xls, wsh=1, datrange='', spsh_opts=[])

  # Check if xls struct pointer seems valid
  if (~isstruct (xls)), error ("File ptr struct expected for arg @ 1"); endif
  test1 = ~isfield (xls, "xtype");
  test1 = test1 || ~isfield (xls, "workbook");
  test1 = test1 || isempty (xls.workbook);
  test1 = test1 || isempty (xls.app);
  test1 = test1 || ~ischar (xls.xtype);
  if test1
    error ("Invalid xls file pointer struct");
  endif

  # Check worksheet ptr
  if (~(ischar (wsh) || isnumeric (wsh))), error ("Integer (index) or text (wsh name) expected for arg # 2"); endif
  # Check range
  if (~(isempty (datrange) || ischar (datrange))), error ("Character string (range) expected for arg # 3"); endif

  # Check & setup options struct
  if (nargin < 4 || isempty (spsh_opts))
    spsh_opts.formulas_as_text = 0;
    spsh_opts.strip_array = 1;
    # Future options:
  elseif (isstruct (spsh_opts))
    if (~isfield (spsh_opts', 'formulas_as_text')), spsh_opts.formulas_as_text = 0; endif
    if (~isfield (spsh_opts', 'strip_array')), spsh_opts.strip_array = 1; endif
    % Future options:
  else
    error ("Structure expected for arg # 4");
  endif

  # Select the proper interfaces
  if (strcmp (xls.xtype, 'COM'))
    # Call Excel tru COM / ActiveX server
    [rawarr, xls, rstatus] = xls2com2oct (xls, wsh, datrange, spsh_opts);
  elseif (strcmp (xls.xtype, 'POI'))
    # Read xls file tru Java POI
    [rawarr, xls, rstatus] = xls2jpoi2oct (xls, wsh, datrange, spsh_opts);
  elseif (strcmp (xls.xtype, 'JXL'))
    # Read xls file tru JExcelAPI
    [rawarr, xls, rstatus] = xls2jxla2oct (xls, wsh, datrange, spsh_opts);
  elseif (strcmp (xls.xtype, 'OXS'))
    # Read xls file tru OpenXLS
    [rawarr, xls, rstatus] = xls2oxs2oct (xls, wsh, datrange, spsh_opts);
  elseif (strcmp (xls.xtype, 'UNO'))
    # Read xls file tru OpenOffice.org UNO (Java) bridge
    [rawarr, xls, rstatus] = xls2uno2oct (xls, wsh, datrange, spsh_opts);
#  elseif ---- <Other interfaces here>
    # Call to next interface
  else
    error (sprintf ("xls2oct: unknown Excel .xls interface - %s.", xls.xtype));
  endif

  # Optionally strip empty outer rows and columns & keep track of original data location
  if (spsh_opts.strip_array)
    emptr = cellfun ('isempty', rawarr);
    if (all (all (emptr)))
      rawarr = {};
      xls.limits = [];
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

      # Crop output cell array and update limits
      rawarr = rawarr(irowt:irowb, icoll:icolr);
      xls.limits = xls.limits + [icoll-1, icolr-ncols; irowt-1, irowb-nrows];
    endif
  endif

endfunction


#====================================================================================
## Copyright (C) 2009,2010,2011,2012 P.R. Nienhuis, <pr.nienhuis at hccnet.nl>
##
## based on mat2xls by Michael Goffioul (2007) <michael.goffioul@swing.be>
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
## @deftypefn {Function File} [@var{obj}, @var{rstatus}, @var{xls} ] = xls2com2oct (@var{xls})
## @deftypefnx {Function File} [@var{obj}, @var{rstatus}, @var{xls} ] = xls2com2oct (@var{xls}, @var{wsh})
## @deftypefnx {Function File} [@var{obj}, @var{rstatus}, @var{xls} ] = xls2com2oct (@var{xls}, @var{wsh}, @var{range})
## @deftypefnx {Function File} [@var{obj}, @var{rstatus}, @var{xls} ] = xls2com2oct (@var{xls}, @var{wsh}, @var{range}, @var{spsh_opts})
## Get cell contents in @var{range} in worksheet @var{wsh} in an Excel
## file pointed to in struct @var{xls} into the cell array @var{obj}. 
##
## xls2com2oct should not be invoked directly but rather through xls2oct.
##
## Examples:
##
## @example
##   [Arr, status, xls] = xls2com2oct (xls, 'Second_sheet', 'B3:AY41');
##   Arr = xls2com2oct (xls, 'Second_sheet');
## @end example
##
## @seealso {xls2oct, oct2xls, xlsopen, xlsclose, xlsread, xlswrite}
##
## @end deftypefn

## Author: Philip Nienhuis
## Created: 2009-09-23
## Last updates:
## 2009-12-11 <forgot what it was>
## 2010-10-07 Implemented limits (only reliable for empty input ranges)
## 2010-10-08 Resulting data array now cropped (also in case of specified range)
## 2010-10-10 More code cleanup (shuffled xls tests & wsh ptr code before range checks)
## 2010-10-20 Slight change to Excel range setup
## 2010-10-24 Added check for "live" ActiveX server
## 2010-11-12 Moved ptr struct check into main func
## 2010-11-13 Catch empty sheets when no range was specified
## 2012-01-26 Fixed "seealso" help string
## 2012-06-06 Implemented "formulas_as_text option"

function [rawarr, xls, rstatus ] = xls2com2oct (xls, wsh, crange, spsh_opts)

  rstatus = 0; rawarr = {};
  
  # Basic checks
  if (nargin < 2) error ("xls2com2oct needs a minimum of 2 arguments."); endif
  if (size (wsh, 2) > 31) 
    warning ("Worksheet name too long - truncated") 
    wsh = wsh(1:31);
  endif
  app = xls.app;
  wb = xls.workbook;
  # Check to see if ActiveX is still alive
  try
    wb_cnt = wb.Worksheets.count;
  catch
    error ("ActiveX invocation in file ptr struct seems non-functional");
  end_try_catch

  # Check & get handle to requested worksheet
  wb_cnt = wb.Worksheets.count;
  old_sh = 0;  
  if (isnumeric (wsh))
    if (wsh < 1 || wsh > wb_cnt)
      errstr = sprintf ("Worksheet number: %d out of range 1-%d", wsh, wb_cnt);
      error (errstr)
      rstatus = 1;
      return
    else
      old_sh = wsh;
    endif
  else
    # Find worksheet number corresponding to name in wsh
    wb_cnt = wb.Worksheets.count;
    for ii =1:wb_cnt
      sh_name = wb.Worksheets(ii).name;
      if (strcmp (sh_name, wsh)) old_sh = ii; endif
    endfor
    if (~old_sh)
      errstr = sprintf ("Worksheet name \"%s\" not present", wsh);
      error (errstr)
    else
      wsh = old_sh;
    endif
  endif
  sh = wb.Worksheets (wsh);    

  nrows = 0;
  if ((nargin == 2) || (isempty (crange)))
    allcells = sh.UsedRange;
    # Get actually used range indices
    [trow, brow, lcol, rcol] = getusedrange (xls, old_sh);
    if (trow == 0 && brow == 0)
      # Empty sheet
      rawarr = {};
      printf ("Worksheet '%s' contains no data\n", sh.Name);
      return;
    else
      nrows = brow - trow + 1; ncols = rcol - lcol + 1;
      topleft = calccelladdress (trow, lcol);
      lowerright = calccelladdress (brow, rcol);
      crange = [topleft ':' lowerright];
    endif
  else
    # Extract top_left_cell from range
    [topleft, nrows, ncols, trow, lcol] = parse_sp_range (crange);
    brow = trow + nrows - 1;
    rcol = lcol + ncols - 1;
  endif;
  
  if (nrows >= 1) 
    # Get object from Excel sheet, starting at cell top_left_cell
    rr = sh.Range (crange);
    if (spsh_opts.formulas_as_text)
      rawarr = rr.Formula;
    else
      rawarr = rr.Value;
    endif
    delete (rr);

    # Take care of actual singe cell range
    if (isnumeric (rawarr) || ischar (rawarr))
      rawarr = {rawarr};
    endif

    # If we get here, all seems to have gone OK
    rstatus = 1;
    # Keep track of data rectangle limits
    xls.limits = [lcol, rcol; trow, brow];
  else
    error ("No data read from Excel file");
    rstatus = 0;
  endif
  
endfunction


#==================================================================================

## Copyright (C) 2009,2010,2011,2012 Philip Nienhuis <prnienhuis at users.sf.net>
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
## @deftypefn {Function File} [@var{obj}, @var{rstatus}, @var{xls} ] = xls2jpoi2oct (@var{xls})
## @deftypefnx {Function File} [@var{obj}, @var{rstatus}, @var{xls} ] = xls2jpoi2oct (@var{xls}, @var{wsh})
## @deftypefnx {Function File} [@var{obj}, @var{rstatus}, @var{xls} ] = xls2jpoi2oct (@var{xls}, @var{wsh}, @var{range})
## Get cell contents in @var{range} in worksheet @var{wsh} in an Excel
## file pointed to in struct @var{xls} into the cell array @var{obj}.
## @var{range} can be a range or just the top left cell of the range.
##
## xls2jpoi2oct should not be invoked directly but rather through xls2oct.
##
## Examples:
##
## @example
##   [Arr, status, xls] = xls2jpoi2oct (xls, 'Second_sheet', 'B3:AY41');
##   B = xls2jpoi2oct (xls, 'Second_sheet', 'B3');
## @end example
##
## @seealso {xls2oct, oct2xls, xlsopen, xlsclose, xlsread, xlswrite, oct2jpoi2xls}
##
## @end deftypefn

## Author: Philip Nienhuis
## Created: 2009-11-23
## Updates: 
## 2010-01-11 Fall back to cached values when formula evaluator fails
## 2010-03-14 Fixed max column nr for OOXML for empty given range
## 2010-07-28 Added option to read formulas as text strings rather than evaluated value
## 2010-08-01 Some bug fixes for formula reading (cvalue rather than scell)
## 2010-10-10 Code cleanup: -getusedrange called; - fixed typo in formula evaluation msg;
##     ''     moved cropping output array to calling function.
## 2010-11-12 Moved ptr struct check into main func
## 2010-11-13 Catch empty sheets when no range was specified
## 2010-11-14 Fixed sheet # index (was offset by -1) in call to getusedrange() in case
##            of text sheet name arg
## 2012-01-26 Fixed "seealso" help string

function [ rawarr, xls, rstatus ] = xls2jpoi2oct (xls, wsh, cellrange, spsh_opts)

  persistent ctype;
  if (isempty (ctype))
    # Get enumerated cell types. Beware as they start at 0 not 1
    ctype(1) = java_get ('org.apache.poi.ss.usermodel.Cell', 'CELL_TYPE_NUMERIC');
    ctype(2) = java_get ('org.apache.poi.ss.usermodel.Cell', 'CELL_TYPE_STRING');
    ctype(3) = java_get ('org.apache.poi.ss.usermodel.Cell', 'CELL_TYPE_FORMULA');
    ctype(4) = java_get ('org.apache.poi.ss.usermodel.Cell', 'CELL_TYPE_BLANK');
    ctype(5) = java_get ('org.apache.poi.ss.usermodel.Cell', 'CELL_TYPE_BOOLEAN');
    ctype(6) = java_get ('org.apache.poi.ss.usermodel.Cell', 'CELL_TYPE_ERROR');
  endif
  
  rstatus = 0; jerror = 0;
  wb = xls.workbook;

  # Check if requested worksheet exists in the file & if so, get pointer
  nr_of_sheets = wb.getNumberOfSheets ();
  if (isnumeric (wsh))
    if (wsh > nr_of_sheets), error (sprintf ("Worksheet # %d bigger than nr. of sheets (%d) in file %s", wsh, nr_of_sheets, xls.filename)); endif
    sh = wb.getSheetAt (wsh - 1);      # POI sheet count 0-based
    printf ("(Reading from worksheet %s)\n",   sh.getSheetName ());
  else
    sh = wb.getSheet (wsh);
    if (isempty (sh)), error (sprintf ("Worksheet %s not found in file %s", wsh, xls.filename)); endif
  end

  # Check ranges
  firstrow = sh.getFirstRowNum ();    # 0-based
  lastrow = sh.getLastRowNum ();      # 0-based
  if (isempty (cellrange))
    if (ischar (wsh))
      # get numeric sheet index
      ii = wb.getSheetIndex (sh) + 1;
    else
      ii = wsh;
    endif
    [ firstrow, lastrow, lcol, rcol ] = getusedrange (xls, ii);
    if (firstrow == 0 && lastrow == 0)
      # Empty sheet
      rawarr = {};
      printf ("Worksheet '%s' contains no data\n", sh.getSheetName ());
      rstatus = 1;
      return;
    else
      nrows = lastrow - firstrow + 1;
      ncols = rcol - lcol + 1;
    endif
  else
    # Translate range to HSSF POI row & column numbers
    [topleft, nrows, ncols, firstrow, lcol] = parse_sp_range (cellrange);
    lastrow = firstrow + nrows - 1;
    rcol = lcol + ncols - 1;
  endif

  # Create formula evaluator (needed to infer proper cell type into rawarr)
  frm_eval = wb.getCreationHelper().createFormulaEvaluator ();
  
  # Read contents into rawarr
  rawarr = cell (nrows, ncols);      # create placeholder
  for ii = firstrow:lastrow
    irow = sh.getRow (ii-1);
    if ~isempty (irow)
      scol = (irow.getFirstCellNum).intValue ();
      ecol = (irow.getLastCellNum).intValue () - 1;
      for jj = lcol:rcol
        scell = irow.getCell (jj-1);
        if ~isempty (scell)
          # Explore cell contents
          type_of_cell = scell.getCellType ();
          if (type_of_cell == ctype(3))        # Formula
            if ~(spsh_opts.formulas_as_text)
              try    # Because not al Excel formulas have been implemented in POI
                cvalue = frm_eval.evaluate (scell);
                type_of_cell = cvalue.getCellType();
                # Separate switch because form.eval. yields different type
                switch type_of_cell
                  case ctype (1)  # Numeric
                    rawarr {ii+1-firstrow, jj+1-lcol} = scell.getNumberValue ();
                  case ctype(2)  # String
                    rawarr {ii+1-firstrow, jj+1-lcol} = char (scell.getStringValue ());
                  case ctype (5)  # Boolean
                    rawarr {ii+1-firstrow, jj+1-lcol} = scell.BooleanValue ();
                  otherwise
                    # Nothing to do here
                endswitch
                # Set cell type to blank to skip switch below
                type_of_cell = ctype(4);
              catch
                # In case of formula errors we take the cached results
                type_of_cell = scell.getCachedFormulaResultType ();
                ++jerror;   # We only need one warning even for multiple errors 
              end_try_catch
            endif
          endif
          # Preparations done, get data values into data array
          switch type_of_cell
            case ctype(1)    # 0 Numeric
              rawarr {ii+1-firstrow, jj+1-lcol} = scell.getNumericCellValue ();
            case ctype(2)    # 1 String
              rawarr {ii+1-firstrow, jj+1-lcol} = char (scell.getRichStringCellValue ());
            case ctype(3)
              if (spsh_opts.formulas_as_text)
                tmp = char (scell.getCellFormula ());
                rawarr {ii+1-firstrow, jj+1-lcol} = ['=' tmp];
              endif
            case ctype(4)    # 3 Blank
              # Blank; ignore until further notice
            case ctype(5)    # 4 Boolean
              rawarr {ii+1-firstrow, jj+1-lcol} = scell.getBooleanCellValue ();
            otherwise      # 5 Error
              # Ignore
          endswitch
        endif
      endfor
    endif
  endfor

  if (jerror > 0) warning (sprintf ("xls2oct: %d cached values instead of formula evaluations.\n", jerror)); endif
  
  rstatus = 1;
  xls.limits = [lcol, rcol; firstrow, lastrow];
  
endfunction


#==================================================================================
## Copyright (C) 2009,2010,2011,2012 Philip Nienhuis <prnienhuis at users.sf.net>
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
## @deftypefn {Function File} [@var{obj}, @var{rstatus}, @var{xls} ] = xls2jxla2oct (@var{xls})
## @deftypefnx {Function File} [@var{obj}, @var{rstatus}, @var{xls} ] = xls2jxla2oct (@var{xls}, @var{wsh})
## @deftypefnx {Function File} [@var{obj}, @var{rstatus}, @var{xls} ] = xls2jxla2oct (@var{xls}, @var{wsh}, @var{range})
## Get cell contents in @var{range} in worksheet @var{wsh} in an Excel
## file pointed to in struct @var{xls} into the cell array @var{obj}.
## @var{range} can be a range or just the top left cell of the range.
##
## xls2jxla2oct should not be invoked directly but rather through xls2oct.
##
## Examples:
##
## @example
##   [Arr, status, xls] = xls2jxla2oct (xls, 'Second_sheet', 'B3:AY41');
##   B = xls2jxla2oct (xls, 'Second_sheet');
## @end example
##
## @seealso {xls2oct, oct2xls, xlsopen, xlsclose, xlsread, xlswrite, oct2jxla2xls}
##
## @end deftypefn

## Author: Philip Nienhuis
## Created: 2009-12-04
## Updates:
## 2009-12-11 ??? some bug fix
## 2010-07-28 Added option to read formulas as text strings rather than evaluated value
##            Added check for proper xls structure
## 2010-07-29 Added check for too latge requested data rectangle
## 2010-10-10 Code cleanup: -getusedrange(); moved cropping result array to
##     ''     calling function
## 2010-11-12 Moved ptr struct check into main func
## 2010-11-13 Catch empty sheets when no range was specified
## 2011-04-11 (Ron Goldman <ron@ocean.org.il>) Fixed missing months var, wrong arg
##     ''     order in strsplit, wrong isTime condition
## 2012-01-26 Fixed "seealso" help string

function [ rawarr, xls, rstatus ] = xls2jxla2oct (xls, wsh, cellrange, spsh_opts)

  persistent ctype; persistent months;
  if (isempty (ctype))
    ctype = cell (11, 1);
    # Get enumerated cell types. Beware as they start at 0 not 1
    ctype( 1) = (java_get ('jxl.CellType', 'BOOLEAN')).toString ();
    ctype( 2) = (java_get ('jxl.CellType', 'BOOLEAN_FORMULA')).toString ();
    ctype( 3) = (java_get ('jxl.CellType', 'DATE')).toString ();
    ctype( 4) = (java_get ('jxl.CellType', 'DATE_FORMULA')).toString ();
    ctype( 5) = (java_get ('jxl.CellType', 'EMPTY')).toString ();
    ctype( 6) = (java_get ('jxl.CellType', 'ERROR')).toString ();
    ctype( 7) = (java_get ('jxl.CellType', 'FORMULA_ERROR')).toString ();
    ctype( 8) = (java_get ('jxl.CellType', 'NUMBER')).toString ();
    ctype( 9) = (java_get ('jxl.CellType', 'LABEL')).toString ();
    ctype(10) = (java_get ('jxl.CellType', 'NUMBER_FORMULA')).toString ();
    ctype(11) = (java_get ('jxl.CellType', 'STRING_FORMULA')).toString ();
    months = {'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'};
  endif
  
  rstatus = 0; 
  wb = xls.workbook;
  
  # Check if requested worksheet exists in the file & if so, get pointer
  nr_of_sheets = wb.getNumberOfSheets ();
  shnames = char (wb.getSheetNames ());
  if (isnumeric (wsh))
    if (wsh > nr_of_sheets), error (sprintf ("Worksheet # %d bigger than nr. of sheets (%d) in file %s", wsh, nr_of_sheets, xls.filename)); endif
    sh = wb.getSheet (wsh - 1);      # JXL sheet count 0-based
    printf ("(Reading from worksheet %s)\n", shnames {wsh});
  else
    sh = wb.getSheet (wsh);
    if (isempty (sh)), error (sprintf ("Worksheet %s not found in file %s", wsh, xls.filename)); endif
  end

  if (isempty (cellrange))
    # Get numeric sheet pointer (1-based)
    ii = 1;
    while (ii <= nr_of_sheets)
      if (strcmp (wsh, shnames{ii}) == 1)
        wsh = ii;
        ii = nr_of_sheets + 1;
      else
        ++ii;
      endif
    endwhile
    # Get data rectangle row & column numbers (1-based)
    [firstrow, lastrow, lcol, rcol] = getusedrange (xls, wsh);
    if (firstrow == 0 && lastrow == 0)
      # Empty sheet
      rawarr = {};
      printf ("Worksheet '%s' contains no data\n", shnames {wsh});
      rstatus = 1;
      return;
    else
      nrows = lastrow - firstrow + 1;
      ncols = rcol - lcol + 1;
    endif
  else
    # Translate range to row & column numbers (1-based)
    [dummy, nrows, ncols, firstrow, lcol] = parse_sp_range (cellrange);
    # Check for too large requested range against actually present range
    lastrow = min (firstrow + nrows - 1, sh.getRows ());
    nrows = min (nrows, sh.getRows () - firstrow + 1);
    ncols = min (ncols, sh.getColumns () - lcol + 1);
    rcol = lcol + ncols - 1;
  endif

  # Read contents into rawarr
  rawarr = cell (nrows, ncols);      # create placeholder
  for jj = lcol : rcol
    for ii = firstrow:lastrow
      scell = sh.getCell (jj-1, ii-1);
      switch char (scell.getType ())
        case ctype {1}   # Boolean
          rawarr {ii+1-firstrow, jj+1-lcol} = scell.getValue ();
        case ctype {2}   # Boolean formula
          if (spsh_opts.formulas_as_text)
            tmp = scell.getFormula ();
            rawarr {ii+1-firstrow, jj+1-lcol} = ["=" tmp];
          else
            rawarr {ii+1-firstrow, jj+1-lcol} = scell.getValue ();
          endif
        case ctype {3}   # Date
          try
            % Older JXL.JAR, returns float
            rawarr {ii+1-firstrow, jj+1-lcol} = scell.getValue ();
          catch
            % Newer JXL.JAR, returns date string w. epoch = 1-1-1900 :-(
            tmp = strsplit (char (scell.getDate ()), ' ');
            yy = str2num (tmp{6});
            mo = find (ismember (months, upper (tmp{2})) == 1);
            dd = str2num (tmp{3});
            hh = str2num (tmp{4}(1:2));
            mi = str2num (tmp{4}(4:5));
            ss = str2num (tmp{4}(7:8));
            if (scell.isTime ())
              yy = mo = dd = 0;
            endif
            rawarr {ii+1-firstrow, jj+1-lcol} = datenum (yy, mo, dd, hh, mi, ss);
          end_try_catch
        case ctype {4}   # Date formula
          if (spsh_opts.formulas_as_text)
            tmp = scell.getFormula ();
            rawarr {ii+1-firstrow, jj+1-lcol} = ["=" tmp];
          else
            unwind_protect
              % Older JXL.JAR, returns float
              tmp = scell.getValue ();
              % if we get here, we got a float (old JXL).
              % Check if it is time
              if (~scell.isTime ())
                % Reset rawarr <> so it can be processed below as date string
                rawarr {ii+1-firstrow, jj+1-lcol} = [];
              else
                rawarr {ii+1-firstrow, jj+1-lcol} = tmp;
              end
            unwind_protect_cleanup
              if (isempty (rawarr {ii+1-firstrow, jj+1-lcol}))
                % Newer JXL.JAR, returns date string w. epoch = 1-1-1900 :-(
                tmp = strsplit (char (scell.getDate ()), ' ');
                yy = str2num (tmp{6});
                mo = find (ismember (months, upper (tmp{2})) == 1);
                dd = str2num (tmp{3});
                hh = str2num (tmp{4}(1:2));
                mi = str2num (tmp{4}(4:5));
                ss = str2num (tmp{4}(7:8));
                if (scell.isTime ())
                  yy = 0; mo = 0; dd = 0;
                end
                rawarr {ii+1-firstrow, jj+1-lcol} = datenum (yy, mo, dd, hh, mi, ss);
              endif
            end_unwind_protect
          endif
        case { ctype {5}, ctype {6}, ctype {7} }
          # Empty, Error or Formula error. Nothing to do here
        case ctype {8}   # Number
          rawarr {ii+1-firstrow, jj+1-lcol} = scell.getValue ();
        case ctype {9}   # String
          rawarr {ii+1-firstrow, jj+1-lcol} = scell.getString ();
        case ctype {10}  # Numerical formula
          if (spsh_opts.formulas_as_text)
            tmp = scell.getFormula ();
            rawarr {ii+1-firstrow, jj+1-lcol} = ["=" tmp];
          else
            rawarr {ii+1-firstrow, jj+1-lcol} = scell.getValue ();
          endif
        case ctype {11}  # String formula
          if (spsh_opts.formulas_as_text)
            tmp = scell.getFormula ();
            rawarr {ii+1-firstrow, jj+1-lcol} = ["=" tmp];
          else
            rawarr {ii+1-firstrow, jj+1-lcol} = scell.getString ();
          endif
        otherwise
          # Do nothing
      endswitch
    endfor
  endfor

  rstatus = 1;
  xls.limits = [lcol, rcol; firstrow, lastrow];
  
endfunction


## Copyright (C) 2011 Philip Nienhuis <prnienhuis at users.sf.net>
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
## @deftypefn {Function File} [@var{obj}, @var{rstatus}, @var{xls} ] = xls2oxs2oct (@var{xls})
## @deftypefnx {Function File} [@var{obj}, @var{rstatus}, @var{xls} ] = xls2oxs2oct (@var{xls}, @var{wsh})
## @deftypefnx {Function File} [@var{obj}, @var{rstatus}, @var{xls} ] = xls2oxs2oct (@var{xls}, @var{wsh}, @var{range})
## Get cell contents in @var{range} in worksheet @var{wsh} in an Excel
## file pointed to in struct @var{xls} into the cell array @var{obj}.
## @var{range} can be a range or just the top left cell of the range.
##
## xls2oxs2oct should not be invoked directly but rather through xls2oct.
##

## Author: Philip Nienhuis
## Created: 2011-03-26
## Updates:
## 2012-02-25 Changed ctype into num array rather than cell array

function [ rawarr, xls, rstatus ] = xls2oxs2oct (xls, wsh, cellrange, spsh_opts)

  persistent ctype;
  if (isempty (ctype))
    ctype = zeros (6, 1);
    # Get enumerated cell types. Beware as they start at 0 not 1
    ctype( 1) = (java_get ('com.extentech.ExtenXLS.CellHandle', 'TYPE_STRING'));  # 0
    ctype( 2) = (java_get ('com.extentech.ExtenXLS.CellHandle', 'TYPE_FP'));      # 1
    ctype( 3) = (java_get ('com.extentech.ExtenXLS.CellHandle', 'TYPE_INT'));     # 2
    ctype( 4) = (java_get ('com.extentech.ExtenXLS.CellHandle', 'TYPE_FORMULA')); # 3
    ctype( 5) = (java_get ('com.extentech.ExtenXLS.CellHandle', 'TYPE_BOOLEAN')); # 4
    ctype( 6) = (java_get ('com.extentech.ExtenXLS.CellHandle', 'TYPE_DOUBLE'));  # 5
  endif
  
  rstatus = 0; 
  wb = xls.workbook;
  
  # Check if requested worksheet exists in the file & if so, get pointer
  nr_of_sheets = wb.getNumWorkSheets ();
  if (isnumeric (wsh))
    if (wsh > nr_of_sheets), error (sprintf ("Worksheet # %d bigger than nr. of sheets (%d) in file %s", wsh, nr_of_sheets, xls.filename)); endif
    sh = wb.getWorkSheet (wsh - 1);      # OXS sheet count 0-based
    printf ("(Reading from worksheet %s)\n", sh.getSheetName ());
  else
    try
      sh = wb.getWorkSheet (wsh);
    catch
      error (sprintf ("Worksheet %s not found in file %s", wsh, xls.filename));
    end_try_catch
  end

  if (isempty (cellrange))
    # Get numeric sheet pointer (0-based)
    wsh = sh.getTabIndex ();
    # Get data rectangle row & column numbers (1-based)
    [firstrow, lastrow, lcol, rcol] = getusedrange (xls, wsh+1);
    if (firstrow == 0 && lastrow == 0)
      # Empty sheet
      rawarr = {};
      printf ("Worksheet '%s' contains no data\n", shnames {wsh});
      rstatus = 1;
      return;
    else
      nrows = lastrow - firstrow + 1;
      ncols = rcol - lcol + 1;
    endif
  else
    # Translate range to row & column numbers (1-based)
    [dummy, nrows, ncols, firstrow, lcol] = parse_sp_range (cellrange);
    # Check for too large requested range against actually present range
    lastrow = min (firstrow + nrows - 1, sh.getLastRow + 1 ());
    nrows = min (nrows, sh.getLastRow () - firstrow + 1);
    ncols = min (ncols, sh.getLastCol () - lcol + 1);
    rcol = lcol + ncols - 1;
  endif

  # Read contents into rawarr
  rawarr = cell (nrows, ncols);      # create placeholder
  for jj = lcol:rcol
    for ii = firstrow:lastrow
      try
        scell = sh.getCell (ii-1, jj-1);
        sctype = scell.getCellType ();
        rawarr {ii+1-firstrow, jj+1-lcol} = scell.getVal ();
        if (sctype == ctype(2) || sctype == ctype(3) || sctype == ctype(6))
          rawarr {ii+1-firstrow, jj+1-lcol} = scell.getDoubleVal ();
        endif
      catch
        # Empty or non-existing cell
      end_try_catch
    endfor
  endfor

  rstatus = 1;
  xls.limits = [lcol, rcol; firstrow, lastrow];
  
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

## xls2uno2oct

## Author: Philip Nienhuis <prnienhuis@users.sf.net>
## Created: 2011-05-05
## Updates:
## 2011-09-18 Adapted sh_names type to LO 3.4.1
## 2011-09-19 Try to decipher if formulas return numeric or string values

function [rawarr, xls, rstatus] = xls2uno2oct  (xls, wsh, datrange, spsh_opts)

  sheets = xls.workbook.getSheets ();
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
  sh = sheets.getByName(sh_names{wsh}).getObject.queryInterface (unotmp);

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
  [ trow, brow, lcol, rcol ] = getusedrange (xls, wsh);
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
  xls.limits = [lcol, rcol; trow, brow];

  rstatus = ~isempty (rawarr);

endfunction
