md5="d050906c214d14a255c2bad860969feb";rev="6893";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} is_stable (@var{a}, @var{tol}, @var{dflg})
@deftypefnx {Archivo de funci@'on} {} is_stable (@var{sys}, @var{tol})
Regresa 1 si la matriz @var{a} o el sistema @var{sys} es estable, o cero
si no lo @'es

@strong{Entradas}
@table @var
@item  tol
Es un par@'ametro de redondeo, se establece en 200*@code{eps} si se omite
@item dflg
Indicador de sistema digital(no es necesario para la estructura de datos
del sistema):
@table @code
@item @var{dflg} != 0
Establece si eig(a) est@'a en la unidad circular
@item @var{dflg} == 0
Establece si eig(a) est@'a en el abierto LPH (Por defecto)
@end table
@end table
@seealso{size, rows, columns, length, ismatrix, isscalar, isvector
is_observable, is_stabilizable, is_detectable, krylov, krylovb}
@end deftypefn