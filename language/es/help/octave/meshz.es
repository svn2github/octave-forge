md5="ac60a54e9237f01214cee35239b31757";rev="6381";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} meshz (@var{x}, @var{y}, @var{z})
Grafica una malla cortina de las matrices @var{x}, y @var{y} a partir 
de @code{meshgrid} y una matriz @var{z} correspondiente a las coordenadas 
@var{x} y @var{y} de la malla. Si @var{x} y @var{y} son vectores, 
entonces un v@'ertice t@'ipico es (@var{x}(j), @var{y}(i), @var{z}(i,j)). 
As@'i, las columnas de @var{z} corresponden a los diferentes valores de 
@var{x} y las filas de @var{z} corresponden a los diferentes valores de  
@var{y}.
@seealso{meshgrid, mesh, contour}
@end deftypefn
