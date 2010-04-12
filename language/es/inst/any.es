md5="c2463a2a49f0e68a56588d18c2f280d5";rev="6125";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {} any (@var{x}, @var{dim})
Para un vector como argumento, retorna 1 si cualquier elemento del vector es 
distinto de cero.

Para una matriz como argumento, retorna un vector fila de 1's y
0's con cada elemento indicando si alguno de los elementos de la
correspondiente columna de la matriz es distinto de cero. Por ejemplo,

@example
@group
any (eye (2, 4))
     @result{} [ 1, 1, 0, 0 ]
@end group
@end example

Si el agumento opcional @var{dim} es proporcionado, opera a lo largo 
de la dimensi@'on @var{dim}. Por ejemplo,

@example
@group
any (eye (2, 4), 2)
     @result{} [ 1; 1 ]
@end group
@end example
@end deftypefn
