md5="1d9470f81cf4d75ee749469f3188ed8d";rev="6224";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} d2c (@var{sys}, @var{tol})
@deftypefnx {Archivo de funci@'on} {} d2c (@var{sys}, @var{opt})
Convierte un (sub)sistema discreto en uno completamente continuo.
El tiempo de muestreo usado es @code{sysgettsam(@var{sys})}.

@strong{Inputs}
@table @var
@item   sys
estructura de datos del sistema con componentes discretos
@item   tol
valor escalar.
Toleracia para la convergencia de la opci@'on predeterminada @code{"log"} (v@'ease a continuaci@'on)
@item   opt
opci@'on de conversi@'on. Seleccionada de:
@table @code
@item         "log"
(Predeterminado) La conversi@'on es realizada por medio de una matriz logar@'itmica.
Debido a algunos problemas con este c@'alculo, siguido 
por un algoritmo de descenso empinado para identificar las variables 
de tiempo continuo @var{a}, @var{b}, para obtener un mejor ajuste a los datos originales.

Si se invoca @code{d2c (@var{sys}, @var{tol})}, con @var{tol}
escalar positivo, se usa la opci@'on @code{"log"}. El valor predeterminado para 
@var{tol} es @code{1e-8}.
@item        "bi"
La conversi@'on se realiza por medio de la transformaci@'on bilineal 
@math{z = (1 + s T / 2)/(1 - s T / 2)} donde @math{T} es el 
tiempo de muestreo del sistema (v@'ease @code{sysgettsam}).

FIXME: La opci@'on bilineal presenta un error si @var{sys} no es puramente 
discreto
@end table
@end table
@strong{Output}
@table @var
@item csys 
sistema de tiempo continuo (las mismas dimensiones y nombres de se@~{n}ales que en @var{sys}).
@end table
@end deftypefn
