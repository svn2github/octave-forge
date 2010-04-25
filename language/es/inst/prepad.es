md5="7ccaf2ddc956b9c1d9ea4526b169d1e8";rev="7238";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} prepad (@var{x}, @var{l}, @var{c})
@deftypefnx {Archivo de función} {} postpad (@var{x}, @var{l}, @var{c})
@deftypefnx {Archivo de función} {} postpad (@var{x}, @var{l}, @var{c}, @var{dim})

Antepone (anexa), el valor escalar @var{c} para el vector @var{x}
hasta que tenga una longitud @var{l}. Si el tercer argumento no es
suministrado, un valor de 0 es usado.

Si @code{length (@var{x}) > @var{l}},los elementos desde el comienzo 
(final) de @var{x} se eliminan hasta obtener un vector de longitud @var{l}.
 
Si @var{x} es una matriz, los elementos se Anteponen o son retirados de
cada fila.

Si el argumento opcional @var{dim} es dado, entonces opera a lo largo
de esta dimensión
@end deftypefn