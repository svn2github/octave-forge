md5="a294f9c8b3b8e43fefc45762e38b6172";rev="6377";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} mesh (@var{x}, @var{y}, @var{z})
Grafica la malla de las matrices @var{x}, y @var{y} de @code{meshgrid} y 
la matriz @var{z} correspondiente a las coordenadas de @var{x} y @var{y} 
de la malla. Si @var{x} y @var{y} son vectores, entonces un v@'ertice 
es (@var{x}(j), @var{y}(i), @var{z}(i,j)). Asi, las columnas de @var{z} 
corresponden a los diferentes valores de @var{x} y las filas de @var{z}  corresponden a los diferentes valores de @var{y}.
@seealso{meshgrid, contour}
@end deftypefn
