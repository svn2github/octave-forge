md5="ebc812db2539a86d4bbe2a8da512a847";rev="5962";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} corrcoef (@var{x}, @var{y})
Calcula la correlaci@'on entre @var{x} y @var{y}.

Si cada fila de @var{x} y @var{y} es una observaci@'on y cada columna es
una variable, la (@var{i}, @var{j})-@'esima entrada de
@code{corrcoef (@var{x}, @var{y})} es la correlaci@'on entre la 
@var{i}-@'esima variable en @var{x} y la @var{j}-@'esima variable en @var{y}.

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
