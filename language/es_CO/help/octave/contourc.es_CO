md5="8b16797900f6cfe2c102e78e04c208c7";rev="5951";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {[@var{c}, @var{lev}] =}  contourc (@var{x}, @var{y}, @var{z}, @var{vn})
Calcula las isol@'ineas (l@'ineas de contorno) de la matriz @var{z}. 
Los par@'ametros @var{x}, @var{y} and @var{vn} son opcionales.

El valor retornado @var{lev} es un vector de niveles de contorno.
El valor retornado @var{c} es una matriz 2 por @var{n} que contiene las l@'ineas 
de contorno en el siguiente formato:

@example
@var{c} = [lev1, x1, x2, ..., levn, x1, x2, ... 
     len1, y1, y2, ..., lenn, y1, y2, ...]
@end example

@noindent
en donde la l@'inea de contorno @var{n} tiene un nivel (altura) @var{levn} y
longitud @var{lenn}.

Si @var{x} y @var{y} se omiten, son tomados como el @'idice fila/columna
de @var{z}. @var{vn} puede ser un escalar denotamdo el n@'umero de l@'ineas 
a calcular o un vector con los valores de las l@'ineas. Si solo se necesita un 
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
