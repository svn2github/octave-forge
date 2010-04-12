md5="cdfde1dc2139217915282239a9c464fe";rev="6231";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {[@var{l}, @var{m}, @var{p}, @var{e}] =} dlqe (@var{a}, @var{g}, @var{c}, @var{sigw}, @var{sigv}, @var{z})
Construye un estimador cuadr@'atico lineal (filtro Kalman) para el 
sistema de tiempo discreto 
@iftex
@tex
$$
 x_{k+1} = A x_k + B u_k + G w_k
$$
$$
 y_k = C x_k + D u_k + v_k
$$
@end tex
@end iftex
@ifinfo

@example
x[k+1] = A x[k] + B u[k] + G w[k]
  y[k] = C x[k] + D u[k] + v[k]
@end example

@end ifinfo
donde @var{w}, @var{v} son los procesos de ruido gausiano con media cero con 
las intensidades respectivas @code{@var{sigw} = cov (@var{w}, @var{w})} y 
@code{@var{sigv} = cov (@var{v}, @var{v})}.

Si se especifica, @var{z} es @code{cov (@var{w}, @var{v})}. En otro caso 
@code{cov (@var{w}, @var{v}) = 0}.

La estructura del observador es 
@iftex
@tex
$$
 z_{k|k} = z_{k|k-1} + l (y_k - C z_{k|k-1} - D u_k)
$$
$$
 z_{k+1|k} = A z_{k|k} + B u_k
$$
@end tex
@end iftex
@ifinfo

@example
z[k|k] = z[k|k-1] + L (y[k] - C z[k|k-1] - D u[k])
z[k+1|k] = A z[k|k] + B u[k]
@end example
@end ifinfo

@noindent
Se retornan los siguientes valores: 

@table @var
@item l
La ganacia del observador, 
@iftex
@tex
$(A - ALC)$.
@end tex
@end iftex
@ifinfo
(@var{a} - @var{a}@var{l}@var{c}).
@end ifinfo
is stable.

@item m
La soluci@'on de la ecuaci@'on de Riccati. 

@item p
El estimador de la covarianza del error despu@'es de la actualizaci@'on 
de la medida.

@item e
Los polos de ciclo cerrado de 
@iftex
@tex
$(A - ALC)$.
@end tex
@end iftex
@ifinfo
(@var{a} - @var{a}@var{l}@var{c}).
@end ifinfo
@end table
@end deftypefn