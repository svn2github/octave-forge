md5="23a1234bb805dc7607765026d478888e";rev="7223";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{a}, @var{b}] =} arch_fit (@var{y}, @var{x}, @var{p}, @var{iter}, @var{gamma}, @var{a0}, @var{b0})
Ajusta un modelo de regresión ARCH a la serie de tiempo @var{y} usando el 
algoritmo de scoring de Engle publicado en el artículo original de ARCH. El modelo es

@example
y(t) = b(1) * x(t,1) + ... + b(k) * x(t,k) + e(t),
h(t) = a(1) + a(2) * e(t-1)^2 + ... + a(p+1) * e(t-p)^2
@end example

@noindent
en el cual @math{e(t)} es @math{N(0, h(t))}, dado un vector de serie de tiempo
@var{y} hasta el tiempo @math{t-1} y una matriz de regresores (ordinarios)
@var{x} hasta @math{t}. El orden de la regresión de la varianza residual 
es especificado por @var{p}.

Si es invocado como @code{arch_fit (@var{y}, @var{k}, @var{p})} con un
entero positivo @var{k}, ajusta un ARCH(@var{k}, @var{p}) proceso,
p.e., realiza el anterior con la @math{t}-ésima fila de @var{x} dada por

@example
[1, y(t-1), ..., y(t-k)]
@end example

Opcionalmente, uno puede especificar el número de iteraciones @var{iter}, el 
factor de actualización @var{gamma}, y los valores iniciales @math{a0} y
@math{b0} para el algoritmo de scoring.
@end deftypefn
