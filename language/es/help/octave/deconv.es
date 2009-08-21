md5="5744dc0e3afc6ff0deeed3119ba4c442";rev="6125";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} deconv (@var{y}, @var{a})
Deconvoluciona dos vectores.

@code{[b, r] = deconv (y, a)} resuelve @var{b} y @var{r} tal que 
@code{y = conv (a, b) + r}.

Si @var{y} y @var{a} son vectores de coeficientes de polinomios, @var{b} tendr@'a 
los coeficientes del cociente de polinomios y @var{r} ser@'a
el polinomio residuo de m@'as bajo orden.
@seealso{conv, poly, roots, residue, polyval, polyderiv, polyinteg}
@end deftypefn
