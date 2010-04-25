md5="75f462f80672929857e8689cb30f75b0";rev="7241";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} trimesh (@var{tri}, @var{x}, @var{y}, @var{z})
@deftypefnx {Archivo de función} {@var{h} = } trimesh (@dots{})
Grafica una malla triangular en 3D. La variable @var{tri} es la malla 
triangular de los puntos @code{(@var{x}, @var{y})} los cuales son 
retornados con @code{delaunay}. La variable @var{z} es el valor en 
el punto @code{(@var{x}, @var{y})}. El argumento de salida @var{h} es 
el apuntador gráfico al gráfico.
@seealso{triplot, delaunay3}
@end deftypefn
