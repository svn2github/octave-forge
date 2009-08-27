md5="73c45236decd091d052d0f50846403cf";rev="6125";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} complement (@var{x}, @var{y})
Retorna los elementos del conjunto @var{y} que no est@'an en el conjunto  @var{x}. Por ejemplo,

@example
@group
complement ([ 1, 2, 3 ], [ 2, 3, 5 ])
@result{} 5
@end group
@end example
@seealso{create_set, union, intersection}
@end deftypefn
