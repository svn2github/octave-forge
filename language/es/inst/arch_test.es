md5="51719ae92355b48e957adac64ab8fcc6";rev="7201";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{pval}, @var{lm}] =} arch_test (@var{y}, @var{x}, @var{p})
Para un modelo de regresión lineal

@example
y = x * b + e
@end example

@noindent
realiza la prueba de hipótesis nula del multiplicador de Lagrange (LM) de 
no heteroscedascidad condicional en contra de la alternativa de CH(@var{p}).

P.e., el modelo es

@example
y(t) = b(1) * x(t,1) + @dots{} + b(k) * x(t,k) + e(t),
@end example

@noindent
dada @var{y} hasta @math{t-1} y @var{x} hasta @math{t},
@math{e}(t) es @math{N(0, h(t))} con

@example
h(t) = v + a(1) * e(t-1)^2 + @dots{} + a(p) * e(t-p)^2,
@end example

@noindent
y el nulo es @math{a(1)} == @dots{} == @math{a(p)} == 0.

Si el segundo argumento es un entero escalar, @math{k}, realiza la misma
prueba en un modelo de autoregresión lineal de orden @math{k}, p.e., con

@example
[1, y(t-1), @dots{}, y(t-@var{k})]
@end example

@noindent
como la @math{t}-ésima fila de @var{x}.

En caso de nulo, LM aproximadamente tiene una distribución chi-cuadrado con
@var{p} grados de libertad y @var{pval} es el valor @math{p} (1
menos la CDF de esta distribución en LM) para la prueba.

Si ningún argumento de salida es dado, el valor de @math{p} es mostrado.
@end deftypefn
