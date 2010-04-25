md5="ac60a54e9237f01214cee35239b31757";rev="7236";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} meshz (@var{x}, @var{y}, @var{z})
Grafica una malla cortina de las matrices @var{x}, y @var{y} a partir 
de @code{meshgrid} y una matriz @var{z} correspondiente a las coordenadas 
@var{x} y @var{y} de la malla. Si @var{x} y @var{y} son vectores, 
entonces un vértice típico es (@var{x}(j), @var{y}(i), @var{z}(i,j)). 
Así, las columnas de @var{z} corresponden a los diferentes valores de 
@var{x} y las filas de @var{z} corresponden a los diferentes valores de  
@var{y}.
@seealso{meshgrid, mesh, contour}
@end deftypefn
