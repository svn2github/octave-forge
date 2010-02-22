md5="dec5ae668b90e7af69cc4ee061f9fa50";rev="6944";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} vander (@var{c})
Regresa la matriz de Vandermonde cuya pen@'ultima columna es @var{c}.

Una matriz Vandermonde tiene la forma:
@iftex
@tex
$$
\left[\matrix{c_1^{n-1}  & \cdots & c_1^2  & c_1    & 1      \cr
              c_2^{n-1}  & \cdots & c_2^2  & c_2    & 1      \cr
              \vdots     & \ddots & \vdots & \vdots & \vdots \cr
              c_n^{n-1}  & \cdots & c_n^2  & c_n    & 1      }\right]
$$
@end tex
@end iftex
@ifinfo

@example
@group
c(1)^(n-1) ... c(1)^2  c(1)  1
c(2)^(n-1) ... c(2)^2  c(2)  1
    .     .      .      .    .
    .       .    .      .    .
    .         .  .      .    .
c(n)^(n-1) ... c(n)^2  c(n)  1
@end group
@end example
@end ifinfo
@seealso{hankel, sylvester_matrix, hilb, invhilb, toeplitz}
@end deftypefn