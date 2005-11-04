## dlmwrite(file, matrix, 'option', value, ...)
## write matrix to the file using delimiters (defaults to ",")
##
## Use one of the following options:
## '-append'
##    Add the data to an existing file.
## 'precision','%#.#f'
##    Specify the width and number of decimals for the stored field
##    Default is %.15g
## 'newline','os'
##    Specify the line separator
##    'pc' uses <CR><LF>
##    'unix' uses <LF>
##    'mac' uses <CR>
## 'delimiter','seq'
##    Use 'seq' to separate elements of the matrix.  Default is ','.  Use
##    the sequence "\t" for tab-delimited values.
## 'roffset',r
##    The number of delimiter-only lines to add to the start of the output.
## 'coffset',c
##    The number of delimiters to add to the start of each line.
## 'seq',r,c
##    This is equivalent to 'delimiter','seq','roffest',r,'coffset',c.
## 
## TODO: proper handling of complex data

## Author: Paul Kienzle <pkienzle@users.sf.net>
## 
## This program is granted to the public domain
## 
## 2002-03-08 Paul Kienzle <pkienzle@users.sf.net>
## * Initial revision

function [ ret ] = dlmwrite (file, A, varargin)
  if nargin < 2, 
     usage("dlmwrite(file, A, 'option', value, ...)"); 
  end

  delim = ',';
  r = 0;
  c = 0;
  mode = 'w';
  newline = setstr(10);
  precision = '%.16g';
  
  arg = 1;
  n = length(varargin);
  while arg <= n
    code = varargin{arg++};
    if ~ischar(code), error("expects 'option',value,..."); endif
    switch code,
    case {'-append'},
      ## No value options
      mode = 'a';

    case {'delimiter','precision','roffset','coffset','newline'},
      ## One value options
      if arg > n, error("'%s' expects a value",code); endif
      value = varargin{arg++};
      switch code,
      case 'delimiter',
        if ~ischar(value), error("expects 'delimiter','seq'"); endif
        delim = setstr(double(value(:)));
      case 'precision',
        if ~ischar(value) && ~any(value(:)=='%'), 
          error("expects 'precision','%#.#f'"); 
        endif
        precision = value;
      case 'newline',
        switch value,
	case 'pc', newline = setstr([13,10]);
	case 'unix',newline = setstr(10);
	case 'mac',newline = setstr(13);
	otherwise,  error("expects 'newline','pc'|'unix'|'mac'");
	end
      case 'roffset',
        if ~isscalar(value), error("expects 'roffset',r"); endif
        r = value;
      case 'coffset',
        if ~isscalar(value), error("expects 'coffset',c"); endif
        c = value;
      end

    otherwise,
      ## Two value options
      if arg > n-1 || ~ischar(code) || ~isscalar(varargin{arg}) ...
          || ~isscalar(varargin{arg+1})
        error("expects 'delimiter',r,c"); 
      endif
      r = varargin{arg++};
      c = varargin{arg++};
    end
  end

  [fid,msg] = fopen(file,mode);
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
%! fid = fopen(f,"r");
%! f1 = char(fread(fid,Inf,'char')');
%! fclose(fid);
%! dlmwrite(f,[5,6],'precision','%5.2f','newline','unix','coffset',1,'delimiter',',','-append');
%! fid = fopen(f,"r");
%! f2 = char(fread(fid,Inf,'char')');
%! fclose(fid);
%! unlink(f);
%!
%! assert(f1,",,\n, 1.00, 2.00\n, 3.00, 4.00\n");
%! assert(f2,",,\n, 1.00, 2.00\n, 3.00, 4.00\n, 5.00, 6.00\n");
