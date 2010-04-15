md5="461be9464be7352733c9a42cff2349c5";rev="7201";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} area (@var{x}, @var{y})
@deftypefnx {Archivo de función} {} area (@var{x}, @var{y}, @var{lvl})
@deftypefnx {Archivo de función} {} area (@dots{}, @var{prop}, @var{val}, @dots{})
@deftypefnx {Archivo de función} {} area (@var{y}, @dots{})
@deftypefnx {Archivo de función} {} area (@var{h}, @dots{})
@deftypefnx {Archivo de función} {@var{h} =} area (@dots{})
Grafica el área de la suma acumulativa de las columnas de @var{y}. 
Muestra las contribuciones de un valor a la suma, y es funcionalmente 
similar a @code{plot (@var{x}, cumsum (@var{y}, 2))}, excepto que el 
área bajo la curva es sombreada.

Si el argumento @var{x} es omitido se asume que está dado por
@code{1 : rows (@var{y})}. El valor @var{lvl} puede ser usado para  
determinar el nivel base del sombreado bajo la curva.

Argumentos adicionales a la función @code{area} son pasados mediante el 
@code{patch}. El valor opcional retornado @var{h} proporciona un manipulador de  
la lista de objetos de tipo patch.
@seealso{plot, patch}
@end deftypefn
