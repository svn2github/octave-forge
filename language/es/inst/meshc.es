md5="03dc08d9aa1ee74bb47650414d3674b1";rev="7236";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} meshc (@var{x}, @var{y}, @var{z})
Grafica la malla y el contorno de las matrices @var{x}, y @var{y} de  
@code{meshgrid}, en donde la matriz @var{z} corresponde a las coordenadas 
@var{x} y @var{y} de la malla. Si @var{x} y @var{y} son vectores, un 
vértice típico es (@var{x}(j), @var{y}(i), @var{z}(i,j)). Asi, 
las columnas de @var{z} corresponden a los diferentes valores de @var{x} 
y las columnas de @var{z} corresponden a los diferentes valores de @var{y}.
@seealso{meshgrid, mesh, contour}
@end deftypefn
