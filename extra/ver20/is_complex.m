## Copyright (C) 2000 Paul Kienzle
##
## This program is free software and may be used for any purpose.  This
## copyright notice must be maintained.  Paul Kienzle is not responsible
## for the consequences of using this software.

## usage: b = is_complex(x)
##
## Returns 1 if any elements of x are complex.

function b = is_complex(x)
  if (nargin != 1) 
    usage("b = is_complex(x)"); 
  endif
  b = any(any(imag(x)));
endfunction

%!shared x
%! x=rand(10,10); 
%!assert (isreal (x));
%!test x(5,1)=1i; 
%!assert (!isreal (x));
%!assert (isreal ([]));
%!error isreal
%!error isreal(1,2)