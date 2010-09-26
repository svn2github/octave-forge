-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {[@var{k}, @var{p}, @var{e}] =} lqe (@var{a}, @var{g}, @var{c}, @var{sigw}, @var{sigv}, @var{z})
Construir el estimador lineal cuadrático (filtro de Kalman) para
el sistema de tiempo continuo
@iftex
@tex
$$
 {dx\over dt} = A x + G u
$$
$$
 y = C x + v
$$
@end tex
@end iftex
@ifinfo

@example
dx
-- = A x + G u
dt

y = C x + v
@end example

@end ifinfo
donde @var{w} y @var{v} son media-cero ruido gaussiano con intensidades
de los procesos respectivos .

@example
sigw = cov (w, w)
sigv = cov (v, v)
@end example

el argumento opcional @var{z} es la cruz-covarianza
@code{cov (@var{w}, @var{v})}.  Si esta es omitida,
@code{cov (@var{w}, @var{v}) = 0} es asumida.

Observando la estructura es 
@code{dz/dt = A z + B u + k (y - C z - D u)}

Los siguientes valores son regresados:

@table @var
@item k
La ganancia del observador,
@iftex
@tex
$(A - K C)$
@end tex
@end iftex
@ifinfo
(@var{a} - @var{k}@var{c})
@end ifinfo
es estable.

@item p
La solución de la algebraica ecuación de Riccati.

@item e
El vector de polos de lazo cerrado.
@iftex
@tex
$(A - K C)$.
@end tex
@end iftex
@ifinfo
(@var{a} - @var{k}@var{c}).
@end ifinfo
@end table
@end deftypefn
