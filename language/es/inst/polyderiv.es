md5="d7754cd85023893d0920cdd53f807e27";rev="7238";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} polyderiv (@var{c})
@deftypefnx {Archivo de función} {[@var{q}] =} polyderiv (@var{b}, @var{a})
@deftypefnx {Archivo de función} {[@var{q}, @var{r}] =} polyderiv (@var{b}, @var{a})

Retorna los coeficientes de la derivada del polinomio cuyos coeficientes 
estan dados por el vector @var{c}. Si se suministra una pareja de polinomios 
@var{b} y @var{a}, se retorna la derivada del producto en @var{q}, o el numerador 
del cociente en @var{q} y el denomianador del cociente en @var{r}.

@seealso{poly, polyinteg, polyreduce, roots, conv, deconv, residue,
filter, polygcd, polyval, polyvalm}
@end deftypefn
