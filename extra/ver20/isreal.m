## usage: b = isreal(x)
##
## Returns 1 if all elements of x are real.

function b = isreal(x)
  if (nargin != 1) 
    usage("b = isreal(x)"); 
  endif
  b = !any(any(imag(x)));
endfunction

%!shared x
%! x=rand(10,10); 
%!assert (isreal (x));
%!test x(5,1)=1i; 
%!assert (!isreal (x));
%!assert (isreal ([]));
%!error isreal
%!error isreal(1,2)