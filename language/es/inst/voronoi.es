md5="c45497a5583b886e2bea4aebb97a5c36";rev="7333";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} voronoi (@var{x}, @var{y})
@deftypefnx {Archivo de función} {} voronoi (@var{x}, @var{y}, "plotstyle")
@deftypefnx {Archivo de función} {} voronoi (@var{x}, @var{y}, "plotstyle", @var{options})
@deftypefnx {Archivo de función} {[@var{vx}, @var{vy}] =} voronoi (@dots{})
Gráfica un diagrama de Voronoi de puntos @code{(@var{x}, @var{y})}.
Las múltiples facetas de Voronoi con los puntos en el infinito no se
ha elaborado. [@var{vx}, @var{vy}] = voronoi(...) devuelve los vértices
en vez de graficar el diagrama. Graficar (@var{vx}, @var{vy}) muestra el
diagrama de Voronoi.

Un cuarto argumento opcional, que debe ser una cadena, contiene opciones
extras pasado el comando qhull subyacente. Consulte la documentación de
la biblioteca qhull para más detalles.

@example
@group
  x = rand (10, 1);
  y = rand (size (x));
  h = convhull (x, y);
  [vx, vy] = voronoi (x, y);
  plot (vx, vy, "-b", x, y, "o", x(h), y(h), "-g")
  legend ("", "points", "hull");
@end group
@end example

@seealso{voronoin, delaunay, convhull}
@end deftypefn 