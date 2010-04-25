md5="ff1193349d3df889de78bb0dd9b62151";rev="7238";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} polyout (@var{c}, @var{x})
Muestra el polinomio con formato 
@iftex
@tex
$$ c(x) = c_1 x^n + \ldots + c_n x + c_{n+1} $$
@end tex
@end iftex
@ifinfo
@example
   c(x) = c(1) * x^n + ... + c(n) x + c(n+1)
@end example
@end ifinfo
lo retorna como una cadena o lo muestra en la pantalla (si 
@var{nargout} es cero).
El valor predetermiando de la variable @var{x} es la cadena @code{"s"}.
@seealso{polyval, polyvalm, poly, roots, conv, deconv, residue,
filter, polyderiv, and polyinteg}
@end deftypefn
