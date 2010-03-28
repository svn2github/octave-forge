md5="a4a0145e891e928a2a9a6d72936aecda";rev="7136";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {@var{xl} =} zlim ()
@deftypefnx {Archivo de funci@'on} {} zlim (@var{xl})
@deftypefnx {Archivo de funci@'on} {@var{m} =} zlim ('mode')
@deftypefnx {Archivo de funci@'on} {} zlim (@var{m})
@deftypefnx {Archivo de funci@'on} {} zlim (@var{h}, @dots{})
Obtiene o establece los l@'imites del eje z de la gr@'afica actual.
Cuando se llama sin argumentos @code{zlim} devuelve los l@'imites 
el eje z de la gr@'afica actual. Si se pasa de dos vectores elemento
@var{xl}, los l@'imites del eje z se establece en este valor.

El modo actual de c@'alculo del eje z se pueden devolver con una llamada
@code{zlim ('mode')}, y puede ser 'auto' o 'Manual'. El modo de graficado
actual se puede establecer pasando ya sea 'auto' o 'Manual' como 
argumento.

Si se pasa un identificador como el primer argumento, y luego se operara
sobre este identificador en lugar de los ejes actuales a manejar.
@seealso{xlim, ylim, set, get, gca}
@end deftypefn
