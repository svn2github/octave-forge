md5="cae532dacc2450302ed389e46c1f1527";rev="6224";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} damp (@var{p}, @var{tsam})
Muestra los valores propios, frecuencias naturales y coeficientes de amortiguaci@'on 
de los valores propios una matriz @var{p} o la matriz @math{A} de un 
sistema @var{p}, respectivamente.
Si @var{p} es un sistema, no se debe especificar @var{tsam}.
Si @var{p} es una matriz y se especifica @var{tsam}, se asume que los valores 
propios de @var{p} est@'an en el dominio @var{z}.
@seealso{eig}
@end deftypefn
