md5="7b2e15a880c05b61ce67119fa98753b4";rev="7226";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función cargable} {@var{p} =} dmperm (@var{s})
@deftypefnx {Función cargable} {[@var{p}, @var{q}, @var{r}, @var{s}] =} dmperm (@var{s})
@cindex Dulmage-Mendelsohn decomposition
Realiza una permutación Dulmage-Mendelsohn sobre la matriz dispersa @var{s}.
Con un único argumento de salida @dfn{dmperm}, realiza la permutación 
de la fila @var{p} tal que @code{@var{s} (@var{p},:)} tiene elementos 
distintos ceros en la diagonal.

Cuando se llama con dos o más argumentos de salida, retorna la fila 
y columna de permutaciones, tal que @code{@var{s} (@var{p}, @var{q})} es un bloque 
triangular. Los valores de @var{r} y @var{s} define los límites de 
los bloques. Si @var{s} es cuadrada, entonces @code{@var{r} == @var{s}}.

El método usado se describe en: A. Pothen & C.-J. Fan. Computing the block
triangular form of a sparse matrix. ACM Trans. Math. Software,
16(4):303-324, 1990.
@seealso{colamd, ccolamd}
@end deftypefn
