md5="a4a0145e891e928a2a9a6d72936aecda";rev="7241";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {@var{xl} =} zlim ()
@deftypefnx {Archivo de función} {} zlim (@var{xl})
@deftypefnx {Archivo de función} {@var{m} =} zlim ('mode')
@deftypefnx {Archivo de función} {} zlim (@var{m})
@deftypefnx {Archivo de función} {} zlim (@var{h}, @dots{})
Obtiene o establece los límites del eje z de la gráfica actual.
Cuando se llama sin argumentos @code{zlim} devuelve los límites 
el eje z de la gráfica actual. Si se pasa de dos vectores elemento
@var{xl}, los límites del eje z se establece en este valor.

El modo actual de cálculo del eje z se pueden devolver con una llamada
@code{zlim ('mode')}, y puede ser 'auto' o 'Manual'. El modo de graficado
actual se puede establecer pasando ya sea 'auto' o 'Manual' como 
argumento.

Si se pasa un identificador como el primer argumento, y luego se operara
sobre este identificador en lugar de los ejes actuales a manejar.
@seealso{xlim, ylim, set, get, gca}
@end deftypefn
