## s = tars (foo,bar, ... ) == struct ("foo",foo,"bar",bar,...)
##
## Groups foo, bar, ... into a struct whose fields are "foo", "bar" ...
## and such that s.foo == foo, s.bar == bar ...  
##
## See also : untar

## Author:        Etienne Grossmann <etienne@isr.ist.utl.pt>
## Last modified: October 2000

## modified by Olaf Till

function s = tars (varargin)

  s = cell2struct (varargin, deblank (cellstr (argn)), 2);

endfunction
