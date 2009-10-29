md5="1722b37f4bb4cda1183351c0958a2d0e";rev="6408";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on}  ribbon (@var{x}, @var{y}, @var{width})
@deftypefnx {Archivo de funci@'on}  ribbon (@var{y})
@deftypefnx {Archivo de funci@'on}  @var{h} = ribbon (@dots{})
Grafica un gr@'afico de list@'on para las columnas de @var{y} en funci@'on 
de @var{x}. El par@'ametro opcional @var{width} especifica el ancho de un 
list@'on sencillo (el valor predetermiando es 0.75). Si se omite @var{x}, 
se asume un vector con el n@'umero de filas (1:rows(Y)). Si se requiere, 
retorna un vector @var{h} con los apuntadores a los objetos de tipo 
superficie.
@seealso{gca, colorbar}
@end deftypefn
