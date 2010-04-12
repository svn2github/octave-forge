md5="61da6dc9c54f9cf43d128237ced10bdf";rev="7136";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {@var{xl} =} xlim ()
@deftypefnx {Archivo de funci@'on} {} xlim (@var{xl})
@deftypefnx {Archivo de funci@'on} {@var{m} =} xlim ('mode')
@deftypefnx {Archivo de funci@'on} {} xlim (@var{m})
@deftypefnx {Archivo de funci@'on} {} xlim (@var{h}, @dots{})
Obtiene o establece los l@'imites del eje x de la gr@'afica actual.
Cuando se llama sin argumentos @code{xlim} devuelve los l@'imites
el eje x de la gr@'afica actual. Si se pasa de dos vectores elemento
@var{xl}, los l@'imites del eje x se establece en este valor.

El modo actual de c@'alculo del eje x se pueden devolver con una llamada
@code{xlim ('mode')}, y puede ser 'auto' o 'Manual'. El modo de graficado
actual se puede establecer pasando ya sea 'auto' o 'Manual' como 
argumento.

Si se pasa un identificador como el primer argumento, y luego se operara
sobre este identificador en lugar de los ejes actuales a manejar.
@seealso{ylim, zlim, set, get, gca}
@end deftypefn 