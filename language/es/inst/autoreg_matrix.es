md5="7c49d8eddd0ea177c3ad5549ced7b728";rev="7223";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} autoreg_matrix (@var{y}, @var{k})
Dada una serie de tiempo (vector) @var{y}, returna una matriz con unos en la
primera columna y en los primeros @var{k} valores desfasados de @var{y} en las
otras columnas. P.e., para @var{t} > @var{k}, @code{[1,
@var{y}(@var{t}-1), @dots{}, @var{y}(@var{t}-@var{k})]} es la t-ésima fila
del resultado. La matriz resultante puede ser usada como una matriz regresora 
en autoregresiones.
@end deftypefn
