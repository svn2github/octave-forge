md5="d7d8c3f0828801ae03034533c05d37af";rev="7230";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} hilb (@var{n})
Retorna matriz de Hilbert de orden @var{n}. El 
@iftex
@tex
$i,\,j$
@end tex
@end iftex
@ifinfo
i, j
@end ifinfo
elemento de una matriz de Hilbert se difine como 
@iftex
@tex
$$
H (i, j) = {1 \over (i + j - 1)}
$$
@end tex
@end iftex
@ifinfo

@example
H (i, j) = 1 / (i + j - 1)
@end example
@end ifinfo
@seealso{hankel, vander, sylvester_matrix, invhilb, toeplitz}
@end deftypefn
