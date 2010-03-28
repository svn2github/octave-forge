md5="6907e823cbf38ce81292b8d0d6d69d46";rev="7136";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} poly (@var{a})
Si @var{a} es una matriz cuadrada @math{N}-por-@math{N}, @code{poly (@var{a})}
es el vector fila de los coeficientes de @code{det (z * eye (N) - a)},
polinomio caracter@'istico de @var{a}. como ejemplo podemos usar esto como
los valores propios de @var{a} como las rac@'ices de @code{poly (@var{a})}.
@example
roots(poly(eye(3)))
@result{} 1.00000 + 0.00000i
@result{} 1.00000 - 0.00000i
@result{} 1.00000 + 0.00000i
@end example
En ejemplos reales usted debe, sin embargo, utilizar la function @code{eig}
para calular los valores propios.

Si @var{x} es un vector, @code{poly (@var{x})} es un vector de coeficientes
del polinomio cuyas ra@'ices son los elementos de @var{x}. Es decir, 
a @var{c} es un polinomio, entonces los elementos de 
@code{@var{d} = roots (poly (@var{c}))} se encuentran en @var{c}.
Los vectores @var{c} y @var{d} son, sin embargo, no iguales debido a la 
clasificaci@'on y los errores num@'ericos.

@seealso{eig, roots}
@end deftypefn 