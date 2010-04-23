md5="d050906c214d14a255c2bad860969feb";rev="7231";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} is_stable (@var{a}, @var{tol}, @var{dflg})
@deftypefnx {Archivo de función} {} is_stable (@var{sys}, @var{tol})
Regresa 1 si la matriz @var{a} o el sistema @var{sys} es estable, o cero
si no lo és

@strong{Entradas}
@table @var
@item  tol
Es un parámetro de redondeo, se establece en 200*@code{eps} si se omite
@item dflg
Indicador de sistema digital(no es necesario para la estructura de datos
del sistema):
@table @code
@item @var{dflg} != 0
Establece si eig(a) está en la unidad circular
@item @var{dflg} == 0
Establece si eig(a) está en el abierto LPH (Por defecto)
@end table
@end table
@seealso{size, rows, columns, length, ismatrix, isscalar, isvector
is_observable, is_stabilizable, is_detectable, krylov, krylovb}
@end deftypefn