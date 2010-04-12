md5="45c1971143a819f0a652c382657f7c5c";rev="6381";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} surfc (@var{x}, @var{y}, @var{z})
Grafica la superficie y contorno de las matrices @var{x}, y @var{y} 
mediante @code{meshgrid} y la matriz @var{z} corresponde a las coordenadas 
@var{x} y @var{y} de la malla. Si @var{x} y @var{y} son vectores, 
entonces un v@'ertice t@'ipico es (@var{x}(j), @var{y}(i), @var{z}(i,j)). 
As@'i, las columnas de @var{z} corresponden a los diferentes valores de 
@var{x} y las filas de @var{z} corresponden a los diferentes valores de @var{y}.
@seealso{meshgrid, surf, contour}
@end deftypefn
