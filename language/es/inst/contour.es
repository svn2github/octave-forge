md5="94518bcef9ad581e579dcd92474b8293";rev="6125";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} contour (@var{z})
@deftypefnx {Archivo de funci@'on} {} contour (@var{z}, @var{vn})
@deftypefnx {Archivo de funci@'on} {} contour (@var{x}, @var{y}, @var{z})
@deftypefnx {Archivo de funci@'on} {} contour (@var{x}, @var{y}, @var{z}, @var{vn})
@deftypefnx {Archivo de funci@'on} {} contour (@dots{}, @var{style})
@deftypefnx {Archivo de funci@'on} {} contour (@var{h}, @dots{})
@deftypefnx {Archivo de funci@'on} {[@var{c}, @var{h}] =} contour (@dots{})
Graf@'ica las curvas de nivel (l@'ineas de contorno) de la matriz @var{z}, usando la
matriz de contorno @var{c} calculada por @code{contourc} de los mismos
argumentos; v@'ease m@'as adelante para su interpretaci@'on. El conjunto de
niveles de contorno, @var{c}, solo se retorna si es solicitado. Por ejemplo:

@example
@group
x = 0:2;
y = x;
z = x' * y;
contour (x, y, z, 2:3)
@end group
@end example

El estilo usado para graficar puede ser definido con un estilo de l@'inea @var{style}
en forma similar a los estilos de l@'inea usados con el comando @code{plot}.
Cualquier marcador definido en @var{style} se ignora.

El argumento opcional de entrada y salida @var{h} permite que el manejador 
de ejes se pase a @code{contour} y se retorne el manejador del objeto contorno.
@seealso{contourc, patch, plot}
@end deftypefn
