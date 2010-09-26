-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {[@var{k}, @var{p}, @var{e}] =} lqr (@var{a}, @var{b}, @var{q}, @var{r}, @var{z})
construir el regulador lineal cuadrático para el tiempo continuo del sistema
@iftex
@tex
$$
 {dx\over dt} = A x + B u
$$
@end tex
@end iftex
@ifinfo

@example
dx
-- = A x + B u
dt
@end example

@end ifinfo
reducir al mínimo el costo funcionales
@iftex
@tex
$$
 J = \int_0^\infty x^T Q x + u^T R u
$$
@end tex
@end iftex
@ifinfo

@example
      infinity
      /
  J = |  x' Q x + u' R u
     /
    t=0
@end example
@end ifinfo

@noindent
@var{z} omite o
@iftex
@tex
$$
 J = \int_0^\infty x^T Q x + u^T R u + 2 x^T Z u
$$
@end tex
@end iftex
@ifinfo

@example
      infinity
      /
  J = |  x' Q x + u' R u + 2 x' Z u
     /
    t=0
@end example

@end ifinfo
@var{z} incluido.

Los siguientes son los valores devueltos:

@table @var
@item k
La ganancia de realimentación de estado,
@iftex
@tex
$(A - B K)$
@end tex
@end iftex
@ifinfo
(@var{a} - @var{b}@var{k})
@end ifinfo
es estable y minimiza el costo funcionales

@item p
La solución de estabilización de la ecuación algebraica de Riccati 
adecuada


@item e
El vector de los polos de bucle cerrado
@iftex
@tex
$(A - B K)$.
@end tex
@end iftex
@ifinfo
(@var{a} - @var{b}@var{k}).
@end ifinfo
@end table

@strong{Reference}
Anderson and Moore, @cite{Optimal control: linear quadratic methods},
Prentice-Hall, 1990, pp. 56--58.
@end deftypefn
