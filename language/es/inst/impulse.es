md5="c2ffaefd91f67a276205775d5173f9e0";rev="7230";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{y}, @var{t}] =} impulse (@var{sys}, @var{inp}, @var{tstop}, @var{n})
Respuesta a impulso de un sistema lineal
El sistema puede ser discreto o multivariable (o ambos).
Si no se especifican los argumentos de salida, @code{impulse}
produce una gráfica o los datos de respuesta al impulso
para el sistema de @var{sys}.

@strong{Entradas}
@table @var
@item sys
Estructura de datos del sistema.
@item inp
índice de entradas que se excitan.
@item tstop
El argumento @var{tstop} (valor escalar) denota el momento en que 
la simulación debe terminar.
@item n
El número de valores.

Ambos parámetros @var{tstop} y @var{n} pueden ser omitidos y se 
calcula a partir de los valores propios de la matriz A.
@end table
@strong{Salidas}
@table @var
@item y
Valores de los impulsos de respuesta.
@item t
Tiempos de los impulsos de respuestas.
@end table
@seealso{step}
@end deftypefn