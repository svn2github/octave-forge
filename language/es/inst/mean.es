md5="d1fa47a0025ef0801247822e61343e50";rev="7136";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} mean (@var{x}, @var{dim}, @var{opt})
Si @var{x} es un vector, calcula la media de los elementos de @var{x}
@iftex
@tex
$$ {\rm mean}(x) = \bar{x} = {1\over N} \sum_{i=1}^N x_i $$
@end tex
@end iftex
@ifinfo

@example
mean (x) = SUM_i x(i) / N
@end example
@end ifinfo
Si @var{x} es una matriz, calcula la media para cada columna y los
regresa en un vector fila.

Con el argumento opcional @var{opt}, el tipo de la media calculada puede
ser seleccionado. Las siguientes opciones son reconocidas:

@table @code
@item "a"
Calcula la (ordinary) la media aritm@'etica. Este es el predeterminado.

@item "g"
Calcula la media geom@'etrica.

@item "h"
Calcule la media harmonica.
@end table

Si el argumento opcional @var{dim} es suministrado, trabaja a lo largo
de la dimensi@'on @var{dim}.

@var{dim} y @var{opt} son opcionales. Si ambos se suministran,
bien pueden aparecer en primer lugar.
@end deftypefn