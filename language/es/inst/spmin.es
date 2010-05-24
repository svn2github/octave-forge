md5="383cb320d9f1f5c7f36aa73f1d4b809a";rev="7333";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función de mapeo} {} spmin (@var{x}, @var{y}, @var{dim})
@deftypefnx {Función de mapeo} {[@var{w}, @var{iw}] =} spmin (@var{x})
@cindex Utility Functions
Para un argumento vector, devuelva el valor mínimo. Para un argumento
de matriz, devuelve el valor mínimo de cada columna, como un vector fila,
o sobre la dimensión @var{dim} si está definida. Para dos matrices (o una
matriz y escalar), devuelva el mínimo de pares.
Por lo tanto,

@example
min (min (@var{x}))
@end example

@noindent
regresa el menor elemento de @var{x}, y 

@example
@group
min (2:5, pi)
    @result{}  2.0000  3.0000  3.1416  3.1416
@end group
@end example
@noindent
compara cada elemento de el rango @code{2:5} con @code{pi}, y regresa
un vector fila de los mínimos valores.

Para argumentos complejos, la magnitud de los elementos es usada para 
comparacion.

Si se llama con un argumento de entrada y dos de salida, @code{min}
también regresa el primer indice de los mínimos valores.
Por lo tanto,

@example
@group
[x, ix] = min ([1, 3, 0, 2, 5])
    @result{}  x = 0
        ix = 3
@end group
@end example
@end deftypefn
