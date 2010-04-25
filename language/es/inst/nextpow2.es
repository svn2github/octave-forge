md5="bf81628001245dc4e9e628e8b3c4cccb";rev="7236";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} nextpow2 (@var{x})
Si @var{x} es un escalar, retorna el primer entero @var{n} tal que 
@iftex
@tex
 $2^n \ge |x|$.
@end tex
@end iftex
@ifinfo
 2^n >= abs (x).
@end ifinfo

Si @var{x} es un vector, retorna @code{nextpow2 (length (@var{x}))}.
@seealso{pow2}
@end deftypefn
