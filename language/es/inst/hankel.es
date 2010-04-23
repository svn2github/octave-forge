md5="3c2f0c12355e71df829d4da3e6bb292c";rev="7230";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} hankel (@var{c}, @var{r})
Regresa la matriz de Hankel construida dados la primera columna @var{c}, y
(opcionalmente) la última fila @var{r}. Si el último elemento de @var{c},
no es el mismo que el primer elemento de @var{r}, el último elemento de
@var{c} es usado. Si se omite el segundo argumento, se supone que es un 
vector de ceros con el mismo tama@~{n}o que @var{c}.

Una matriz de Hankel formada a partir de un m-vector @var{c}, y un n-vector
@var{r}, tiene los elementos
@iftex
@tex
$$
H (i, j) = \cases{c_{i+j-1},&$i+j-1\le m$;\cr r_{i+j-m},&otherwise.\cr}
$$
@end tex
@end iftex
@ifinfo

@example
@group
H(i,j) = c(i+j-1),  i+j-1 <= m;
H(i,j) = r(i+j-m),  otherwise
@end group
@end example
@end ifinfo
@seealso{vander, sylvester_matrix, hilb, invhilb, toeplitz}
@end deftypefn