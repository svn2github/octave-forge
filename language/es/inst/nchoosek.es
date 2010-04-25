md5="0c833663e65b49955803d800422a01a0";rev="7236";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {@var{c} =} nchoosek (@var{n}, @var{k})

Calcule el coeficiente binomial o todas las combinaciones de @var{n}.
Si @var{n} es un escalar entonces, calcule el coeficiente binomial 
de @var{n} y @var{k}, definido como

@iftex
@tex
$$
 {n \choose k} = {n (n-1) (n-2) \cdots (n-k+1) \over k!}
               = {n! \over k! (n-k)!}
$$
@end tex
@end iftex
@ifinfo

@example
@group
 /   \
 | n |    n (n-1) (n-2) ... (n-k+1)       n!
 |   |  = ------------------------- =  ---------
 | k |               k!                k! (n-k)!
 \   /
@end group
@end example
@end ifinfo

Si @var{n} es un vector genera todas las combinaciones de los
elementos de @var{n}, tomando @var{k} a la vez, una fila para
cada combinación. El resultado @var{c} tiene el tama@~{n}o 
de @code{[nchoosek (length (@var{n}), @var{k}), @var{k}]}.
@seealso{bincoeff}
@end deftypefn