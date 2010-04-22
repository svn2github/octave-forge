md5="cecece684bb61caf75f2557b34f3fb87";rev="7225";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} contour3 (@var{z})
@deftypefnx {Archivo de función} {} contour3 (@var{z}, @var{vn})
@deftypefnx {Archivo de función} {} contour3 (@var{x}, @var{y}, @var{z})
@deftypefnx {Archivo de función} {} contour3 (@var{x}, @var{y}, @var{z}, @var{vn})
@deftypefnx {Archivo de función} {} contour3 (@dots{}, @var{style})
@deftypefnx {Archivo de función} {} contour3 (@var{h}, @dots{})
@deftypefnx {Archivo de función} {[@var{c}, @var{h}] =} contour3 (@dots{})
Grafíca las curvas de nivel (líneas de contorno) de la matriz @var{z}, 
usando la matriz de contornos @var{c} calculada por @code{contourc} para los mismo
argumentos; véase más adelante para sus interpretaciones. Los contornos son
graficados en el nivel Z correspondiente a sus contornos. El conjunto de 
niveles de contornos, @var{c}, solo se retorna si es solicitado. Por ejemplo:

@example
@group
contour3 (peaks (19));
hold on
surface (peaks (19), 'FaceColor', 'none', 'EdgeColor', 'black')
colormap hot
@end group
@end example

El estilo usado para graficar puede ser definido con un estilo de línea @var{style}
en forma similar a los estilos de línea usados con el comando @code{plot}.
Cualquier marcador definido en @var{style} se ignora.

El argumento opcional de entrada y salida @var{h} permite que el apuntador 
de ejes se pase a @code{contour} y se retorne el apuntador del objeto contorno.
@seealso{contourc, patch, plot}
@end deftypefn
