md5="11ea4485a85c8a793023c8dd3af6da54";rev="7136";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {@var{xl} =} ylim ()
@deftypefnx {Archivo de funci@'on} {} ylim (@var{xl})
@deftypefnx {Archivo de funci@'on} {@var{m} =} ylim ('mode')
@deftypefnx {Archivo de funci@'on} {} ylim (@var{m})
@deftypefnx {Archivo de funci@'on} {} ylim (@var{h}, @dots{})
Obtiene o establece los l@'imites del eje y de la gr@'afica actual.
Cuando se llama sin argumentos @code{ylim} devuelve los l@'imites 
el eje y de la gr@'afica actual. Si se pasa de dos vectores elemento
@var{xl}, los l@'imites del eje y se establece en este valor.

El modo actual de c@'alculo del eje y se pueden devolver con una llamada
@code{ylim ('mode')}, y puede ser 'auto' o 'Manual'. El modo de graficado
actual se puede establecer pasando ya sea 'auto' o 'Manual' como 
argumento.

Si se pasa un identificador como el primer argumento, y luego se operara
sobre este identificador en lugar de los ejes actuales a manejar.
@seealso{xlim, zlim, set, get, gca}
@end deftypefn