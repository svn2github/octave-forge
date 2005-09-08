## c = cellstr(s)
## Convert a character matrix into a cell array of strings.

## Author: Paul Kienzle
## This program is public domain.

function c = cellstr(s)
  if nargin != 1 || !ischar(s)
    usage ("c = cellstr(s)");
  else
    for i=rows(s):-1:1
      c{i} = deblank(s(i,:));
    endfor
  endif
endfunction
