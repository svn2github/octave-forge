md5="7bd43e553d468fda9c065c0fa72e17b2";rev="6466";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {[@var{C}, @var{F}] =} voronoin (@var{pts})
@deftypefnx {Archivo de funci@'on} {[@var{C}, @var{F}] =} voronoin (@var{pts}, @var{options})

Calcula el diagrama de Voronoi de @code{n} dimensiones. La matriz de 
entrada @var{pts} de tama@~{n}o [n, dim] contiene @code{n} puntos de 
dimensi@'on @var{dim}. La variable @var{C} contiene los puntos de los 
diagramas de Voronoi. La lista @var{F} contiene, para cada diagrama, 
los @'indices de los puntos de Voronoi.

El segundo argumento opcional, el cual debe ser una cadena, contiene los 
puntos adicionales que se pasan al comando subyacente @code{qhull}. V@'ease 
la documentaci@'on de la librer@'ia Qhull para m@'as detalles.
@seealso{voronoin, delaunay, convhull}
@end deftypefn
