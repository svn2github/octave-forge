md5="52e68a7e95b71231226e762559e89a8c";rev="6125";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} create_set (@var{x})
Retorna un vector fila con los valores @'unicos en @var{x}, ordenados en
forma ascendente. Por ejemplo,

@example
@group
create_set ([ 1, 2; 3, 4; 4, 2 ])
@result{} [ 1, 2, 3, 4 ]
@end group
@end example
@seealso{union, intersection, complement}
@end deftypefn
