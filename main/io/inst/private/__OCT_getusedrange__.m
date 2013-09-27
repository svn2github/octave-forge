## Copyright (C) 2013 Philip Nienhuis
## 
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
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
## @deftypefn {Function File} {@var{retval} =} __OCT_getusedrange__ (@var{x} @var{y})
## Get leftmost & rightmost occupied column numbers, and topmost and
## lowermost occupied row numbers (base 1).
##
## @seealso{}
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis at users.sf.net>
## Created: 2013-09-08
## Updates:
## 2013-09-23 Prepared for adding in OOXML
## 2013-09-26 Improved code to skip last empty columns in column count

function [ trow, brow, lcol, rcol ] = __OCT_getusedrange__ (spptr, ii)

  if (strcmpi (spptr.filename(end-3:end), ".ods"))
    [ trow, brow, lcol, rcol ] = __OCT_ods_getusedrange__ (spptr, ii);
  else
    [ trow, brow, lcol, rcol ] = __OCT_xlsx_getusedrange__ (spptr, ii);
  endif

endfunction


##=============================OOXML========================
function [ trow, brow, lcol, rcol ] = __OCT_xlsx_getusedrange__ (spptr, ii);

  trow = brow = lcol = rcol = 0;

  ## FIXME OOXML stuff (.xlsx) here

endfunction

##==============================ODS=========================
function [ trow, brow, lcol, rcol ] = __OCT_ods_getusedrange__ (spptr, ii)

  trow = brow = lcol = rcol = 0;

  ## Check input
  nsheets = numel (spptr.sheets.sh_names); 
  if (ii > nsheets)
    error ("getusedrange: sheet index (%d) out of range (1 - %d)", ii, nsheets);
  endif

  ## Get requested sheet
  sheet = spptr.workbook(spptr.sheets.shtidx(ii):spptr.sheets.shtidx(ii+1)-1);

  ## Check if sheet contains any cell content at all
  ## FIXME: in far-fetched cases, cell string content may contain ' office:' too
  if (! index (sheet, " office:"))
    return
  endif

  ## Assess number of spreadsheet rows out of table-rows
  rowidx = [strfind(sheet, "<table:table-row") length(sheet)];
  nrows1 = nrows = numel (rowidx) - 1;
  ## Get and count repeated table-row occurences
  reprows = strfind (sheet, "table:number-rows-repeated");
  repcnt1 = 0;
  ## Find which rows contain rep counts
  if (! isempty (reprows))
    for ii=1:numel (reprows)
      irow = find ((reprows(ii) > rowidx))(end);
      tblrow = sheet(rowidx(irow):rowidx(irow+1));
      repcnt = str2double (getxmlattv (tblrow, "table:number-rows-repeated")) - 1;
      ## Add repcount to temporary counter
      repcnt1 += repcnt;
      ## Check if this row contains any data
      if (index (tblrow, "office:"))
        ## If yes, add repcounter to nrows and reset it
        nrows += repcnt1;
        repcnt1 = 0;
      else
        ## If no, check if there's data in the next table-row
        tblrow = getxmlnode (sheet(rowidx(irow+1):end), "table:table-row");
        if (! isempty (tblrow))
          if (index (tblrow, "office:"))
            ## If yes, add repcounter to nrows and reset it
            nrows += repcnt1;
            repcnt1 = 0;
          endif
        endif
      endif
    endfor
  else
    
  endif

  ## Set spreadsheet upper data row and count columns
  ncol = 0;
  re = 1;
  for jj=1:nrows1
    ## Get a table row
    [trow1, ~, re] = getxmlnode (sheet, "table:table-row", re);

    ## Prepare to count columns in row
    tcell = " ";
    tcidx = 1;

    ## Find top row index. Only for first table-row, check if empty
    if (! ncol)
      if (index (trow1, "office:"))
        trow = 1;
      else
        ## Apparently a placeholder table-row
        repcnt = str2double (getxmlattv (trow1, "table:number-rows-repeated"));
        if (isfinite (repcnt))
          ## First row with data is below this table row
          trow = repcnt + 1;
        else
          ## Upper table row is a single row
          trow = 2;
        endif
      endif

      ## Explore number of columns in row (should match that of entire sheet)
      ## Older OOo versions fill the entire width with nr-cols-repeated attrib
      while (! isempty (tcell))
        emptycols = 0;
        ## Try to get next table-cell
        [tcell, ~, tcidx] = getxmlnode (trow1, "table:table-cell", tcidx);
        if (! isempty (tcell))
          repcolatt = getxmlattv (tcell, "table:number-columns-repeated");
          repcol = str2double (repcolatt);
          if (! isfinite (repcol))
            emptycols += repcol;
            ## Check if cell has data
            if (index (tcell, " office:"))
              ncol += emptycols;
              emptycols = 0;
            endif
          else
            if (index (tcell, " office:"))
              ncol += 1 + emptycols;
              emptycols = 0;
            else
              emptycols++;
            endif
          endif
        endif
      endwhile
      if (ncol)
        lcol = ncol;
      else
        lcol = ncol = repcol;
      endif

    ## For subsequent rows, just check if 1st & last tcell contain repcols
    ## On older OOo versions an empty to row may have 1024 cols, and ncol = 0
    else
      ## Get indices of all table-cells
      tcidx = regexp (trow1, '<table:table-cell', "start");
      ## Leftmost table-cell
      tcell = getxmlnode (trow1, "table:table-cell");
      repcol = str2double (getxmlattv (tcell, "table:number-columns-repeated"));
      if (index (tcell, " office:"))
        ## Yes. Leftmost table-cell contains data
        lcol = 1; 
      else
        if (isfinite (repcol))
          lcol = min (lcol, repcol + 1);
        else
          lcol = 2;
        endif
      endif
      ## Rightmost table-cell, if row contains more than one tcell
      if (numel (tcidx) > 1)
        rc = str2double (getxmlattv (trow1(tcidx(end):end), "table:number-columns-repeated"));
        if (! isfinite (rc))
          ## Check for data content
          if (index (trow1(tcidx(end):end), " office:value"))
            ncol = min (ncol, numel (tcidx));
          endif
        endif
        ##
      endif
    endif

    
    ## Check if last table-row contains any data
    if (jj == nrows1)
      if (! index (trow1, " office:"))
        nrows -= 1;
      endif
    endif

  endfor

  if (ncol > 0)
    rcol = ncol;
    brow = nrows;
  endif

endfunction
