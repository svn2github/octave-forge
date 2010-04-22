md5="94518bcef9ad581e579dcd92474b8293";rev="7225";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} contour (@var{z})
@deftypefnx {Archivo de función} {} contour (@var{z}, @var{vn})
@deftypefnx {Archivo de función} {} contour (@var{x}, @var{y}, @var{z})
@deftypefnx {Archivo de función} {} contour (@var{x}, @var{y}, @var{z}, @var{vn})
@deftypefnx {Archivo de función} {} contour (@dots{}, @var{style})
@deftypefnx {Archivo de función} {} contour (@var{h}, @dots{})
@deftypefnx {Archivo de función} {[@var{c}, @var{h}] =} contour (@dots{})
Grafíca las curvas de nivel (líneas de contorno) de la matriz @var{z}, usando la
matriz de contorno @var{c} calculada por @code{contourc} de los mismos
argumentos; véase más adelante para su interpretación. El conjunto de
niveles de contorno, @var{c}, solo se retorna si es solicitado. Por ejemplo:

@example
@group
x = 0:2;
y = x;
z = x' * y;
contour (x, y, z, 2:3)
@end group
@end example

El estilo usado para graficar puede ser definido con un estilo de línea @var{style}
en forma similar a los estilos de línea usados con el comando @code{plot}.
Cualquier marcador definido en @var{style} se ignora.

El argumento opcional de entrada y salida @var{h} permite que el apuntador 
de ejes se pase a @code{contour} y se retorne el apuntador del objeto contorno.
@seealso{contourc, patch, plot}
@end deftypefn
