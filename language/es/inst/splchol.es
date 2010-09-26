-*- texinfo -*-
@deftypefn {Funci@'on cargable} {@var{l} =} splchol (@var{a})
@deftypefnx {Funci@'on cargable} {[@var{l}, @var{p}] =} splchol (@var{a})
@deftypefnx {Funci@'on cargable} {[@var{l}, @var{p}, @var{q}] =} splchol (@var{a})
@cindex Cholesky factorization
Calcule el factor de Cholesky, @var{l}, de la escasa sim�trica definida
positiva de la matriz @var{a}, cuando

@iftex
@tex
$ L L^T = A $.
@end tex
@end iftex
@ifinfo

@example
l * l' = a.
@end example
@end ifinfo

Si se invoca con dos o m�s salidas @var{p} es el 0 cuando @var{l} es 
definida positiva y @var{l} es un entero positivo lo contrario.

Si se invoca con 3 salidas la permutaci�n se aplica a @var{a} antes
de la factorizaci�n. Eso es @var{l} es la factorizaci�n de 
@code{@var{a}(@var{q},@var{q})} tal que

@iftex
@tex
$ L R^T = A (Q, Q)$.
@end tex
@end iftex
@ifinfo

@example
r * r' = a (q, q).
@end example
@end ifinfo

Tenga en cuenta que @code{splchol} factorizaciones es m�s r�pido y 
consumen menos memoria que @code{spchol}. @code{splchol(@var{a})}
es equivalente a @code{spchol(@var{a})'}.
@seealso{spcholinv, spchol2inv, splchol}
@end deftypefn
