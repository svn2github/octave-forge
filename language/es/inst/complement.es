md5="73c45236decd091d052d0f50846403cf";rev="7225";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} complement (@var{x}, @var{y})
Retorna los elementos del conjunto @var{y} que no están en el conjunto  @var{x}. Por ejemplo,

@example
@group
complement ([ 1, 2, 3 ], [ 2, 3, 5 ])
@result{} 5
@end group
@end example
@seealso{create_set, union, intersection}
@end deftypefn
