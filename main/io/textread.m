## Copyright (C) 2001 Albert Danial <alnd@users.sf.net>
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
## along with this program; if not, write to the Free Software
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

## usage: [a,b,c,...] = textread(file, format, n);
##
## Reads data from the file using the provided format string.  The
## first return value will contain the first column of the file,
## the second return value gets the second column, et cetera.
## If n is given, the format string will be reused n times.
## If n is omitted or negative, the entire file will be read.
##
## %#c formats return a character array of width #
## %s and %[ formats return a list of strings
## All other formats (see fscanf) return a column vector of doubles
##
## Example:  say the file 'info.txt' contains the following lines:
##    Bunny Bugs   5.5     age=30
##    Duck Daffy  -7.5e-5  age=27
##    Penguin Tux   6      age=10
## Columns from this file could be read with the line:
##   [Lname, Fname, x, a] = textread('info.txt', '%s %s %e age=%d');
## then,
##   nth(Lname,3)  is 'Penguin'
##   nth(Fname,3)  is 'Tux'
##   x(3)          is  6
##   a(3)          is 10
##
## You can skip columns using '%*':
##   [Lname, x] = textread('info.txt','%s %*s %e age=%*d')
##
## You can skip the whole rest of the line using '%*[^\n]':
##   [Lname, Fname] = textread('info.txt','%s%s%*[^\n]')
##
## Compatibility:
##
##    Missing %q for quoted input
##    Need control options:
##      whitespace (set of characters for word delimiters)
##      delimiter (field separator character)
##      commentstyle  ( 'matlab', 'shell', 'C', 'C++' )
##      headerlines (number of lines to skip at the start)
##      emptyvalue (what to use in place of consecutive delimiters)

## A note on delimiters:
##   The delimiter is optional if it is obvious that the next field is
##   starting.  E.g., 3 4 will read as two numbers even with a delimiter
##   of ",".  If there is no delimiter, then %s treats whitespace as a 
##   delimiter.  If there is a delimiter, then %s treats whitespace as
##   part of the string.  The format %[ will eat through delimiters.

## Author: Albert Danial <alnd@users.sf.net>
## Author: Paul Kienzle  <pkienzle@kienzle.powernet.co.uk>

## 2002-03-15 Paul Kienzle
## * remove dependency on str_incr
## * return list of strings for %s rather than character matrix
## * proper handling of leading text
## * handle %* and %%
## 2002-03-15 Paul Kienzle
## * %[ produces a string
## * additional documentation

function [varargout] = textread(file, format, n);

  if (nargin < 2 || nargin > 3)
    error("[a1, a2, ...] = textread(file, format [, n])");
  endif

  if (nargin < 3) n = -1; endif
  if (n < 0) n = Inf; endif
  
  ## Step 1:  Find the format characters
  idx = [find(format=="%"), length(format)+1];
  nFields = length(idx) - 1;
  
  
  ## Step 2: categorize the format strings
  cat = zeros(nFields,1);
  delidx = zeros(nFields,1);
  for i = 1:nFields
    j = idx(i)+1;
    while (j < idx(i+1) && any(" -0123456789.+" == format(j))) 
      j++;
    endwhile
    if (any(format(j)=="%*")) # skip %% and %* fields
      delidx(i) = 1;
      continue;
    endif
    if (j == idx(i+1))
      error("textread: invalid format %s", format(idx(i):idx(i+1)-1) );
    endif
    if format(j) == '['
	cat(i) = toascii('s');
    else
        cat(i) = toascii(format(j));
    endif
  endfor

  ## Fix up indices
  idx(find(delidx)) = [];  # delete any skip fields
  cat(find(delidx)) = []; 
  nFields = length(cat);  # count the number of fields remaining
  idx(1) = 1; # include leading characters in first format
  if (nargout > nFields) # check that we have enough
    error("textread: fewer fields than output arguments");
  endif

  ## initialize the return values
  cat = setstr(cat);
  for i=1:length(cat)
    if cat(i) == "s"
      eval(sprintf("a%d=list();",i));
    elseif cat(i) == "c"
      eval(sprintf("a%d="";", i));
    else
      eval(sprintf("a%d=[];", i));
    endif
  endfor

  
  
  ## Step 3:  Read the contents of the file one term at a time.
  ##          Place the terms into temporary octave matrices
  ##          called 'a1', 'a2', et cetera.  Each pass through
  ##          the format strings yields one new row in these working
  ##          matrices.
  
  [fid, message] = fopen(file, "r");
  if (fid == -1)
    error("textread('%s',...):  %s\n", file, message);
  endif
  
  try elok = empty_list_elements_ok;
  catch elok = 0;
  end
  try wel = warn_empty_list_elements;
  catch wel = 0;
  end
  try pcv = prefer_column_vectors; # so that scalars come out as [ v; v; ... ]
  catch pcv = 0;
  end
  unwind_protect
    empty_list_elements_ok = 1;
    warn_empty_list_elements = 0;
    prefer_column_vectors = 1;
    
    row = 1;
    while (!feof(fid))
      for i = 1:nFields
        [data, count] = fscanf(fid, format(idx(i):idx(i+1)-1), "C");
	if (count == 0) 
	   if (i==1 && feof(fid)) break; endif
	   error("unable to interpret '%s' for record %d, field %d",...
		    format(idx(i):idx(i+1)-1),row,i);
	endif
        if (cat(i) == "s") # list of strings
	  eval(sprintf("a%d = append(a%d, data);", i, i));
	elseif (cat(i) == "c" )  # matrix of characters
          eval(sprintf("a%d = [ a%d ; data ];", i, i));
        else                       # matrix of scalars
          eval(sprintf("a%d(%d) = data;", i, row));
        endif
      endfor
      ++row;
      
      if (count==0 || row > n)
        break;
      endif
      
    endwhile
  unwind_protect_cleanup
    empty_list_elements_ok = elok;
    warn_empty_list_elements = wel;
    prefer_column_vectors = pcv;
    fclose(fid);
  end_unwind_protect
  
  ## Step 4:  populate the return values with the contents of a1, a2, etc.
  if nargout == 0
     ret = list();
     for i = 1:nFields
	eval( sprintf("ret(i) = a%d;",i) );
     endfor
     vr_val_cnt = 1; varargout{vr_val_cnt++} = ret;
  else
    vr_val_cnt = 1;
    for i = 1:nargout
      eval( sprintf ("varargout{vr_val_cnt++} = a%d;",i) );
    endfor
  endif

endfunction
