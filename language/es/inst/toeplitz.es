md5="a5c4a1cec672f14b00483a7946464197";rev="7333";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} toeplitz (@var{c}, @var{r})
Devuelva la matriz de Toeplitz construida dada la primera columna @var{c},
y (opcionalmente) la primera fila @var{r}. Si el primer elemento de @var{c}
no es lo mismo que el primer elemento de @var{r}, el primer elemento de 
@var{c} es usado. Si el segundo argumento se omite, la primera fila es 
llevada a ser la misma que la primera columna.

Una matriz cuadrada Toeplitz tiene la forma:
@iftex
@tex
$$
\left[\matrix{c_0    & r_1     & r_2      & \cdots & r_n\cr
              c_1    & c_0     & r_1      & \cdots & r_{n-1}\cr
              c_2    & c_1     & c_0      & \cdots & r_{n-2}\cr
              \vdots & \vdots  & \vdots   & \ddots & \vdots\cr
              c_n    & c_{n-1} & c_{n-2} & \ldots & c_0}\right]
$$
@end tex
@end iftex
@ifinfo

@example
@group
c(0)  r(1)   r(2)  ...  r(n)
c(1)  c(0)   r(1)  ... r(n-1)
c(2)  c(1)   c(0)  ... r(n-2)
 .     ,      ,   .      .
 .     ,      ,     .    .
 .     ,      ,       .  .
c(n) c(n-1) c(n-2) ...  c(0)
@end group
@end example
@end ifinfo
@seealso{hankel, vander, sylvester_matrix, hilb, invhilb}
@end deftypefn
