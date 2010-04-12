md5="2454e1188756094f4e0d5da4790983bd";rev="6166";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} kurtosis (@var{x}, @var{dim})
Si @var{x} es un vector de longitud @math{N}, retorna la curtosis
@iftex
@tex
$$
 {\rm kurtosis} (x) = {1\over N \sigma(x)^4} \sum_{i=1}^N (x_i-\bar{x})^4 - 3
$$
donde $\bar{x}$ es el valor medio de $x$.
@end tex
@end iftex
@ifinfo

@example
kurtosis (x) = N^(-1) std(x)^(-4) sum ((x - mean(x)).^4) - 3
@end example
@end ifinfo

@noindent
de @var{x}.  Si @var{x} es una matriz, retorna la curtosis sobre la 
primero dimensi@'on no sencilla. El argumento opcional @var{dim}
puede ser dado para forzar que la curtosis sea calculada sobre 
esa dimensi@'on.
@end deftypefn
