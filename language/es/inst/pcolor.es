md5="98029b303b7d5b6a7bfa9f44eb983655";rev="7238";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} pcolor (@var{x}, @var{y}, @var{c})
@deftypefnx {Archivo de función} {} pcolor (@var{c})
Realiza la gráfica de densidad para las matrices @var{x}, y @var{y} 
a partir de @code{meshgrid} y la matriz @var{c} correspondiente a las 
coordenadas @var{x} y @var{y} de la malla. 

Si @var{x} y @var{y} son vectores, entonces un vértice típico es 
(@var{x}(j), @var{y}(i), @var{c}(i,j)). Asi, las columnas de @var{c} 
corresponden a los diferentes valores de @var{x} y las filas de @var{c}  
corresponden a los diferentes valores de @var{y}. 
@seealso{meshgrid, contour}
@end deftypefn
