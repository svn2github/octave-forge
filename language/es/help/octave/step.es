md5="bbd49b5cb6abf2ca6cacbf61eddc1085";rev="7136";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {[@var{y}, @var{t}] =} step (@var{sys}, @var{inp}, @var{tstop}, @var{n})
Respuesta al dar un paso de un sistema lineal.
El sistema puede ser discreta o multivariable (o ambos).
Si no se especifican los argumentos de salida, @code{step}
produce una gr@'afica o los datos de respuesta al paso para el sistema @var{sys}.

@strong{Entradas}
@table @var
@item sys
Estructura de datos del sistema.
@item inp
@'Indice de entrada que se excita
@item tstop
El argumento @var{tstop} (valor escalar) indica el momento en que
la simulaci@'on debe terminar.
@item n
n@'umero de valores de datos.

Ambos par@'ametros @var{tstop} y @var{n}  puede ser omitidos y se calcula
a partir de los valores propios de la matriz A.
@end table
@strong{Salidas}
@table @var
@item y
Los valores de respuesta del paso dado.
@item t
Los tiempos de respuesta del paso dado.
@end table

Cuando se invoca con el par@'ametro de salida @var{y} la gr@'afica no se
muestra.
@seealso{impulse}
@end deftypefn