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
## @deftypefn {Function File} [@var{raw}, @var{ods}, @var{rstatus} = __OCT_gnm2oct__ (@var{ods}, @var{wsh}, @var{range}, @var{opts})
## Internal function for reading data from a Gnumeric worksheet
##
## @seealso{}
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis at users.sf.net>
## Created: 2013-10-01
## Updates:
## 

function [ rawarr, xls, rstatus] = __OCT_gnm2oct__ (xls, wsh, cellrange='', spsh_opts)

  rstatus = 0;

  ## Check if requested worksheet exists in the file & if so, get sheet
  if (isnumeric (wsh))
    if (wsh > numel (xls.sheets.sh_names) || wsh < 1)
      error ("xls2oct: sheet number (%d) out of range (1 - %d)", wsh, numel (xls.sheets.sh_names));
    endif
  elseif (ischar (wsh))
    idx = strmatch (wsh, xls.sheets.sh_names);
    if (isempty (idx))
      error ("xls2oct: sheet '%s' not found in file %s", wsh, xls.filename);
    endif
    wsh = idx;
  endif

  ## Get requested sheet from info in file struct pointer. Open file
  fid = fopen (xls.workbook, "r");
  ## Go to start of requested sheet
  fseek (fid, xls.sheets.shtidx(wsh), 'bof');
  ## Compute size of requested chunk
  nchars = xls.sheets.shtidx(wsh+1) - xls.sheets.shtidx(wsh);
  ## Get the sheet
  xml = fread (fid, nchars, "char=>char").';
  fclose (fid);
  ## Add xml to struct pointer to avoid __OCT_getusedrange__ to read it again
  xls.xml = xml;

  ## Check ranges
  [ firstrow, lastrow, lcol, rcol ] = getusedrange (xls, wsh);
  ## Remove xml field
  xls.xml = [];
  xls = rmfield (xls, "xml");
  if (isempty (cellrange))
    if (firstrow == 0 && lastrow == 0)
      ## Empty sheet
      rawarr = {};
      printf ("Worksheet '%s' contains no data\n", xls.sheets.sh_names{wsh});
      rstatus = 1;
      return;
    else
      nrows = lastrow - firstrow + 1;
      ncols = rcol - lcol + 1;
    endif
  else
    [topleft, nrows, ncols, firstrow, lcol] = parse_sp_range (cellrange);
    ## Check if requested range exists
    if (firstrow > lastrow || lcol > rcol)
      ## Out of occupied range
      warning ("xls2oct: requested range outside occupied range");
      rawarr = {};
      xls.limits = [];
      return
    endif
    
    lastrow = min (lastrow, firstrow + nrows - 1);
    rcol = min (rcol, lcol + ncols - 1);
  endif

  ## Preallocate output array
  rawarr = cell (nrows, ncols);

  ## Get cells
  cells = getxmlnode (xml, "gnm:Cells");
  gcell = " ";
  icx = 1;                      # Position counter
  while (! isempty (gcell))
    ## Get next cell
    [gcell, ~, jcx] = getxmlnode (cells, "gnm:Cell", icx);
    ## Get row index (0-based)
    crow = str2double (getxmlattv (gcell, "Row"));
    if (crow >= firstrow - 1 && crow < lastrow)
      ## Row is in range. Get column index
      ccol = str2double (getxmlattv (gcell, "Col"));
      if (ccol >= lcol - 1 && ccol < rcol)
        ## This cell is in range. Get type
        ctype = getxmlattv (gcell, "ValueType");
        if (! isempty (ctype))
          switch ctype
            case "40"   # float
              rawarr {crow-firstrow+2, ccol-lcol+2} = str2double (getxmlnode (gcell, "gnm:Cell", 1, 1));
            case "60"   # string
              rawarr {crow-firstrow+2, ccol-lcol+2} = getxmlnode (gcell, "gnm:Cell", 1, 1);
            otherwise
              ## Nothing
          endswitch
        else
          ## Probably a formula. Return as text string (we have no formula evaluator)
          rawarr {crow-firstrow+2, ccol-lcol+2} = getxmlnode (gcell, "gnm:Cell", 1, 1);
        endif
      endif
    endif
    icx = jcx;
    
  endwhile
  xls.limits = [lcol, rcol; firstrow, lastrow];
  rstatus = 1;

endfunction
