md5="0f5ab66b85eae7503b2bc3aafca15145";rev="7241";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} triplot (@var{tri}, @var{x}, @var{y})
@deftypefnx {Archivo de función} {} triplot (@var{tri}, @var{x}, @var{y}, @var{linespec})
@deftypefnx {Archivo de función} {@var{h} = } triplot (@dots{})
Grafica una malla triangular en 2D. La variable @var{tri} es la malla 
triangular de los puntos @code{(@var{x}, @var{y})} los cuales son retornados 
por @code{delaunay}. Si se suministra, la función @var{linespec} determina 
las propiedades que se van a usar para las líneas. 

El arguemto de salida @var{h} es el apuntador al objeto gráfico. 
@seealso{plot, trimesh, delaunay}
@end deftypefn
