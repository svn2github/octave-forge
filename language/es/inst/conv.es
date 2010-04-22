md5="a4db42e2f89f1a71c495b7661aa07124";rev="7225";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} conv (@var{a}, @var{b})
Realiza la convolución sobre dos vectores.

@code{y = conv (a, b)} retorna un vector de longitud equivalente a
@code{length (a) + length (b) - 1}.
Si @var{a} y @var{b} son vectores de coeficientes de polinomios, @code{conv}
retorna los coeficientes del producto de polinomios.
@seealso{deconv, poly, roots, residue, polyval, polyderiv, polyinteg}
@end deftypefn
