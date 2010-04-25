md5="2bd018a2075c612dd0f81d0675f27d42";rev="7236";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {@var{out} =} ltifr (@var{a}, @var{b}, @var{w})
@deftypefnx {Archivo de función} {@var{out} =} ltifr (@var{sys}, @var{w})
Tiempo de respuesta de frecuencia invariable lineal de sistemas de 
entradas sencillas.

@strong{Entradas}
@table @var
@item a
@itemx b
matrices de coeficientes de @math{dx/dt = A x + B u}
@item sys
Estructura de datos del sistema
@item w
vector de frecuencias
@end table
@strong{Salidas}
@table @var
@item out
Frecuencia de respuesta, es decir:
@end table
@iftex
@tex
$$ G(j\omega) = (j\omega I-A)^{-1}B $$
@end tex
@end iftex
@ifinfo
@example
                           -1
             G(s) = (jw I-A) B
@end example
@end ifinfo
Para frecuencias complejas @math{s = jw}.
@end deftypefn