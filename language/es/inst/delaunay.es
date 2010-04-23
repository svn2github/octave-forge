md5="038f5f5ae3967ceecf182fad9fc3db3c";rev="7226";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {@var{tri}=} delaunay (@var{x}, @var{y})
@deftypefnx {Archivo de función} {@var{tri}=} delaunay (@var{x}, @var{y}, @var{opt})
Retorna una matriz [n, 3] con un conjunto de triángulos los cuales 
son descritos por los índices del punto @var{x} y el vector @var{y}.
La triangulación satisface el criterio circumcircular de Delaunay.
Ningún otro punto está en el circumcírculo del triángulo definido.

Un tercer argumento opcional, el cual debe ser una cadena, contiene opciones 
dicionales que se suministran al subyasciente comando qhull. Véase la documentación de
la librería Qhull para detalles.

@example
@group
x = rand (1, 10);
y = rand (size (x));
T = delaunay (x, y);
X = [x(T(:,1)); x(T(:,2)); x(T(:,3)); x(T(:,1))];
Y = [y(T(:,1)); y(T(:,2)); y(T(:,3)); y(T(:,1))];
axis ([0,1,0,1]);
plot (X, Y, "b", x, y, "r*");
@end group
@end example
@seealso{voronoi, delaunay3, delaunayn}
@end deftypefn
