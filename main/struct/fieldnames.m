## f = fieldnames(s)
## 
## When s is a structure, fieldnames(s) returns a list of the field names 
## used in s.  When s is not a structure, fieldnames(s) returns the
## empty list.  Note that this function exists for compatibility with
## Matlab.  Since Octave lacks the dereferencing operator f{i}, you must
## replace all dereferences in your script with nth(f,i).  The function 
## nth is easily implemented in Matlab as:
##
## function x = nth(f,i)
##    x = f{i};
##
## See also cmpstruct, getfield, setfield, rmfield, isfield, isstruct,
## struct. 

## TODO: return a cell array instead of a list

## Author:        Paul Kienzle <pkienzle@kienzle.powernet.co.uk>
## Based on fields.m by Etienne Grossmann  <etienne@isr.ist.utl.pt>

function f = fieldnames(s)
  f = list() ;
  i = 1 ;
  for [val, key] = s
    f(i++) = key ;
  end
endfunction
