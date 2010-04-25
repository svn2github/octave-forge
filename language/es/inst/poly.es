md5="6907e823cbf38ce81292b8d0d6d69d46";rev="7238";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} poly (@var{a})
Si @var{a} es una matriz cuadrada @math{N}-por-@math{N}, @code{poly (@var{a})}
es el vector fila de los coeficientes de @code{det (z * eye (N) - a)},
polinomio característico de @var{a}. como ejemplo podemos usar esto como
los valores propios de @var{a} como las racíces de @code{poly (@var{a})}.
@example
roots(poly(eye(3)))
@result{} 1.00000 + 0.00000i
@result{} 1.00000 - 0.00000i
@result{} 1.00000 + 0.00000i
@end example
En ejemplos reales usted debe, sin embargo, utilizar la function @code{eig}
para calular los valores propios.

Si @var{x} es un vector, @code{poly (@var{x})} es un vector de coeficientes
del polinomio cuyas raíces son los elementos de @var{x}. Es decir, 
a @var{c} es un polinomio, entonces los elementos de 
@code{@var{d} = roots (poly (@var{c}))} se encuentran en @var{c}.
Los vectores @var{c} y @var{d} son, sin embargo, no iguales debido a la 
clasificación y los errores numéricos.

@seealso{eig, roots}
@end deftypefn 