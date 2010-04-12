md5="4b5a26552ec5e5dddc4236d163f55dc6";rev="6231";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {[@var{k}, @var{p}, @var{e}] =} dlqr (@var{a}, @var{b}, @var{q}, @var{r}, @var{z})
Construye el regulador cuadr@'atico lineal para el sistema de tiempo discreto 
@iftex
@tex
$$
 x_{k+1} = A x_k + B u_k
$$
@end tex
@end iftex
@ifinfo

@example
x[k+1] = A x[k] + B u[k]
@end example

@end ifinfo
para minimizar el funcional de costo 
@iftex
@tex
$$
 J = \sum x^T Q x + u^T R u
$$
@end tex
@end iftex
@ifinfo

@example
J = Sum (x' Q x + u' R u)
@end example
@end ifinfo

@noindent
se omite @var{z} o 
@iftex
@tex
$$
 J = \sum x^T Q x + u^T R u + 2 x^T Z u
$$
@end tex
@end iftex
@ifinfo

@example
J = Sum (x' Q x + u' R u + 2 x' Z u)
@end example

@end ifinfo
se incluye @var{z}.

Se retornan los siguientes valores:

@table @var
@item k
El estado de ganancia de retroalimentaci@'on, 
@iftex
@tex
$(A - B K)$
@end tex
@end iftex
@ifinfo
(@var{a} - @var{b}@var{k})
@end ifinfo
es estable.

@item p
La soluci@'on de la ecuaci@'on algebr@'aica de Riccati. 

@item e
Los polos de ciclo cerrado de 
@iftex
@tex
$(A - B K)$.
@end tex
@end iftex
@ifinfo
(@var{a} - @var{b}@var{k}).
@end ifinfo
@end table
@end deftypefn
