## f = fieldnames(s)
##
## This function exists in Matlab as a function which returns a cell
## array containing the names of the fields in structure s.  Since
## Octave 2.0 does not support cell arrays, you must convert your script
## to use the Octave function struct_elements, which returns a string 
## matrix instead of a cell array.  The function struct_elements is 
## easily implemented in Matlab as:
##
## function x = struct_elements(s) 
##    x = char(fieldnames(s));
##
## See also cmpstruct, getfield, setfield, rmfield, isfield, isstruct,
## struct.


## Author:        Paul Kienzle <pkienzle@kienzle.powernet.co.uk>

function f = fieldnames(s)
  error("cell arrays unavailable in Octave 2.0; use struct_elements instead");
endfunction
