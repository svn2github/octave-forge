md5="232892831df864b0efdd60bba5684bad";rev="7238";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función de mapeo} {} pow2 (@var{x})
@deftypefnx {Función de mapeo} {} pow2 (@var{f}, @var{e})
Con un argumento, calcula 
@iftex
@tex
 $2^x$
@end tex
@end iftex
@ifinfo
 2 .^ x
@end ifinfo
para cada elemento de @var{x}. Con dos argumentos, retorna 
@iftex
@tex
 $f \cdot 2^e$.
@end tex
@end iftex
@ifinfo
 f .* (2 .^ e).
@end ifinfo
@seealso{nextpow2}
@end deftypefn
