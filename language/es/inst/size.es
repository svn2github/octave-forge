md5="5e45629b93ceb0ba1224360873fe7030";rev="7239";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {} size (@var{a}, @var{n})
Retorna el número de filas y columnas de @var{a}.

Con un argumento de entrada y un argumento de salida, se devuelve el
resultado en un vector fila. Si hay argumentos de salida múltiples,
el número de filas se asigna al primera, y el número de columnas a
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

Si se le da un segundo argumento, @code{size} devolverá el tama@~{n}o de 
la dimensión correspondiente. Por ejemplo

@example
size ([1, 2; 3, 4; 5, 6], 2)
     @result{} 2
@end example

@noindent
regresa el número de columnas de la matriz dada.
@seealso{numel}
@end deftypefn