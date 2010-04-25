md5="49225ab7301bfee86e3e453873ec5a7d";rev="7241";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} union (@var{x}, @var{y})
Retorna el conjunto de elementos que están en el conjunto @var{x} 
y @var{y}. Por ejemplo,

@example
@group
union ([ 1, 2, 4 ], [ 2, 3, 5 ])
@result{} [ 1, 2, 3, 4, 5 ]
@end group
@end example
@seealso{create_set, intersection, complement}
@end deftypefn
