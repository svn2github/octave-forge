md5="596948aa5d3ac95c6973427b3a70c1ca";rev="7333";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{p}, @var{y}] =} ppplot (@var{x}, @var{dist}, @var{params})
Realice un PP-plot (gráfico de probabilidad).

Si F es el de la CDF de la distribución @var{dist} con los
parámetros @var{params} y @var{x} muestra un vector de longitud
@var{n}, la gráfica PP-plot coordina @var{y}(@var{i}) = F (@var{i}-ésimo
elemento más grande de @var{x}) frente al eje de abscisas 
@var{p}(@var{i}) = (@var{i} - 0.5)/@var{n}. Si la muestra procede
de F, aproximadamente los pares seguirán una línea recta.

El valor predeterminado para @var{dist} es la distribución normal
estándar. El argumento opcional @var{params} contiene una lista de
parámetros de @var{dist}. Por ejemplo, para una gráfica de 
probabilidad de la distribución uniforme en [2,4] y @var{x}, se 
utiliza

@example
ppplot (x, "uniform", 2, 4)
@end example

@noindent
@var{dist} puede ser cualquier cadena para que una función @var{dist_cdf}
para calcular la CDF de la distribución @var{dist} existente.

Si los argumentos de salida no son dados, la información es gráficada
directamente.
@end deftypefn 