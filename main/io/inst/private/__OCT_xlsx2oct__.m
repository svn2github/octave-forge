## Copyright (C) 2013 Markus Bergholz
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
## @deftypefn {Function File} [ @var{raw}, @var{xls}, @var rstatus} ] = __OCT_xlsx2oct__ (@var{xlsx}, @var{wsh}, @var{range})
## Internal function for reading data from an xlsx worksheet
##
## @seealso{}
## @end deftypefn

## Author: Markus Bergholz <markuman+xlsread@gmail.com>
## Created: 2013-10-04
## Updates:
## 2010-10-20 Transplanted & adapted section for text string worksheet names (PRN)
##     ''     Much code restyled into Octave coding conventions
## 2013-10-28 More fixes by Markus
## 2013-11-02 Added rstatus return arg (needed by xlsread.m)
## 2013-11-04 (PRN) Adapted regexp search strings to include (numeric) formulas and booleans
##     ''     (PRN) Commented out code for only numeric data until contiguousness is checked

function [ mat, xls, rstatus ] = __OCT_xlsx2oct__ (xls, wsh, crange='')

  ## If a worksheet if given, check if it's given by a name (string) or a number
  if (ischar (wsh))
    fid = fopen (sprintf ('%s/xl/workbook.xml', xls.workbook));
    if (fid < 0)
      ## File open error
      error ("xls2oct: file %s couldn't be opened for reading", filename);
    else
      fgetl (fid); 
      xml = fgetl(fid);
      ## Close file
      fclose (fid);

      ## Search for requested sheet name
      id = strmatch (wsh, xls.sheets.sh_names);
      if (! isempty (id))
        error ("xlsxread: cannot find sheet '%s' in file %s", wsh, xls.filename);
      else
        wsh = xls.sheets.rid(id);
      endif
      
    endif
  endif
  rstatus = 0;

  ## Prepare to open requested worksheet file in subdir xl/ . Note: Win accepts forward slashes
  rawsheet = fopen (sprintf ('%s/xl/worksheets/sheet%d.xml', xls.workbook, wsh));
  if (rawsheet > 0)
    fgetl (rawsheet);                   ## skip the first line
    rawdata = fgetl (rawsheet);         ## here comes our needed datastring
    fclose (rawsheet);
  else
    error ("xls2oct: sheet number out of range");
  endif

  ## FIXME
  if (! isempty (crange))  ## someone wants to read a range :-/ don't work atm!!!
    printf ("xls2oct: reading specified ranges not supported - you'll get all the numeric data\n");
  endif
  ##    s = '"';
  ##    [ra.num, ra.char] = __getrange(crange);   ## lets analyse the range
  ##    matrows = columns (ra.num); % brainfuck? :)
  ##    eval (sprintf ("tmpdata=regexp(rawdata, '<c r=%s[%s]+[%s]%s[^>]*><v[^>]*>(.*?)</v></c>',"tokens");", s, ra.char, ra.num, s));
  ##    tmpdata = char (tmpdata{:});
  ##    tmpdata = strrep (tmpdata, ',' , '');
  ##    tmpdata = str2double (tmpdata);
  ##    mat=reshape(tmpdata, [], matrows)';
  ##
  ##else ## someone wants all or nothing! :)

  ## 'val' are the relevant values. 'valraw' are the corresponding(!) positions (e.g. B3).
  ##
  ## Check if rawdata string was created with Excel 2007, 2010 or 2010 for mac

  ## Check if there are only numeric data (then no s="" or <f> r="s")
  ## FIXME contguous data rectangles check needed!! so corresponding else clause below
  ##if (numel (strfind (rawdata, ' s="')) > 0 || numel (strfind (rawdata, '<f>')) > 0 || numel (strfind (rawdata, 't="s"')) > 0)
    val = cell2mat    (regexp (rawdata, '<c r="\w+"(?: t="[b]+")?>(?:<f.+?(?:</f>|/>))?<v>(.*?)</v>', "tokens"));
    valraw = cell2mat (regexp (rawdata, '<c r="(\w+)"(?: t="[b]+")?>(?:<f.+?(?:</f>|/>))?<v>.*?</v>', "tokens"));
    ## If val is still empty, try another regexpression
    if (numel (val) == 0)
      val =    cell2mat (regexp (rawdata, '<c r="\w+" s="\d"(?!t="s")><v>(.*?)</v>', "tokens"));
      valraw = cell2mat (regexp (rawdata, '<c r="(\w+)" s="\d"(?!t="s")><v>.*?</v>', "tokens"));
    ## If 'val' exist, check is there are tagged s="NUMBERS" values
    elseif (numel (strfind (rawdata,' s="')) > 0)
      valp = cell2mat (regexp (rawdata, '<c r="\w+" s="\d"(?!t="s")><v>(.*?)</v>', "tokens"));
      if (! isempty (valp))
        val =    [val    valp];
        valraw = [valraw cell2mat(regexp (rawdata, '<c r="(\w+)" s="\d"(?!t="s")><v>.*?</v>', "tokens"))];
      endif
    endif

  ## if no s="...", nor <formular>, nor t="s" is found. good luck - it could be awesome fast (like example.xlsx)!
  ## FIXME This will break on the reshape below if the data are non-contiguous. Numeric formula results are skipped too
  ##else
    ##val = cell2mat (regexp(rawdata, '<c r="\w+"(?:t="b")?><v>(.*?)</v>', "tokens"));
    ##valraw = [];
  ##endif

  ## the values for mat
  val = str2double (val)';

  ## FIXME see FIXME below
  ##if (numel (valraw))
    ## get the row number (currently supported from 1 to 999999)
    ## admitted of improvement
    vi.row = str2double (cell2mat (regexp (valraw, '(\d+|\d+\d+|\d+\d+\d+|\d+\d+\d+\d+|\d+\d+\d+\d+\+d|\d+\d+\d+\d+\d+\d+)?', "match"))')';
    ## get the column character (A to ZZZ) (that are more than 18k supported columns atm)
    ## admitted of improvement
    vi.alph = cell2mat (regexp (valraw, '([A-Za-z]+|[A-Za-z]+[A-Za-z]+|[A-Za-z]+[A-Za-z]+[A-Za-z]+)?', "match"));
    ## free memory
    ## might be useful while reading huge files
    clear valraw
    ## if missed formular indices
    idx.all = cell2mat (regexp (rawdata, '<c r="(\w+)"[^>]*><f', "tokens"));
    if (0 < numel (idx.all))
      idx.num = str2double (cell2mat (regexp (idx.all, '(\d+|\d+\d+|\d+\d+\d+|\d+\d+\d+\d+|\d+\d+\d+\d+\+d|\d+\d+\d+\d+\d+\d+)?', "match"))')';
      idx.alph = cell2mat (regexp (idx.all, '([A-Za-z]+|[A-Za-z]+[A-Za-z]+|[A-Za-z]+[A-Za-z]+[A-Za-z]+)?', "match"));
      idx.alph = double (cell2mat (cellfun (@__col_str_to_number, vi.alph, "UniformOutput", 0)));
    else
      ## to prevent warnings or errors while calculating corresponding NaN matrix
      idx.num = [];
      idx.alph = [];
    end
    ## transform column character to column number
    ## A -> 1; C -> 3, AB -> 28 ...
    ## admitted of improvement
    vi.col = double (cell2mat (cellfun (@__col_str_to_number, vi.alph, "UniformOutput", 0)));
    ## create corresponding NaN matrix
    idx.mincol = min ([idx.alph vi.col]);
    idx.minrow = min ([idx.num vi.row]);
    idx.maxrow = max ([idx.num vi.row]);
    idx.maxcol = max ([idx.alph vi.col]);

    ## Convey limits of data rectangle to xls2oct. Must be done here
    xls.limits = [idx.mincol, idx.maxcol; idx.minrow, idx.maxrow];

    ## column adjustment when first number or formula don't begin in the first column
    if (1 < idx.mincol)
          vi.col = vi.col - (idx.mincol - 1);
    endif
    ## row adjustment when first number or formular don't begin in the first row
    if (1 < idx.minrow)
          vi.row = vi.row - (idx.minrow - 1);
    endif
    ## create corresponding NaN matrix
    mat(1 : idx.maxrow-(idx.minrow-1), 1 : idx.maxcol-(idx.mincol-1)) = NaN;

    ## get logical indices for 'val' from 'valraw' positions in NaN matrix
    vi.idx = sub2ind (size (mat), (vi.row), (vi.col));
    ## set values to the corresponding indizes in final mat
    mat (vi.idx) = val;

  ## this was the "good luck" part. no regard for strings, formulars etc.
  ##else
    ## FIZME This reshapewill break on non-contguous data
    ##matrows = size (strfind (rawdata, '</row>'), 2);
    ##mat= reshape (val, [], matrows)';
  ##endif

  ## xls2oct expects a cell array
  mat = num2cell (mat);
  
  if (! isempty (mat))
    rstatus = 1;
  endif

endfunction
