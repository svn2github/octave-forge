md5="34304b89c6b3683f4ae9c948ba3d44c6";rev="7236";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función cargable} {[@var{l}, @var{u}, @var{p}] =} lu (@var{a})
@cindex LU decomposition
Calcula la factorización LU de @var{a}, mediante las subrutinas de 
@sc{Lapack}. El resultado se retorna en forma permutada, acorde con el 
valor opcional de retorno @var{p}. Por ejemplo, dada la matriz 
@code{a = [1, 2; 3, 4]},

@example
[l, u, p] = lu (a)
@end example

@noindent
returns

@example
l =

  1.00000  0.00000
  0.33333  1.00000

u =

  3.00000  4.00000
  0.00000  0.66667

p =

  0  1
  1  0
@end example

No se requiere que la matriz sea cuadrada. 
@end deftypefn
