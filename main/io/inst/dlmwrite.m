## -*- texinfo -*-
## @deftypefn {Function File} {} dlmwrite(@var{file}, @var{A})
## @deftypefnx {Function File} {} dmlwrite(@var{file}, @var{A}, @var{delim}, @var{r}, @var{c})
## @deftypefnx {Function File} {} dmlwrite(@var{file}, @var{A}, @code{"attrib1"}, @var{value1}, @code{"attrib2"}, @var{value2}, ...)
## @deftypefnx {Function File} {} dmlwrite(@var{file}, @var{A}, @code{"-append"}, ...)
##
## Write the matrix @var{A} to the text @var{file} using delimiters.
##
## @table @var
## @item delim
## the delimiter to use to separate values on a row
##
## @item r
## the number of delimiter-only lines to add to the start of the file
##
## @item c
## the number of delimiters to prepend to each line of data.
##
## @item '-append'
## append to the end of the @var{file}.
##
## @item 'append', state
## Either @samp{'on'} or @samp{'off'}.  See @samp{'-append'} above.
##
## @item 'delimiter', d
## See @code{"delim"} above.
##
## @item 'newline', os
## The character(s) to use to separate each row.  Three special cases
## exist for this option.  @samp{'unix'} is changed into "\n", @samp{'pc'} is
## changed into "\r\n", and @samp{'mac'} is changed into "\r".  Other
## values for this option are kept as is.
##
## @item 'roffset', r
## See @var{r} above.
##
## @item 'coffset', c
## See @var{c} above.
##
## @item 'precision', p
## The precision to use when writing the file.  It can either be a
## format string (as used by fprintf) or a number of significant digits.
## @end table
##
## @example
## @var{A} = reshape(1:16,4,4);
## dlmwrite(@code{"file.csv"}, @var{A})
## @end example
##
## Note the extra escaping of the backslashes necessary in using the
## latex delimiter of "\\" with a unix style newline.
##
## @example
## dlmwrite(@code{"file.tex"}, @var{A}, @code{"delimiter"}, @code{"&"}, @code{"newline"}, @code{"\\\\\n"})
## @end example
##
## TODO: proper handling of complex data
## @seealso{dlmread, csvread, csvwrite, csv2cell, cell2csv}
## @end deftypefn

## Author: Paul Kienzle <pkienzle@users.sf.net>
## 
## This program is granted to the public domain
## 
## 2002-03-08 Paul Kienzle <pkienzle@users.sf.net>
## * Initial revision
## 2005-11-27 Bill Denney <bill@givebillmoney.com>
## * Significant modifications of the input arguements for additional
## functionality.

function dlmwrite (file, A, varargin)
  if (nargin < 2 || !ischar(file))
    usage("dlmwrite(file, A, delim, r, c)");
  endif

  ## set defaults
  delim = ",";
  r = 0;
  c = 0;
  newline = "\n";
  precision = "%.16g";
  opentype = "wt";

  ## process the input arguements
  i = 0;
  while (i < length(varargin))
    i = i + 1;
    if strcmpi(varargin{i}, "delimiter")
      i = i + 1;
      delim = varargin{i};
    elseif strcmpi(varargin{i}, "newline")
      i = i + 1;
      newline = varargin{i};
      if strcmpi(newline, "unix")
	newline = "\n";
      elseif strcmpi(newline, "pc")
	newline = "\r\n";
      elseif strcmpi(newline, "mac")
	newline = "\r";
      endif
    elseif strcmpi(varargin{i}, "roffset")
      i = i + 1;
      r = varargin{i};
    elseif strcmpi(varargin{i}, "coffset")
      i = i + 1;
      c = varargin{i};
    elseif strcmpi(varargin{i}, "precision")
      i = i + 1;
      precision = varargin{i};
      if (~ strcmpi(class(precision), "char"))
	precision = sprintf("%.%gg", precision);
      endif
    elseif strcmpi(varargin{i}, "-append")
      opentype = "at";
    elseif strcmpi(varargin{i}, "append")
      i = i + 1;
      if strcmpi(varargin{i}, "on")
	opentype = "at";
      elseif strcmpi(varargin{i}, "off")
	opentype = "wt";
      else
	error("dlmwrite: append must be \"on\" or \"off\".");
      endif
    else
      if (i == 1)
	delim = varargin{i};
      elseif (i == 2)
	r = varargin{i};
      elseif (i == 3)
	c = varargin{i};
      else
	usage("dlmwrite(file, A, delim, r, c)");
      endif
    endif
  endwhile

  [fid,msg] = fopen(file,opentype);
  if (fid < 0)
    error(msg);
  else
    if (r > 0)
      fprintf(fid,"%s",repmat([repmat(delim,1,c+columns(A)-1),newline],1,r));
    endif
    template = [ precision, repmat([delim,precision],1,columns(A)-1), newline ];
    if (c > 0)
      template = [ repmat(delim,1,c), template ];
    endif
    fprintf(fid,template,A.');
    fclose(fid);
  endif
endfunction

%!test
%! f = tmpnam();
%! dlmwrite(f,[1,2;3,4],'precision','%5.2f','newline','unix','roffset',1,'coffset',1);
%! fid = fopen(f,"rt");
%! f1 = char(fread(fid,Inf,'char')');
%! fclose(fid);
%! dlmwrite(f,[5,6],'precision','%5.2f','newline','unix','coffset',1,'delimiter',',','-append');
%! fid = fopen(f,"rt");
%! f2 = char(fread(fid,Inf,'char')');
%! fclose(fid);
%! unlink(f);
%!
%! assert(f1,",,\n, 1.00, 2.00\n, 3.00, 4.00\n");
%! assert(f2,",,\n, 1.00, 2.00\n, 3.00, 4.00\n, 5.00, 6.00\n");
