md5="7f7f65f7b6b6c890bf13fa1df5273831";rev="7224";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función cargable} {[@var{j}, @var{ierr}] =} besselj (@var{alpha}, @var{x}, @var{opt})
@deftypefnx {Función cargable} {[@var{y}, @var{ierr}] =} bessely (@var{alpha}, @var{x}, @var{opt})
@deftypefnx {Función cargable} {[@var{i}, @var{ierr}] =} besseli (@var{alpha}, @var{x}, @var{opt})
@deftypefnx {Función cargable} {[@var{k}, @var{ierr}] =} besselk (@var{alpha}, @var{x}, @var{opt})
@deftypefnx {Función cargable} {[@var{h}, @var{ierr}] =} besselh (@var{alpha}, @var{k}, @var{x}, @var{opt})
Calcula las funciones de Bessel o Hankel de varios tipos:

@table @code
@item besselj
Funciones de Bessel de primer tipo.
@item bessely
Funciones de Bessel de segundo tipo.
@item besseli
Funciones de Bessel de primer tipo modificada.
@item besselk
Funciones de Bessel de segundo tipo modificada.
@item besselh
Calcula las funciones de Hankel del primer (@var{k} = 1) o segundo (@var{k}
 = 2) tipo.
@end table

Si el argumento @var{opt} es suministrado, el resultado es multiplicado por 
@code{exp (-I*@var{x})} para @var{k} = 1 o @code{exp (I*@var{x})} para
@var{k} = 2.

Si @var{alpha} es un escalar, el resultado es del mismo tamaño de @var{x}.
Si @var{x} es un escalar, el resultado es del mismo tamaño de @var{alpha}.
Si @var{alpha} es un vector fila y @var{x} un vector columna, el 
resultado es una matriz con @code{length (@var{x})} filas y
@code{length (@var{alpha})} columnas. En otro caso, @var{alpha} y
@var{x} deben coincidir y el resultado será del mismo tamanño.

El valor de @var{alpha} debe ser real. El valor de @var{x} puede ser 
complejo.

Si es requerido, @var{ierr} contiene la siguiente información de estado
y es del  mismo tamanño que el resultado.

@enumerate 0
@item
Retorna normal.
@item
Error de entrada, returna @code{NaN}.
@item
Desbordamiento, returna @code{Inf}.
@item
Pérdida de significancia por reducción de argumentos resulta en menos de 
la mitad de la precisión de la máquina.
@item
Pérdida completa de significancia por reducción de argumentos, returna @code{NaN}.
@item
Error---ningún cálculo, condición de terminación del algoritmo no cumplida,
returna @code{NaN}.
@end enumerate
@end deftypefn
