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
## 2013-09-27 Re-use old jOpenDocument code; may be slow but it is well-tested
## 2013-10-01 Gnumeric subfunction added
## 2013-11-03 Fix wrong variable name "xml"->"sheet" in __OCT_ods_getusedrange__ 

function [ trow, brow, lcol, rcol ] = __OCT_getusedrange__ (spptr, ii)

  ## Check input
  nsheets = numel (spptr.sheets.sh_names); 
  if (ii > nsheets)
    error ("getusedrange: sheet index (%d) out of range (1 - %d)", ii, nsheets);
  endif

  if (strcmpi (spptr.filename(end-3:end), ".ods"))
    [ trow, brow, lcol, rcol ] = __OCT_ods_getusedrange__ (spptr, ii);
  elseif (strcmpi (spptr.filename(end-4:end-1), ".xls"))
    [ trow, brow, lcol, rcol ] = __OCT_xlsx_getusedrange__ (spptr, ii);
  elseif (strcmpi (spptr.filename(end-8:end), ".gnumeric"))
    [ trow, brow, lcol, rcol ] = __OCT_gnm_getusedrange__ (spptr, ii);
  endif

endfunction


##=============================OOXML========================

function [ trow, brow, lcol, rcol ] = __OCT_xlsx_getusedrange__ (spptr, ii);

  trow = brow = lcol = rcol = 0;

  ## Read first part of raw worksheet
  rawsheet = fopen (sprintf ('%s/xl/worksheets/sheet%d.xml', spptr.workbook, ii));
  if (rawsheet > 0)
    fgetl (rawsheet);                   ## skip the first line
    xml = fgetl (rawsheet, 516);        ## Occupied range is in first 512 bytes
    fclose (rawsheet);
  else
    ## We know the number must be good => apparently tmpdir is damaged or it has gone
    error ("getusedrange: sheet number nonexistent or corrupted file pointer struct");
  endif

  node = getxmlnode (xml, "dimension");
  crange = getxmlattv (node, "ref");

  [~, nrows, ncols, trow, lcol] = parse_sp_range (crange);
  brow = trow + nrows - 1;
  rcol = lcol + ncols - 1;

endfunction


##==============================ODS=========================

function [ trow, brow, lcol, rcol ] = __OCT_ods_getusedrange__ (spptr, ii)

  trow = brow = lcol = rcol = nrows = ncols = 0;

  if (isfield (spptr, "xml"))
    sheet = spptr.xml;
  else
    ## Get requested sheet from info in ods struct pointer. Open file
    fid = fopen (sprintf ("%s/content.xml", spptr.workbook), "r");
    ## Go to start of requested sheet
    fseek (fid, spptr.sheets.shtidx(ii), 'bof');
    ## Compute size of requested chunk
    nchars = spptr.sheets.shtidx(ii+1) - spptr.sheets.shtidx(ii);
    ## Get the sheet
    sheet = fread (fid, nchars, "char=>char").';
    fclose (fid);
  endif

  ## Check if sheet contains any cell content at all
  ## FIXME: in far-fetched cases, cell string content may contain ' office:value' too
  if (isempty (strfind (sheet, " office:value")))
    return
  endif

  [trow, brow, lcol, rcol ] = __ods_get_sheet_dims__ (sheet);

endfunction


##===========================Gnumeric=======================

function [ trow, brow, lcol, rcol ] = __OCT_gnm_getusedrange__ (spptr, ii);

  trow = brow = lcol = rcol = nrows = ncols = 0;

  if (isfield (spptr, "xml"))
    xml = spptr.xml;
  else
    ## Get requested sheet from info in ods struct pointer. Open file
    fid = fopen (spptr.workbook, 'r');
    ## Go to start of requested sheet
    fseek (fid, spptr.sheets.shtidx(ii), 'bof');
    ## Compute size of requested chunk
    nchars = spptr.sheets.shtidx(ii+1) - spptr.sheets.shtidx(ii);
    ## Get the sheet
    xml = fread (fid, nchars, "char=>char").';
    fclose (fid);
  endif

  if (isempty (getxmlnode (xml, "gnm:Cell")))
    ## No cell in sheet. We're done
    return
  endif

  ## Start processing cells. Although max row & column (0-based) are given in
  ## dedicated nodes in the xml, these don't seem exact, and no topleft limit
  ## is given anyway.
  cells = getxmlnode (xml, "gnm:Cells");

  ## Min and max columns
  cols = regexp (cells, 'Col="\d*"', "match");
  cols = regexprep (cols, 'Col="', '');
  cols = regexprep (cols, '"', '');
  cols = str2double (cols);
  lcol = min (cols) + 1;
  rcol = max (cols) + 1;

  ## Min and max rows
  rows = regexp (cells, 'Row="\d*"', "match");
  rows = regexprep (rows, 'Row="', '');
  rows = regexprep (rows, '"', '');
  rows = str2double (rows);
  trow = min (rows) + 1;
  brow = max (rows) + 1;

endfunction

