## dlmwrite(file, matrix, delim, r, c)
## write matrix to the file using delimiters (defaults to ",")
## r is the number of delimiter-only lines to add to the start of the file
## c is the number of delimiters to prepend to each line of data
##
## TODO: proper handling of complex data

## Author: Paul Kienzle <pkienzle@users.sf.net>
## 
## This program is granted to the public domain
## 
## 2002-03-08 Paul Kienzle <pkienzle@users.sf.net>
## * Initial revision

function [ ret ] = dlmwrite (file, A, delim, r, c)
  if (nargin < 2 || nargin > 5)
	usage("dlmwrite(file, A, delim, r, c)");
  endif
  if nargin < 3, delim = ","; endif
  if nargin < 4, r = 0; endif
  if nargin < 5, c = 0; endif

  [fid,msg] = fopen(file,"w");
  if (fid < 0)
    error(msg);
  else
    if (r > 0)
      repmat([repmat(delim,1,c+columns(A)-1),"\n"],1,r)
      fprintf(fid,"%s",repmat([repmat(delim,1,c+columns(A)-1),"\n"],1,r));
    endif
    template = [ "%.16g", repmat([delim,"%.16g"],1,columns(A)-1), "\n" ];
    if (c > 0)
        template = [ repmat(delim,1,c), template ]
    endif
    fprintf(fid,template,A.');
    fclose(fid);
  endif
endfunction
