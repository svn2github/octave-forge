## f = fieldnames(s)
## 
## Returns a cell array of field names used in s.
##
## See also getfield, setfield, rmfield, isfield, isstruct, struct. 

## Author:        Paul Kienzle <pkienzle@users.sf.net>

## This program is in the public domain.

function f = fieldnames(s)
  f = cellstr(struct_elements(s));
endfunction
