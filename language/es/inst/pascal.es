md5="b641e5be621511488d572214e47e161a";rev="7238";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} pascal (@var{n}, @var{t})

Retorna la matriz de Pascal de orden @var{n} si @code{@var{t} = 0}.
El valor predetermiando de @var{t} es 0. 

Retorna el factor de Cholesky triangular inferior de la matriz de 
Pascal si @code{@var{t} = 1}. Esta matriz es su propia inversa, es 
decir @code{pascal (@var{n}, 1) ^ 2 == eye (@var{n})}.

Si @code{@var{t} = 2}, retorna una versión traspuesta y permutada 
de @code{pascal (@var{n}, 1)}, la cual es la raíz cúbica de la 
matriz identidad. Es dedir, @code{pascal (@var{n}, 2) ^ 3 == eye (@var{n})}.

@seealso{hankel, vander, sylvester_matrix, hilb, invhilb, toeplitz
          hadamard, wilkinson, compan, rosser}
@end deftypefn
