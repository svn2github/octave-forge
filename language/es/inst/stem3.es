md5="bab22d4b0b0fba281af4b45711a45e42";rev="7240";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {@var{h} =} stem3 (@var{x}, @var{y}, @var{z}, @var{linespec})
Realiza un gráfico de troncos de tres dimensiones y retorna los 
apuntadores de las líneas y los márcadores usados para graficar 
los troncos. El color predeterminado es @code{"r"} (rojo). El estilo 
de línea predetermiando es @code{"-"} y el marcador predetermiando 
es @code{"o"}.

For example,
@example
theta = 0:0.2:6; 
stem3 (cos (theta), sin (theta), theta) 
@end example

@noindent
grafica 31 troncos con altura desde 0 a 6 distribuidos en un círculo. 
La definición de colores mediante tripletas RGB no son válidas!
@seealso{bar, barh, stem, plot}
@end deftypefn
