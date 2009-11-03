md5="bab22d4b0b0fba281af4b45711a45e42";rev="6433";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {@var{h} =} stem3 (@var{x}, @var{y}, @var{z}, @var{linespec})
Realiza un gr@'afico de troncos de tres dimensiones y retorna los 
apuntadores de las l@'ineas y los m@'arcadores usados para graficar 
los troncos. El color predeterminado es @code{"r"} (rojo). El estilo 
de l@'inea predetermiando es @code{"-"} y el marcador predetermiando 
es @code{"o"}.

For example,
@example
theta = 0:0.2:6; 
stem3 (cos (theta), sin (theta), theta) 
@end example

@noindent
grafica 31 troncos con altura desde 0 a 6 distribuidos en un c@'irculo. 
La definici@'on de colores mediante tripletas RGB no son v@'alidas!
@seealso{bar, barh, stem, plot}
@end deftypefn
