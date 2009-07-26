md5="a3f3269d702d00b4c9780b316c5ab541";rev="5920";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} colormap (@var{map})
@deftypefnx {Archivo de funci@'on} {} colormap ("default")
Establece el actual mapa de colores.

@code{colormap (@var{map})} establece el mapa de colores actual @var{map}. El 
mapa de colores debe ser una matrix de @var{n} filas por 3 columnas. Las 
columnas contienen intensidades de rojo, verde, y azul intensities 
respectivamente. Todas las entradas debe estar entre 0 y 1 inclusive. 
Un nuevo mapa de colores se retorna.

@code{colormap ("default")} restaura el mapa de colores predeterminado (el mapa
@code{jet} con 64 entradas).  El mapa de colores predeterminado se retorna.

Sin argumetos, @code{colormap} retorna el mapa de colores actual.
@seealso{jet}
@end deftypefn
