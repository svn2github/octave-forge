md5="9c3cc381a5e98490aba276e4e6a0024a";rev="7333";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función cargable} {@var{r} =} spchol (@var{a})
@deftypefnx {Función cargable} {[@var{r}, @var{p}] =} spchol (@var{a})
@deftypefnx {Función cargable} {[@var{r}, @var{p}, @var{q}] =} spchol (@var{a})
@cindex Cholesky factorization
Calcular el factor de Cholesky, @var{r}, de la matriz simetríca 
positiva dispersa definida @var{a}, donde

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

Si se llama con 2 o más salidas @var{p} es 0 cuando @var{r} es definida
positiva y @var{p} es un entero positivo de otra manera.

Si se llama con 3 salidas luego una escasez preservando fila/columna de
permutación se aplica a @var{a} antes de la factorización. Eso es 
@var{r} es la factorización de @code{@var{a}(@var{q},@var{q})} tal que

@iftex
@tex
$ R^T R = Q A Q^T$.
@end tex
@end iftex
@ifinfo

@example
r' * r = q * a * q'.
@end example
@end ifinfo

Note que @code{splchol} factorizaciones es más rápido y consumen 
menos memoria.
@seealso{spcholinv, spchol2inv, splchol}
@end deftypefn 