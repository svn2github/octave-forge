md5="63851307a6e65e565c3c682115bb9cb5";rev="7333";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{q}, @var{s}] =} qqplot (@var{x}, @var{dist}, @var{params})
Realiza una QQ-plot (Gráfica cuantil).

Si F es la CDF de la distribución @var{dist} con los parámetros
@var{params} y su inverso G, y @var{x} muestra un vector de longitud
@var{n}, los gráficos QQ-plot ordenados @var{s}(@var{i}) = @var{i}-ésima
elemento mayor de x abscisas frente @var{q}(@var{i}f) = G((@var{i} -
0.5)/@var{n}).

Si la muestra proviene de F a excepto para una transformación de la
localización y escala, los pares aproximadamente seguirán una línea
recta.

El valor predeterminado de @var{dist} es la distribución normal
estándar. El argumento opcional @var{params} contiene una lista de
parámetros de @var{dist}. Por ejemplo, para una gráfica cuantil de
la distribución uniforme en [2,4] y @var{x}, utilice

@example
qqplot (x, "uniform", 2, 4)
@end example

@noindent
@var{dist} puede ser cualquier cadena para la que una función 
@var{dist_inv} que calcula la inversa de la distribución de la CDF 
@var{dist} existente.

Si no son dados argumentos de salida, los datos son gráficados
directamente.
@end deftypefn
