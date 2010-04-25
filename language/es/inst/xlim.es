md5="61da6dc9c54f9cf43d128237ced10bdf";rev="7241";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {@var{xl} =} xlim ()
@deftypefnx {Archivo de función} {} xlim (@var{xl})
@deftypefnx {Archivo de función} {@var{m} =} xlim ('mode')
@deftypefnx {Archivo de función} {} xlim (@var{m})
@deftypefnx {Archivo de función} {} xlim (@var{h}, @dots{})
Obtiene o establece los límites del eje x de la gráfica actual.
Cuando se llama sin argumentos @code{xlim} devuelve los límites
el eje x de la gráfica actual. Si se pasa de dos vectores elemento
@var{xl}, los límites del eje x se establece en este valor.

El modo actual de cálculo del eje x se pueden devolver con una llamada
@code{xlim ('mode')}, y puede ser 'auto' o 'Manual'. El modo de graficado
actual se puede establecer pasando ya sea 'auto' o 'Manual' como 
argumento.

Si se pasa un identificador como el primer argumento, y luego se operara
sobre este identificador en lugar de los ejes actuales a manejar.
@seealso{ylim, zlim, set, get, gca}
@end deftypefn 