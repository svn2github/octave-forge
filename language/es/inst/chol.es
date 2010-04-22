md5="4b8e6435990c2743ae22ad51cbe8f5c2";rev="7225";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función cargable} {} chol (@var{a})
@cindex Factorización de Cholesky
Calcula el factor Cholesky, @var{r}, de la matriz simétrica positiva 
definida @var{a}, donde
@iftex
@tex
$ R^T R = A $.
@end tex
@end iftex
@ifinfo

@example
r' * r = a.
@end example
@end ifinfo
@seealso{cholinv, chol2inv}
@end deftypefn
