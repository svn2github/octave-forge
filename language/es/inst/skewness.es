md5="e9d8568ce2d5fc8d264d74d6db0afb16";rev="7239";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} skewness (@var{x}, @var{dim})
Si @var{x} es un vector de longitud @math{n}, retorna la asimetría 
@iftex
@tex
$$
{\rm skewness} (x) = {1\over N \sigma(x)^3} \sum_{i=1}^N (x_i-\bar{x})^3
$$
donde $\bar{x}$ es el valor medio de $x$.
@end tex
@end iftex
@ifinfo

@example
skewness (x) = N^(-1) std(x)^(-3) sum ((x - mean(x)).^3)
@end example
@end ifinfo

@noindent
de @var{x}. Si @var{x} es una matriz, retorna la asimetría a lo 
largo de la primera dimensión no singleton de la matriz. Si se 
suministra el parámetro opcional @var{dim}, realiza el cálculo 
a lo largo de esta dimensión. 
@end deftypefn
