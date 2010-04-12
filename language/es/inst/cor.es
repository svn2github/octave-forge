md5="6b7d4ab2647ff16eee28fe1f0c9f53f4";rev="6125";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} cor (@var{x}, @var{y})
Calcula la correlaci@'on entre @var{x} y @var{y}.

La (@var{i}, @var{j})-@'esima entrada de @code{cor (@var{x}, @var{y})} es
la correlaci@'on entre la @var{i}-@'esima variable en @var{x} y la
@var{j}-@'esima variable en @var{y}.

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

Para matrices, cada fila es una observaci@'on y cada columna una variable;
los vectores siempre son observaciones y pueden ser vectores fila o columna.

@code{cor (@var{x})} es equivalente a @code{cor (@var{x}, @var{x})}.

N@'otese que la funci@'on @code{corrcoef} hace lo mismo que @code{cor}.
@end deftypefn
