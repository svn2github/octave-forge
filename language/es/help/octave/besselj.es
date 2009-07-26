md5="befc9b8a96679b7e94ba18e4b65b1f00";rev="5701";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Funci@'on cargable} {[@var{j}, @var{ierr}] =} besselj (@var{alpha}, @var{x}, @var{opt})
@deftypefnx {Funci@'on cargable} {[@var{y}, @var{ierr}] =} bessely (@var{alpha}, @var{x}, @var{opt})
@deftypefnx {Funci@'on cargable} {[@var{i}, @var{ierr}] =} besseli (@var{alpha}, @var{x}, @var{opt})
@deftypefnx {Funci@'on cargable} {[@var{k}, @var{ierr}] =} besselk (@var{alpha}, @var{x}, @var{opt})
@deftypefnx {Funci@'on cargable} {[@var{h}, @var{ierr}] =} besselh (@var{alpha}, @var{k}, @var{x}, @var{opt})
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

Si @var{alpha} es un escalar, el resultado es del mismo tama@~no de @var{x}.
Si @var{x} es un escalar, el resultado es del mismo tama@~no de @var{alpha}.
Si @var{alpha} es un vector fila y @var{x} un vector columna, el 
resultado es una matriz con @code{length (@var{x})} filas y
@code{length (@var{alpha})} columnas. En otro caso, @var{alpha} y
@var{x} deben coincidir y el resultado ser@'a del mismo taman@~no.

El valor de @var{alpha} debe ser real. El valor de @var{x} puede ser 
complejo.

Si es requerido, @var{ierr} contiene la siguiente informaci@'on de estado
y es del  mismo taman@~no que el resultado.

@enumerate 0
@item
Retorna normal.
@item
Error de entrada, returna @code{NaN}.
@item
Desbordamiento, returna @code{Inf}.
@item
P@'erdida de significancia por reducci@'on de argumentos resulta en menos de 
la mitad de la precisi@'on de la m@'aquina.
@item
P@'erdida completa de significancia por reducci@'on de argumentos, returna @code{NaN}.
@item
Error---ning@'un c@'alculo, condici@'on de terminaci@'on del algoritmo no cumplida,
returna @code{NaN}.
@end enumerate
@end deftypefn
