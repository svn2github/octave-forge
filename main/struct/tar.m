## s = tar (foo,bar, ... ) == struct ("foo",foo,"bar",bar,...)
##
## Groups foo, bar, ... into a struct whose fields are "foo", "bar" ...
## and such that s.foo == foo, s.bar == bar ...  
##
## See also : untar

## Author:        Etienne Grossmann  <etienne@isr.ist.utl.pt>
## Last modified: October 2000

function s = tar(varargin)

for i=1:nargin
   s.(deblank(argn(i,:))) = varargin{i};
end
