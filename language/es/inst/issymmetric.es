md5="c30032ea4f869a6d67b3e21ec1f03266";rev="6377";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} issymmetric (@var{x}, @var{tol})
Si @var{x} es sim@'etrica dentro de la tolerancia especificada por 
@var{tol}, retorna la dimensi@'on de @var{x}. En otro caso, retorna 0. 
Si se omite @var{tol}, use una tolerancia igual a la precisi@'on de la 
m@'aquina.

La matrix @var{x} se considera sim@'etrica si @code{norm (@var{x} - 
@var{x}.', inf) / norm (@var{x}, inf) < @var{tol}}.
@seealso{size, rows, columns, length, ishermitian, ismatrix, isscalar,
issquare, isvector}
@end deftypefn
