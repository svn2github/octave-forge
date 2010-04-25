md5="5bb358550ac8169dc65e40502392a715";rev="7239";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} rot90 (@var{x}, @var{n})
Devuelve una copia de @var{x} con los elementos de rotación en sentido
contrario en incrementos de 90-grados. El segundo argumento es opcional,
y especifica el número de rotaciones de 90-grados a ser aplicadas (el 
valor predeterminado es 1). Los valores negativos de @var{n} rotan la 
matriz en sentido horario. Por ejemplo,

@example
@group
rot90 ([1, 2; 3, 4], -1)
@result{}  3  1
         4  2
@end group
@end example

@noindent
gira en sentido horario la matriz dada en 90-grados. Las siguientes son
todas las declaraciones equivalentes:

@example
@group
rot90 ([1, 2; 3, 4], -1)
rot90 ([1, 2; 3, 4], 3)
rot90 ([1, 2; 3, 4], 7)
@end group
@end example

Debido a la dificultad de definir un eje sobre el cual rotar la matriz
@code{rot90} trabaja sólo con matrices en 2-D. Para girar N-d matrices
use  @code{rotdim} en su lugar.
@seealso{rotdim, flipud, fliplr, flipdim}
@end deftypefn 