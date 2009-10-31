md5="98029b303b7d5b6a7bfa9f44eb983655";rev="6420";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} pcolor (@var{x}, @var{y}, @var{c})
@deftypefnx {Archivo de funci@'on} {} pcolor (@var{c})
Realiza la gr@'afica de densidad para las matrices @var{x}, y @var{y} 
a partir de @code{meshgrid} y la matriz @var{c} correspondiente a las 
coordenadas @var{x} y @var{y} de la malla. 

Si @var{x} y @var{y} son vectores, entonces un v@'ertice t@'ipico es 
(@var{x}(j), @var{y}(i), @var{c}(i,j)). Asi, las columnas de @var{c} 
corresponden a los diferentes valores de @var{x} y las filas de @var{c}  
corresponden a los diferentes valores de @var{y}. 
@seealso{meshgrid, contour}
@end deftypefn
