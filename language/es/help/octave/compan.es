md5="158fbf32d5b31ee07a7ec13db1add174";rev="6125";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} compan (@var{c})
Calcula la matriz compa@~{n}era correspondiente al vector de coeficientes de polinomio @var{c}.

La matriz compa@~{n}era es
@iftex
@tex
$$
A = \left[\matrix{
 -c_2/c_1 & -c_3/c_1 & \cdots & -c_N/c_1 & -c_{N+1}/c_1\cr
     1    &     0    & \cdots &     0    &         0   \cr
     0    &     1    & \cdots &     0    &         0   \cr
  \vdots  &   \vdots & \ddots &  \vdots  &      \vdots \cr
     0    &     0    & \cdots &     1    &         0}\right].
$$
@end tex
@end iftex
@ifnottex

@smallexample
     _                                                        _
    |  -c(2)/c(1)   -c(3)/c(1)  ...  -c(N)/c(1)  -c(N+1)/c(1)  |
    |       1            0      ...       0             0      |
    |       0            1      ...       0             0      |
A = |       .            .   .            .             .      |
    |       .            .       .        .             .      |
    |       .            .           .    .             .      |
    |_      0            0      ...       1             0     _|
@end smallexample
@end ifnottex

Los valores propios de la matriz compa@~{n}era son iguales a las raices del polinomio.
@seealso{poly, roots, residue, conv, deconv, polyval, polyderiv,
polyinteg}
@end deftypefn
