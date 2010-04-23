md5="1d9470f81cf4d75ee749469f3188ed8d";rev="7226";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} d2c (@var{sys}, @var{tol})
@deftypefnx {Archivo de función} {} d2c (@var{sys}, @var{opt})
Convierte un (sub)sistema discreto en uno completamente continuo.
El tiempo de muestreo usado es @code{sysgettsam(@var{sys})}.

@strong{Inputs}
@table @var
@item   sys
estructura de datos del sistema con componentes discretos
@item   tol
valor escalar.
Toleracia para la convergencia de la opción predeterminada @code{"log"} (véase a continuación)
@item   opt
opción de conversión. Seleccionada de:
@table @code
@item         "log"
(Predeterminado) La conversión es realizada por medio de una matriz logarítmica.
Debido a algunos problemas con este cálculo, siguido 
por un algoritmo de descenso empinado para identificar las variables 
de tiempo continuo @var{a}, @var{b}, para obtener un mejor ajuste a los datos originales.

Si se invoca @code{d2c (@var{sys}, @var{tol})}, con @var{tol}
escalar positivo, se usa la opción @code{"log"}. El valor predeterminado para 
@var{tol} es @code{1e-8}.
@item        "bi"
La conversión se realiza por medio de la transformación bilineal 
@math{z = (1 + s T / 2)/(1 - s T / 2)} donde @math{T} es el 
tiempo de muestreo del sistema (véase @code{sysgettsam}).

FIXME: La opción bilineal presenta un error si @var{sys} no es puramente 
discreto
@end table
@end table
@strong{Output}
@table @var
@item csys 
sistema de tiempo continuo (las mismas dimensiones y nombres de se@~{n}ales que en @var{sys}).
@end table
@end deftypefn
