md5="830d66103cf772f7182e0300adadc709";rev="7136";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {[@var{rldata}, @var{k}] =} rlocus (@var{sys}[, @var{increment}, @var{min_k}, @var{max_k}])

Visualiza la gr@'afica ra@'iz lugar del sistema especificado @acronym{SISO} .
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
Valor m@'inimo de @var{k}
@item max_k
valor m@'aximo de @var{k}
@item increment
El incremento de c@'alculo utilizado en los valores de ganancia
@end table

@strong{Salidas}
Gr@'afica el lugar de ra@'ices a la pantalla
@table @var 
@item rldata
Puntos de datos mostrados: en la columna 1 valores reales, en la columna 
2 los valores imaginarios.
@item k
Las ganancias para el eje real de puntos de quiebre.
@end table
@end deftypefn