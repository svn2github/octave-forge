md5="11ea4485a85c8a793023c8dd3af6da54";rev="7241";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {@var{xl} =} ylim ()
@deftypefnx {Archivo de función} {} ylim (@var{xl})
@deftypefnx {Archivo de función} {@var{m} =} ylim ('mode')
@deftypefnx {Archivo de función} {} ylim (@var{m})
@deftypefnx {Archivo de función} {} ylim (@var{h}, @dots{})
Obtiene o establece los límites del eje y de la gráfica actual.
Cuando se llama sin argumentos @code{ylim} devuelve los límites 
el eje y de la gráfica actual. Si se pasa de dos vectores elemento
@var{xl}, los límites del eje y se establece en este valor.

El modo actual de cálculo del eje y se pueden devolver con una llamada
@code{ylim ('mode')}, y puede ser 'auto' o 'Manual'. El modo de graficado
actual se puede establecer pasando ya sea 'auto' o 'Manual' como 
argumento.

Si se pasa un identificador como el primer argumento, y luego se operara
sobre este identificador en lugar de los ejes actuales a manejar.
@seealso{xlim, zlim, set, get, gca}
@end deftypefn