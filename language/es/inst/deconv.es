md5="5744dc0e3afc6ff0deeed3119ba4c442";rev="7226";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} deconv (@var{y}, @var{a})
Deconvoluciona dos vectores.

@code{[b, r] = deconv (y, a)} resuelve @var{b} y @var{r} tal que 
@code{y = conv (a, b) + r}.

Si @var{y} y @var{a} son vectores de coeficientes de polinomios, @var{b} tendrá 
los coeficientes del cociente de polinomios y @var{r} será
el polinomio residuo de más bajo orden.
@seealso{conv, poly, roots, residue, polyval, polyderiv, polyinteg}
@end deftypefn
