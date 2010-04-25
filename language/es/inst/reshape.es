md5="a1af2d575f23f4221fc4ce1064873b67";rev="7239";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {} reshape (@var{a}, @var{m}, @var{n}, @dots{})
@deftypefnx {Función incorporada} {} reshape (@var{a}, @var{siz})
Regresa una matriz con las dimensiones en particular, cuyos elementos
son tomados de la matriz @var{a}. Los elementos de la matriz son introducidos
en el orden columna-mayor (La forma en que Fortran almacenadas los arreglos). 

Por ejemplo,

@example
@group
reshape ([1, 2, 3, 4], 2, 2)
     @result{}  1  3
         2  4
@end group
@end example

@noindent
Note que el número total de elementos en la matriz original
debe coincidir con el número total de elementos de la nueva matriz.

Una sola dimensión en la matriz resultante puede ser desconocida y es 
marcada por un argumento vacio.
@end deftypefn