md5="6b7d4ab2647ff16eee28fe1f0c9f53f4";rev="7225";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} cor (@var{x}, @var{y})
Calcula la correlación entre @var{x} y @var{y}.

La (@var{i}, @var{j})-ésima entrada de @code{cor (@var{x}, @var{y})} es
la correlación entre la @var{i}-ésima variable en @var{x} y la
@var{j}-ésima variable en @var{y}.

@iftex
@tex
$$
{\rm corrcoef}(x,y) = {{\rm cov}(x,y) \over {\rm std}(x) {\rm std}(y)}
$$
@end tex
@end iftex
@ifnottex
@example
corrcoef(x,y) = cov(x,y)/(std(x)*std(y))
@end example
@end ifnottex

Para matrices, cada fila es una observación y cada columna una variable;
los vectores siempre son observaciones y pueden ser vectores fila o columna.

@code{cor (@var{x})} es equivalente a @code{cor (@var{x}, @var{x})}.

Nótese que la función @code{corrcoef} hace lo mismo que @code{cor}.
@end deftypefn
