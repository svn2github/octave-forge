md5="f33df5b1c68338f7d052768607a7ed1f";rev="7225";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} cross (@var{x}, @var{y}, @var{dim})
Calcula el producto vectorial entre dos vectores 3-dimensionales 
@var{x} y @var{y}.

@example
@group
cross ([1,1,0], [0,1,1])
@result{} [ 1; -1; 1 ]
@end group
@end example

Si @var{x} y @var{y} son matrices, el producto vectorial se aplica 
a lo largo de la primera dimensión con tres elementos. El argumento opcional 
@var{dim} se usa para forzar que el producto vectorial sea calculado a lo largo 
de la dimensión definida en @var{dim}.
@end deftypefn
