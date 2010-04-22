md5="ebc812db2539a86d4bbe2a8da512a847";rev="7225";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} corrcoef (@var{x}, @var{y})
Calcula la correlación entre @var{x} y @var{y}.

Si cada fila de @var{x} y @var{y} es una observación y cada columna es
una variable, la (@var{i}, @var{j})-ésima entrada de
@code{corrcoef (@var{x}, @var{y})} es la correlación entre la 
@var{i}-ésima variable en @var{x} y la @var{j}-ésima variable en @var{y}.

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

Si se llama con un argumento, calcula @code{corrcoef (@var{x}, @var{x})}.
@end deftypefn
