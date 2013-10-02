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
## 2013-10-02 Drop return arg rstatus
## 2013-10-02 Significant speed-up using regexp and splitting xml in chunks ~4e5 chars

function [ rawarr, xls] = __OCT_gnm2oct__ (xls, wsh, cellrange='', spsh_opts)

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
  cells = getxmlnode (xml, "gnm:Cells", 1, 1);  # save -v7 cells.mat cells

  ## The row and column checks below assume rows and cols are sorted rows 1st cols 2nd
  ## In case of requested cell range, set pointer to first cell in range
  if (! isempty (cellrange))
    cells = cells (max (1, regexp (cells, sprintf ('Row="%d"', firstrow - 1), "once") - 12) : end);
  endif

  ## Reading nodes goes fastest if the xml is split in chunks of around 4.10^5 chars
  cdim = length (cells);
  if (cdim > 410000)
    idx = 1;
    jdx = 400000;
    ccells = cell (1, ceil (cdim / 400000));
    ## Assign to ccell, make sure chunks end at <gnm:Cell> node ends
    for ii=1:numel (ccells) - 1
      kdx = regexp (cells(jdx+1:min(jdx+400000, cdim)), "<gnm:Cell ", "once");
      ## Subtract 1 for ">" before "<gnm:" and another 1 coz index = 1-based
      jdx += kdx - 2;
      ccells(ii) = cells (idx:jdx);
      idx = jdx + 1;
      jdx = min (400000 * (ii+1), cdim);
    endfor
    ccells(end) = cells(idx:end);
  else
    ccells = {cells};
  endif

  ## Get first cell
  [gcell, ~, jcx] = getxmlnode (ccells{1}, "gnm:Cell");
  inrange = 1;
  for ii=1:numel (ccells)
    cells = ccells{ii};
    while (! isempty (gcell) && inrange)
      ## Get row index (0-based)
      crow = str2double (regexp (gcell, 'Row="[+-.\d]*"', "match"){1}(6:end-1));
      if (crow >= firstrow - 1)
        if (crow < lastrow)
          ## Row is in range. Get column index
          ccol = str2double (regexp (gcell, 'Col="[+-.\d]*"', "match"){1}(6:end-1));
          if (ccol >= lcol - 1)
            if (ccol < rcol)
              ## This cell is in range. Get type
              ctype = regexp (gcell, 'ValueType="[+-.\d]*"', "match"){1}(6:end-1);
              if (ctype(1) == "4")
                ## Type 40, float
                rawarr {crow-firstrow+2, ccol-lcol+2} = str2double (regexp (gcell, '>.*<', "match"){1}(2:end-1));
              else
                ## A string or maybe a formula. Return as text string anyway (we have no formula evaluator)
                rawarr {crow-firstrow+2, ccol-lcol+2} = regexp (gcell, '>.*<', "match"){1}(2:end-1);
              endif
            endif
          endif
        else
          inrange = 0;
        endif
      endif
      icx = jcx;
      ## Get next cell
      [gcell, ~, jcx] = getxmlnode (cells, "gnm:Cell", icx);
    endwhile
  endfor

  xls.limits = [lcol, rcol; firstrow, lastrow];

endfunction
