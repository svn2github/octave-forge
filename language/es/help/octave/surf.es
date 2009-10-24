md5="f9b49ef4f9c371d05cfac2945ef17718";rev="6377";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} surf (@var{x}, @var{y}, @var{z})
Grafica la superficie dada por las matrices @var{x}, y @var{y} de 
@code{meshgrid} y la matriz @var{z} correspondiente a las coordenadas 
@var{x} y @var{y} de la malla. Si @var{x} y @var{y} son vectores, un 
v@'ertice t@'ipico es (@var{x}(j), @var{y}(i), @var{z}(i,j)). Asi, 
las columnas de @var{z} corresponden a los diferentes valores de @var{x} 
y las filas de @var{z} corresponden a los diferentes valores de @var{y}.
@seealso{mesh, surface}
@end deftypefn
