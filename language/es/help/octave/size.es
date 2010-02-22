md5="5e45629b93ceb0ba1224360873fe7030";rev="6944";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {} size (@var{a}, @var{n})
Retorna el n@'umero de filas y columnas de @var{a}.

Con un argumento de entrada y un argumento de salida, se devuelve el
resultado en un vector fila. Si hay argumentos de salida m@'ultiples,
el n@'umero de filas se asigna al primera, y el n@'umero de columnas a
la segunda, etc Por ejemplo,

@example
@group
size ([1, 2; 3, 4; 5, 6])
     @result{} [ 3, 2 ]

[nr, nc] = size ([1, 2; 3, 4; 5, 6])
     @result{} nr = 3
     @result{} nc = 2
@end group
@end example

Si se le da un segundo argumento, @code{size} devolver@'a el tama@~{n}o de 
la dimensi@'on correspondiente. Por ejemplo

@example
size ([1, 2; 3, 4; 5, 6], 2)
     @result{} 2
@end example

@noindent
regresa el n@'umero de columnas de la matriz dada.
@seealso{numel}
@end deftypefn