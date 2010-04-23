md5="c30032ea4f869a6d67b3e21ec1f03266";rev="7231";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} issymmetric (@var{x}, @var{tol})
Si @var{x} es simétrica dentro de la tolerancia especificada por 
@var{tol}, retorna la dimensión de @var{x}. En otro caso, retorna 0. 
Si se omite @var{tol}, use una tolerancia igual a la precisión de la 
máquina.

La matrix @var{x} se considera simétrica si @code{norm (@var{x} - 
@var{x}.', inf) / norm (@var{x}, inf) < @var{tol}}.
@seealso{size, rows, columns, length, ishermitian, ismatrix, isscalar,
issquare, isvector}
@end deftypefn
