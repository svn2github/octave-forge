md5="1722b37f4bb4cda1183351c0958a2d0e";rev="7239";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función}  ribbon (@var{x}, @var{y}, @var{width})
@deftypefnx {Archivo de función}  ribbon (@var{y})
@deftypefnx {Archivo de función}  @var{h} = ribbon (@dots{})
Grafica un gráfico de listón para las columnas de @var{y} en función 
de @var{x}. El parámetro opcional @var{width} especifica el ancho de un 
listón sencillo (el valor predetermiando es 0.75). Si se omite @var{x}, 
se asume un vector con el número de filas (1:rows(Y)). Si se requiere, 
retorna un vector @var{h} con los apuntadores a los objetos de tipo 
superficie.
@seealso{gca, colorbar}
@end deftypefn
