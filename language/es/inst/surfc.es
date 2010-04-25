md5="45c1971143a819f0a652c382657f7c5c";rev="7240";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} surfc (@var{x}, @var{y}, @var{z})
Grafica la superficie y contorno de las matrices @var{x}, y @var{y} 
mediante @code{meshgrid} y la matriz @var{z} corresponde a las coordenadas 
@var{x} y @var{y} de la malla. Si @var{x} y @var{y} son vectores, 
entonces un vértice típico es (@var{x}(j), @var{y}(i), @var{z}(i,j)). 
Así, las columnas de @var{z} corresponden a los diferentes valores de 
@var{x} y las filas de @var{z} corresponden a los diferentes valores de @var{y}.
@seealso{meshgrid, surf, contour}
@end deftypefn
