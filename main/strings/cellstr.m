## c = cellstr(s)
## Convert a character matrix into a cell array of strings.
function c = cellstr(s)
  if nargin != 1 || !isstr(s)
    usage ("c = cellstr(s)");
  else
    for i=rows(s):-1:1
      c{i} = deblank(s(i,:));
    endfor
  endif
endfunction
