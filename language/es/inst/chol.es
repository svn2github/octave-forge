md5="4b8e6435990c2743ae22ad51cbe8f5c2";rev="6125";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Funci@'on cargable} {} chol (@var{a})
@cindex Factorizaci@'on de Cholesky
Calcula el factor Cholesky, @var{r}, de la matriz sim@'etrica positiva 
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
