md5="c6a11c008095786d2ce90b260961c43d";rev="7226";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {@var{T} =} delaunay3 (@var{x}, @var{y}, @var{z})
@deftypefnx {Archivo de función} {@var{T} =} delaunay3 (@var{x}, @var{y}, @var{z}, @var{opt})
Retorna una matrix de [n, 4]. Cada fila contiene un conjunto de 
tetrahedros los cuales son descritos por los índices a los puntos 
de los vectores (@var{x}, @var{y}, @var{z}).

Un cuarto argumento opcional, el cual debe ser una cadena o un arreglo de celdas de cadenas, 
contiene opciones dicionales que se suministran al subyasciente comando qhull. Véase la 
documentación de la librería Qhull para detalles.
@seealso{delaunay,delaunayn}
@end deftypefn
