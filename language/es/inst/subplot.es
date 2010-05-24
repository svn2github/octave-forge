md5="90cfdc74ee43c801c0cd7b412b59ef75";rev="7333";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} subplot (@var{rows}, @var{cols}, @var{index})
@deftypefnx {Archivo de función} {} subplot (@var{rcn})
Establece una tabla gráfica con @var{cols} por @var{rows} 
y la grafica en la ubicación dada por @var{index}.

Si sólo un argumento se presenta, entonces debe ser un valor de tres 
dígitos que especifica la ubicación en los dígitos 1 (filas) y 
2 (columnas) y el índice de la trama en dígito 3.

El índice gráfica recore las de filas. En primer lugar todas las columnas
de una fila se ingresan y luego la siguiente fila.

Por ejemplo, una tabla gráfica de 2 por 3 tendra índices graficos 
corriendo de la siguiente manera:
@iftex
@tex
\vskip 10pt
\hfil\vbox{\offinterlineskip\hrule
\halign{\vrule#&&\qquad\hfil#\hfil\qquad\vrule\cr
height13pt&1&2&3\cr height12pt&&&\cr\noalign{\hrule}
height13pt&4&5&6\cr height12pt&&&\cr\noalign{\hrule}}}
\hfil
\vskip 10pt
@end tex
@end iftex
@ifinfo
@display
@group
@example

+-----+-----+-----+
|  1  |  2  |  3  |
+-----+-----+-----+
|  4  |  5  |  6  |
+-----+-----+-----+
@end example
@end group
@end display
@end ifinfo
@seealso{plot}
@end deftypefn
