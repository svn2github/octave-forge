md5="8b16797900f6cfe2c102e78e04c208c7";rev="7225";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{c}, @var{lev}] =}  contourc (@var{x}, @var{y}, @var{z}, @var{vn})
Calcula las isolíneas (líneas de contorno) de la matriz @var{z}. 
Los parámetros @var{x}, @var{y} and @var{vn} son opcionales.

El valor retornado @var{lev} es un vector de niveles de contorno.
El valor retornado @var{c} es una matriz 2 por @var{n} que contiene las líneas 
de contorno en el siguiente formato:

@example
@var{c} = [lev1, x1, x2, ..., levn, x1, x2, ... 
     len1, y1, y2, ..., lenn, y1, y2, ...]
@end example

@noindent
en donde la línea de contorno @var{n} tiene un nivel (altura) @var{levn} y
longitud @var{lenn}.

Si @var{x} y @var{y} se omiten, son tomados como el ídice fila/columna
de @var{z}. @var{vn} puede ser un escalar denotamdo el número de líneas 
a calcular o un vector con los valores de las líneas. Si solo se necesita un 
valor, establezca @code{@var{vn} = [val, val]}; Si @var{vn} se omite, el valor 
predeterminado es 10. Por ejemplo,

@example
@group
x = 0:2;
y = x;
z = x' * y;
contourc (x, y, z, 2:3)
@result{}   2.0000   2.0000   1.0000   3.0000   1.5000   2.0000
     2.0000   1.0000   2.0000   2.0000   2.0000   1.5000

@end group
@end example
@seealso{contour}
@end deftypefn
