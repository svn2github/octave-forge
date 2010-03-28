md5="260dde060c4b7c005c23489df197802f";rev="7136";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {[@var{xx}, @var{yy}, @var{zz}] =} meshgrid (@var{x}, @var{y}, @var{z})
@deftypefnx {Archivo de funci@'on} {[@var{xx}, @var{yy}] =} meshgrid (@var{x}, @var{y})
@deftypefnx {Archivo de funci@'on} {[@var{xx}, @var{yy}] =} meshgrid (@var{x})
Dados los vectores de coordenadas @var{x}, @var{y} y @var{z}, regresa
3 argumentos, regresa tres arreglos dimencionales correspondientes a 
las coordenadas @var{x}, @var{y} y @var{z} de una malla. Al regresar 
s@'olo 2 argumentos, regresa matrices correspondientes a las coordenadas
@var{x} y @var{y} de una malla. Las filas de @var{xx} son copias de 
@var{x}, y las columnas de @var{yy} son copias de @var{y}. Si @var{y}
es omitida, entonces se asume que tiene el mismo valor que @var{x}, y 
si @var{z} entonces se asume que tiene el mismo  valor que @var{y}.
@seealso{mesh, contour}
@end deftypefn