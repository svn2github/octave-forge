md5="b3baa4f298d5dafdb4999374c3330069";rev="7224";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {@var{map_out} =} brighten (@var{map}, @var{beta})
@deftypefnx {Archivo de función} {@var{map_out} =} brighten (@var{h}, @var{beta})
@deftypefnx {Archivo de función} {@var{map_out} =} brighten (@var{beta})
Oscurece o aclara el mapa de colores dado. Si el argumento @var{map} se omite, 
la función se aplica al mapa de colores actual. El primer argumento 
puede ser también un apuntador gráfico válido @var{h}, en cuyo caso  
@code{brighten} se aplica al mapa de colores asociado con este apuntador.

El mapa de colores resulutante @var{map_out} no debería asignarse, éste será escrito en el mapa de colores actual.

El argumento @var{beta} debería ser un escalar entre -1 y 1,
donde un valor negativo oscurece y un valor positivo aclara el mapa de colores.
@seealso{colormap}
@end deftypefn
