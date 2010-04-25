md5="7bd43e553d468fda9c065c0fa72e17b2";rev="7241";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{C}, @var{F}] =} voronoin (@var{pts})
@deftypefnx {Archivo de función} {[@var{C}, @var{F}] =} voronoin (@var{pts}, @var{options})

Calcula el diagrama de Voronoi de @code{n} dimensiones. La matriz de 
entrada @var{pts} de tama@~{n}o [n, dim] contiene @code{n} puntos de 
dimensión @var{dim}. La variable @var{C} contiene los puntos de los 
diagramas de Voronoi. La lista @var{F} contiene, para cada diagrama, 
los índices de los puntos de Voronoi.

El segundo argumento opcional, el cual debe ser una cadena, contiene los 
puntos adicionales que se pasan al comando subyacente @code{qhull}. Véase 
la documentación de la librería Qhull para más detalles.
@seealso{voronoin, delaunay, convhull}
@end deftypefn
