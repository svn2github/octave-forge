md5="3a64aa3404bf5ca116fa92403fdac5e9";rev="7333";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función de mapeo} {} max (@var{x}, @var{y}, @var{dim})
@deftypefnx {Función de mapeo} {[@var{w}, @var{iw}] =} max (@var{x})
@cindex Utility Functions
Para un argumento vector, devuelva el valor máximo. Para un argumento
de matriz, devuelve el valor máximo de cada columna, como un vector fila,
o sobre la dimensión @var{dim} si está definida. Para dos matrices (o una
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
compara cada elemento del rango @code{2:5} con @code{pi}, y devuelve un
vector fila de los valores máximos.

Para los argumentos complejos, la magnitud de los elementos se utilizan
para la comparación.

Si se llama con una entrada y dos argumentos de salida,
@code{max} devuelve también el primer índice del valor(es) máximo (s).
Por lo tanto,

@example
@group
[x, ix] = max ([1, 3, 5, 2, 5])
    @result{}  x = 5
        ix = 3
@end group
@end example
@end deftypefn
