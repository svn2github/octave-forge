md5="67d79f37388ac3bd4fe3b66bfdfab8eb";rev="7238";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} plot_border (...)
Especifica los bordes de la gráfica que serán mostrados. 
Son permitidos múlitples argumentos, entre los que se incluyen:

@table @code
@item "blank"
No se muestra ningún borde.

@item "all"
Muestra todos los bordes.

@item "north"
Borde norte.

@item "south"
Borde sur.

@item "east"
Borde oriental.

@item "west"
Borde occidental.
@end table

@noindent
Los argumentos se pueden abreviar usando el primer caracter. 
Sin argumentos, @code{plot_border} desactiva los bordes.
@end deftypefn
