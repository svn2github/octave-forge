md5="a6767bdb29d48062a74e67e1bc480f8c";rev="7231";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} isdefinite (@var{x}, @var{tol})
Retorna 1 si @var{x} es simétrica positiva definida dentro de la 
tolerancia especificada por @var{tol} o 0 si @var{x} es simétrica 
positiva semidefinida. En otro caso, return -1. Si se omite @var{tol}, 
usa la tolerancia igual a 100 veces la precisión de la máquina. 
@seealso{issymmetric}
@end deftypefn
