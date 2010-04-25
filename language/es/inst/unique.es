md5="0d413d5c8aef736f0d23baaab91d5ee3";rev="7241";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} unique (@var{x})
@deftypefnx {Archivo de función} {} unique (@var{A}, 'rows')
@deftypefnx {Archivo de función} {[@var{y}, @var{i}, @var{j}] = } unique (@var{x})

Retorna los elementos únicos de @var{x}, organizados en orden ascendente. 
Si @var{x} es un vector fila, retorna un vector fila, pero si @var{x} 
es un vector columna o una matriz, retorna un vector columna. 

Si se especifica el argumento opcional 'rows', retorna las filas únicas de @var{A}, 
organiazadas en orden ascendente.

Si se especifican los argumentos @var{i} y @var{j}, retorna los índices @var{i} y @var{j}, 
tales que @code{x(i)==y} y @code{y(j)==x}.
@seealso{union, intersect, setdiff, setxor, ismember}
@end deftypefn
