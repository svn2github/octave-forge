md5="73096facff914b85844a9f8909b426ed";rev="7230";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} grid (@var{arg})
@deftypefnx {Archivo de función} {} grid ("minor", @var{arg2})
Obliga a mostrar la malla de la gráfica. El argumento puede ser 
@code{"on"} o @code{"off"}. Si se omite, se intercambia el valor 
actual.

Si @var{arg} es @code{"minor"}, se intercambia el estado de la malla 
menor. Cuando se usa una malla menor, se permite un segundo argumento 
@var{arg2}, el cual puede ser @code{"on"} o @code{"off"} para establecer 
explícitamente el estado de la malla menor.
@seealso{plot}
@end deftypefn
