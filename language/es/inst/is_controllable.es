-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {[@var{retval}, @var{u}] =} is_controllable (@var{sys}, @var{tol})
@deftypefnx {Archivo de funci@'on} {[@var{retval}, @var{u}] =} is_controllable (@var{a}, @var{b}, @var{tol})
Prueba lógica para comprobar la capacidad de control del sistema.

@strong{Entradas}
@table @var
@item sys
Estructura de datos del sistema
@item a
@itemx b
@var{n} by @var{n}, @var{n} by @var{m} matrices, respectively
@item tol
parámetro redondeo opcional. Valor predeterminado: @code{10*eps}
@end table

@strong{Salidas}
@table @var
@item retval
Bandera lógica; devuelve verdadero (1) si el sistema es controlable, 
@var{sys} o el par (@var{a}, @var{b}) lo que se pasa como argumentos 
de entrada.

@item u
@var{u} es una base ortogonal del subespacio controlable.
@end table

@strong{Method}
Controlabilidad se determina mediante la aplicación de la iteración
Arnoldi con completa re-ortogonalización para obtener una base 
ortogonal del subespacio de Krylov
@example
span ([b,a*b,...,a^@{n-1@}*b]).
@end example
La iteración de Arnoldi se ejecuta con @code{krylov} si el sistema
tiene una única entrada, de lo contrario una iteración Arnoldi bloque
se realiza con @code{krylovb}.
@seealso{size, rows, columns, length, ismatrix, isscalar, isvector
is_observable, is_stabilizable, is_detectable, krylov, krylovb}
@end deftypefn
