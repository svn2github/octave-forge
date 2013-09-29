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
## @deftypefn {Function File} {@var{retval} =} __OCT_ods2oct__ (@var{x} @var{y})
##
## @seealso{}
## @end deftypefn

## Author: Philip Nienhuis <prnienhuis at users.sf.net>
## Created: 2013-09-08
## Updates:
## 2013-09-09 Fix getxmlnode call
##     ''     boolean, percentage & currency tags properly handled
## 2013-09-11 Properly skip empty upper table-rows
##     ''     Return dates as strings to avoid misinterpreting plethora of formats
##     ''     Try-catch construct for time values
##     ''     Formula reading support
## 2013-09-23 Renamed to __OCT_ods2oct__.m
## 2013-09-29 Use values between <text> tags only for strings & dates/times
##     ''     Return date values as Octave datenums (doubles)

function [ rawarr, xls, rstatus] = __OCT_ods2oct__ (xls, wsh, cellrange='', spsh_opts)

  rstatus = 0;

  ## Check if requested worksheet exists in the file & if so, get sheet
  if (isnumeric (wsh))
    if (wsh > numel (xls.sheets.sh_names) || wsh < 1)
      error ("ods2oct: sheet number (%d) out of range (1 - %d)", wsh, numel (xls.sheets.sh_names));
    endif
  elseif (ischar (wsh))
    idx = strmatch (wsh, ods.sheets.sh_names);
    if (isempty (idx))
      error ("ods2oct: sheet '%s' not found in file %s", wsh, xls.filename);
    endif
    wsh = idx;
  endif
  sheet = xls.workbook(xls.sheets.shtidx(wsh):xls.sheets.shtidx(wsh+1));

  ## Check ranges
  [ firstrow, lastrow, lcol, rcol ] = getusedrange (xls, wsh);
  ## FIXME first row & left col always 1
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
    lastrow = min (lastrow, firstrow + nrows - 1);
    rcol = min (rcol, lcol + ncols - 1);
  endif

  rawarr = cell (nrows, rcol);

  ## Get data
  re = 1;
  ii = 0;
  trow = " ";
  ## Row index ii below does not necessarily match table-rows!
  while (ii < nrows && (! isempty (trow)))
    ## Get next table-row
    [trow, ~, re] = getxmlnode (sheet, "table:table-row", re);

    if (! isempty (trow))
      ## Check if table-row has any data
      datrow = index (trow, " office:");

      ## Only process table-row contents if it has any data. Skip upper
      ## empty table-rows (that's why we need an OR), only start counting
      ## with the first table-row containing data
      if (datrow || ii)
        ++ii;
        ## Check repeat status
        reprow = str2double (getxmlattv (trow, "table:number-rows-repeated"));
        ce = 0;
        jj = 0;
        tcell = " ";
        ## Column index jj below does not necessarily match table-cells!
        while (jj < rcol && (! isempty (tcell)))
          ++jj;

          ## Get next table-cell. First see if it is covered (merged)
          [tcell1, ~, ce1] = getxmlnode (trow, "table:covered-table-cell", ce+1);
          [tcell2, ~, ce2] = getxmlnode (trow, "table:table-cell", ce+1);
          if (ce1 > 0 && ce2 > 0)
            ## Both  table-cell and a table-covered-cell are present
            if (ce1 < ce2)
              ## table-covered cell before table-cell. Set pointer at its end
              ce = ce1;
              tcell = tcell1;
              ## Signal code below that content parsing must be skipped
              ce2 = 0;
            else
              ## table-cell before table-covered cell. Pointer to end of table-cell
              ce = ce2;
              tcell = tcell2;
            endif
          else
            if (ce1 > 0)
              ## Only table-covered-cell found
              ce = ce1;
              tcell = tcell1;
            else
              ## Only table-cell found
              ce = ce2;
              tcell = tcell2;
            endif
          endif

          if (! isempty (tcell))
            ## First check its repeat status
            repcol = str2double (getxmlattv (tcell, "table:number-columns-repeated"));
            ## Try to get value type
            ctype = '';
            if (ce2)
              ctype = getxmlattv (tcell, "office:value-type");
            endif
            if (! isempty (ctype))
              if (spsh_opts.formulas_as_text)
                form = getxmlattv (tcell, "table:formula");
                if (! isempty (form))
                  ctype = "cformula";
                endif
              endif
              ## Get value
              ctvalue = getxmlnode (tcell, "text:p")(9:end-9);
              ## Put proper translation into rawarr
              switch ctype
                case "cformula"
                  form = strrep (form(4:end), "&quot;", '"');
                  form = strrep (form, "&lt;", "<");
                  form = strrep (form, "&gt;", ">");
                  form = strrep (form, "&amp;", "&");
                  ## Pimp ranges in formulas
                  form = regexprep (form, '\[\.(\w+)\]', '$1');
                  form = regexprep (form, '\[\.(\w+):', '$1:');
                  form = regexprep (form, ':\.(\w+)\]', ':$1');
                  rawarr{ii, jj} = form;
                case "float"
                  ## Watch out for error values. If so, <text> has #VALUE and office:value = 0
                  if (isfinite (str2double (ctvalue)))
                    rawarr{ii, jj} = str2double (getxmlattv (tcell, "office:value"));
                  else
                    rawarr{ii, jj} = NaN;
                  endif
                case "percentage"
                  ## Watch out for error values. If so, <text> has #VALUE and office:value = 0
                  ctvalue = ctvalue (1:end-1);
                  if (isfinite (str2double (ctvalue)))
                    rawarr{ii, jj} = str2double (getxmlattv (tcell, "office:value"));
                  else
                    rawarr{ii, jj} = NaN;
                  endif
                case "currency"
                  ## Watch out for error values. If so, <text> has #VALUE and office:value = 0
                  idx = regexp (ctvalue, '[\d.\d]');
                  if (isempty (idx))
                    rawarr{ii, jj} = NaN;
                  else
                    rawarr{ii, jj} = str2double (getxmlattv (tcell, "office:value"));
                  endif
                case "string"
                  rawarr{ii, jj} = ctvalue;
                case "date"
                  cvalue = getxmlattv (tcell, "office:date-value");
                  try
                    cvalue = strsplit (cvalue, "T");
                    ## Date part
                    cv = regexp (cvalue{1}, '[0-9]*', "match");
                    yr = str2double (cv(1));
                    mo = str2double (cv(2));
                    dy = str2double (cv(3));
                    rawarr{ii, jj} = datenum(yr, mo, dy) + 693960;
                    ## Time part, if any (that's what the try-catch is for)
                    cv = regexp (cvalue{2}, '[0-9]*', "match");
                    hh = str2double (cv(1));
                    mm = str2double (cv(2));
                    ss = str2double (cv(3));
                    rawarr{ii, jj} += datenum (0, 0, 0, hh, mm, ss);
                  catch
                  end_try_catch
                case "boolean"
                  rawarr{ii, jj} = strcmpi (ctvalue, "true");
                case "time"
                  ## Time values usually have hours first, then minutes, optionally seconds
                  hh = mi = ss = 0;
                  ctvalue = regexp (getxmlattv (tcell, "office:time-value"), '[0-9]*', "match");
                  ## try-catch to catch missing seconds
                  try
                    hh = str2double (ctvalue(1));
                    mi = str2double (ctvalue(2));
                    ss = str2double (ctvalue(3));
                  catch
                  end_try_catch
                  rawarr{ii, jj} = datenum (0, 0, 0, hh, mi, ss);
                otherwise
                  ## Do nothing
              endswitch
            endif
            ## Copy cell contents for repeated columns & bump column counter
            if (isfinite (repcol))
              rawarr(ii, jj+1:jj+repcol-1) = rawarr(ii, jj);
              jj += repcol - 1;
              repcol = '';
            endif
          endif
        endwhile

        ## Copy row contents to repeated rows & bump row counter
        if (isfinite (reprow))
          for kk=ii+1:min (nrows, ii+reprow-1)
            rawarr(kk, :) = rawarr(ii, :);
          endfor
          ii += reprow - 1;
          reprow = '';
        endif
      endif
    endif

  endwhile

  ## If required strip leftmost empty columns
  if (lcol > 1)
    rawarr (:, 1:ncols) = rawarr (:, lcol:rcol);
    rawarr (:, ncols+1:end) = [];
  endif

  ## Keep track of data rectangle limits
  xls.limits = [1, ncols; 1, nrows];

endfunction
