md5="a9585da2c329177a20136a8ac1dbbe06";rev="6231";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {[@var{Lp}, @var{Lf}, @var{P}, @var{Z}] =} dkalman (@var{A}, @var{G}, @var{C}, @var{Qw}, @var{Rv}, @var{S})
Construye el estimador lineal cuadr@'atico (predictor de Kalman) para el 
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
donde @var{w}, @var{v} son procesos de ruido gausiano con media cero con 
intensidades @code{@var{Qw} = cov (@var{w}, @var{w})} y 
@code{@var{Rv} = cov (@var{v}, @var{v})} respectivamente.

Si se especifica, @var{S} es @code{cov (@var{w}, @var{v})}. En otro caso 
@code{cov (@var{w}, @var{v}) = 0}.

La estructura observadora es 
@iftex
@tex
$x_{k+1|k} = A x_{k|k-1} + B u_k + L_p (y_k - C x_{k|k-1} - D u_k)$
$x_{k|k} = x_{k|k} + L_f (y_k - C x_{k|k-1} - D u_k)$
@end tex
@end iftex
@ifinfo

@example
x[k+1|k] = A x[k|k-1] + B u[k] + LP (y[k] - C x[k|k-1] - D u[k])
x[k|k] = x[k|k-1] + LF (y[k] - C x[k|k-1] - D u[k])
@end example
@end ifinfo

@noindent
Los siguiente valores son retornados:

@table @var
@item Lp
Ganancia del predictor,
@iftex
@tex
$(A - L_p C)$.
@end tex
@end iftex
@ifinfo
(@var{A} - @var{Lp} @var{C})
@end ifinfo
is stable.

@item Lf
Ganancia del filtro.

@item P
Soluci@'on de Riccati.
@iftex
@tex
$P = E \{(x - x_{n|n-1})(x - x_{n|n-1})'\}$
@end tex
@end iftex

@ifinfo
P = E [(x - x[n|n-1])(x - x[n|n-1])']
@end ifinfo

@item Z
Matriz de covarianza de error actualizada.
@iftex
@tex
$Z = E \{(x - x_{n|n})(x - x_{n|n})'\}$
@end tex
@end iftex

@ifinfo
Z = E [(x - x[n|n])(x - x[n|n])']
@end ifinfo
@end table
@end deftypefn
