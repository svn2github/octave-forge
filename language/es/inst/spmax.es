md5="468eeff302239bae8ffe5d43276d6ed3";rev="7333";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función de mapeo} {} spmax (@var{x}, @var{y}, @var{dim})
@deftypefnx {Función de mapeo} {[@var{w}, @var{iw}] =} spmax (@var{x})
@cindex Utility Functions
Para un argumento vector, devuelve el valor máximo. Para un argumento de
matriz, devuelve el valor máximo de cada columna, como un vector fila, o
sobre la dimensión @var{dim} si está definida. Para dos matrices (o una 
matriz y escalar), devuelva el máximo de pares.
Por lo tanto,

@example
max (max (@var{x}))
@end example

@noindent
regresa el mayor elemento de @var{x}, y

@example
@group
max (2:5, pi)
    @result{}  3.1416  3.1416  4.0000  5.0000
@end group
@end example
@noindent
compara cada elemento de el rango @code{2:5} con @code{pi}, y regresa
un vector fila de los máximos valores.

Para argumentos complejos, la magnitud de los elementos es usada para 
comparación.

Si se llama con un entrada y dos argumentos de salida, @code{max} 
también regresa los primeros índices de los máximos valores.
Por lo tanto.

@example
@group
[x, ix] = max ([1, 3, 5, 2, 5])
    @result{}  x = 5
        ix = 3
@end group
@end example
@end deftypefn
