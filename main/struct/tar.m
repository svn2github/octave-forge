## s = tar (foo,bar, ... ) == struct ("foo",foo,"bar",bar,...)
##
## Groups foo, bar, ... into a struct whose fields are "foo", "bar" ...
## and such that s.foo == foo, s.bar == bar ...  
##
## See also : untar

## Author:        Etienne Grossmann  <etienne@isr.ist.utl.pt>
## Last modified: October 2000

function s = tar(...)

## keyboard
## form and eval a string like
## "s.argn(1,:)=va_arg();s.argn(2,:)=va_arg(); ...."

eval(setstr(nze([ones(nargin,1)*toascii("s."),\
		 toascii(argn),\
		 ones(nargin,1)*toascii("=va_arg();")]')')) ;
