md5="830d66103cf772f7182e0300adadc709";rev="7239";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{rldata}, @var{k}] =} rlocus (@var{sys}[, @var{increment}, @var{min_k}, @var{max_k}])

Visualiza la gráfica raíz lugar del sistema especificado @acronym{SISO} .
@example
@group
       -----   ---     --------
   --->| + |---|k|---->| SISO |----------->
       -----   ---     --------        |
       - ^                             |
         |_____________________________|
@end group
@end example

@strong{Entradas}
@table @var
@item sys
estructura de datos del sistema
@item min_k
Valor mínimo de @var{k}
@item max_k
valor máximo de @var{k}
@item increment
El incremento de cálculo utilizado en los valores de ganancia
@end table

@strong{Salidas}
Gráfica el lugar de raíces a la pantalla
@table @var 
@item rldata
Puntos de datos mostrados: en la columna 1 valores reales, en la columna 
2 los valores imaginarios.
@item k
Las ganancias para el eje real de puntos de quiebre.
@end table
@end deftypefn