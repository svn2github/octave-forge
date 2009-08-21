md5="038f5f5ae3967ceecf182fad9fc3db3c";rev="6125";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {@var{tri}=} delaunay (@var{x}, @var{y})
@deftypefnx {Archivo de funci@'on} {@var{tri}=} delaunay (@var{x}, @var{y}, @var{opt})
Retorna una matriz [n, 3] con un conjunto de tri@'angulos los cuales 
son descritos por los @'indices del punto @var{x} y el vector @var{y}.
La triangulaci@'on satisface el criterio circumcircular de Delaunay.
Ning@'un otro punto est@'a en el circumc@'irculo del tri@'angulo definido.

Un tercer argumento opcional, el cual debe ser una cadena, contiene opciones 
dicionales que se suministran al subyasciente comando qhull. V@'ease la documentaci@'on de
la librer@'ia Qhull para detalles.

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
