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
## @deftypefn {Function File} @var{raw} = __OCT_xlsx2oct__ (@var{xlsx}, @var{wsh}, @var{range})
## Internal function for reading data from an xlsx worksheet
##
## @seealso{}
## @end deftypefn

## Author: Markus Bergholz <markuman+xlsread@gmail.com>
## Created: 2013-10-04
## Updates:
## 2010-10-20 Transplanted & adapted section for text string worksheet names (PRN)
##     ''     Much code restyled into Octave coding conventions

function [ mat, xls ] = __OCT_xlsx2oct__ (xls, wsh, crange='')

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

  ## Prepare to open requested worksheet file in subdir xl/ . Note: Win accepts forward slashes
  rawsheet = fopen (sprintf ('%s/xl/worksheets/sheet%d.xml', xls.workbook, wsh));
  if (rawsheet > 0)
    fgetl (rawsheet);                   ## skip the first line
    rawdata = fgetl (rawsheet);         ## here comes our needed datastring
    fclose (rawsheet);
  else
    error ("xls2oct: sheet number out of range");
  endif

  ##if (!isempty (crange)) % someone wants to read a range :-/ don't work atm!!!
  ##    s = '"';
  ##    [ra.num, ra.char] = __getrange(crange); % lets analyse the range
  ##    matrows = columns (ra.num); % brainfuck? :)
  ##    eval (sprintf ("tmpdata=regexp(rawdata, '<c r=%s[%s]+[%s]%s[^>]*><v[^>]*>(.*?)</v></c>','tokens');", s, ra.char, ra.num, s));
  ##    tmpdata = char (tmpdata{:});
  ##    tmpdata = strrep (tmpdata, ',' , '');
  ##    tmpdata = str2double (tmpdata);
  ##    mat=reshape(tmpdata, [], matrows)';
  ##
  ##else % someone wants all or nothing! :)

  ## If source sheet was made with Excel 2007 (i don't care about Excel 2003)
  if (numel (strfind (rawdata, ' s="')) > 0 || numel (strfind (rawdata, '<f>')) > 0 || numel (strfind (rawdata, 't="s"')) > 0)
    val = cell2mat (regexp (rawdata, '<c r="\w+"(?!t="s")><v>(.*?)</v>', 'tokens'));
    valraw = cell2mat (regexp (rawdata, '<c r="(\w+)"(?!t="s")><v>.*?</v>', 'tokens'));
    if (numel(val) == 0)
      val = cell2mat (regexp (rawdata, '<c r="\w+" s="\d"(?!t="s")><v>(.*?)</v>', 'tokens'));
      valraw = cell2mat (regexp(rawdata, '<c r="(\w+)" s="\d"(?!t="s")><v>.*?</v>', 'tokens'));
    elseif (numel (strfind (rawdata,' s="')) > 0)
      val = [val cell2mat(regexp (rawdata, '<c r="\w+" s="\d"(?!t="s")><v>(.*?)</v>', 'tokens'))];
      valraw = [valraw cell2mat(regexp (rawdata, '<c r="(\w+)" s="\d"(?!t="s")><v>.*?</v>', 'tokens'))];
    endif
  else
    val = cell2mat (regexp (rawdata, '<c r="\w+"(?!t="s")><v>(.*?)</v>', 'tokens'));
    valraw = [];
  endif

  ## the values for mat
  % val=str2double(char(val));
  val = str2double (val)';

  if (numel (valraw))
    ## get the column character (A to ZZZ)
    vi.alph = cell2mat (regexp (valraw, '([A-Za-z]+|[A-Za-z]+[A-Za-z]+|[A-Za-z]+[A-Za-z]+[A-Za-z]+)?', 'match'));
    ## get the row number
    vi.row = str2double (cell2mat (regexp (valraw, '(\d+|\d+\d+|\d+\d+\d+|\d+\d+\d+\d+|\d+\d+\d+\d+\+d|\d+\d+\d+\d+\d+\d+)?', 'match'))')';
    ## free memory
    clear valraw
    ## transform column character to column number
    vi.col = double (cell2mat (cellfun (@__col_str_to_number, vi.alph, 'UniformOutput', false)));
    # vi.col = double (cell2mat (cellfun (@__colnr, vi.alpha, 'UniformOutput', false)));
  
    ## create size corresponding NaN matrix
    idx.mincol = min (vi.col);
    idx.minrow = min (vi.row);
    ## Convey limits of data rectangle to xls2oct. Must be done here
    xls.limits = [idx.mincol, max(vi.col); idx.minrow, max(vi.row)];
    if (1 < idx.mincol)
      vi.col = vi.col - (idx.mincol - 1);
    endif
    if (1 < idx.minrow)
      vi.row = vi.row - (idx.minrow - 1);   
    endif
    mat(1:max(vi.row),1:max(vi.col)) = NaN;
    
    ## get logical indices
    vi.idx = sub2ind (size (mat), (vi.row), (vi.col));
    ## set values to the corresponding indizes in final mat
    mat(vi.idx) = val;
  else
    matrows = size (strfind (rawdata, '</row>'), 2);
    mat= reshape (val, [], matrows)';
  endif
  ## xls2oct expects a cell array
  mat = num2cell (mat);

endfunction