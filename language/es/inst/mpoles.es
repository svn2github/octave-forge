md5="c9f58f177c6306f648b12f4761913926";rev="7333";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{multp}, @var{indx}] =} mpoles (@var{p})
@deftypefnx {Archivo de función} {[@var{multp}, @var{indx}] =} mpoles (@var{p}, @var{tol})
@deftypefnx {Archivo de función} {[@var{multp}, @var{indx}] =} mpoles (@var{p}, @var{tol}, @var{reorder})
Identifiquense los polos únicos en @var{p} y asociese su multiplicidad,
ordenándolos de mayor a menor.

Si la diferencia relativa de los polos es menor que @var{tol}, entonces
se consideran ser múltiplos. El valor predeterminado para @var{tol}
es 0,001.

Si el parámetro opcional @var{reorder} es cero, los polos no son
ordenados.

El valor de @var{multp} es un vector que especifica la multiplicidad
de los polos. @var{multp}(:) se refiere a la multiplicidad de @var{p}(@var{indx}(:)).

Por ejemplo,

@example
@group
p = [2 3 1 1 2];
[m, n] = mpoles(p);
@result{} m = [1; 1; 2; 1; 2]
@result{} n = [2; 5; 1; 4; 3]
@result{} p(n) = [3, 2, 2, 1, 1]
@end group
@end example

@seealso{poly, roots, conv, deconv, polyval, polyderiv, polyinteg, residue}
@end deftypefn 