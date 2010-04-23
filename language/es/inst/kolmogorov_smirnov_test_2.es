md5="4bb71a1f748b4d38c572194a7c36f6e9";rev="7231";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{pval}, @var{ks}, @var{d}] =} kolmogorov_smirnov_test_2 (@var{x}, @var{y}, @var{alt})
Realiza una prueba de dos muestras Kolmogorov-Smirnov de hipótesis nula 
tal que las muestras @var{x} y @var{y} provienen de la misma distribución (continua). 
Por ejemplo, Si F y G son las CDFs correspondientes a las muestras 
@var{x} y @var{y}, respectivamente, entonces la hipótesis nula es F == G.

Mediante la cadena de argumento opcional @var{alt}, se puede seleccionar la
alternativa de interes. Si @var{alt} es @code{"!="} o
@code{"<>"}, la hipótesis nula es probada con la alternativa bilatereal F != G. 
En este caso, el estadístico de prueba @var{ks} sigue una distribución  
Kolmogorov-Smirnov bilateral. Si @var{alt} es @code{">"}, se considera la 
alternativa unilateral F > G. De maneda simialr, para @code{"<"},
se considera la alternativa unilateral F < G. En este caso, el 
estadístico de prueba @var{ks} tiene una distribución Kolmogorov-Smirnov
unilateral. El valor predeterminada es el caso bilateral.

El valor p de la prueba se retorna en @var{pval}.

El tercer valor retornado, @var{d}, es el estadístico de prueba que representa la
máxima distancia vertical entre las dos funciones de distribución acumulada.

Si no se especifican argumentos de salida, se muestra el valor p.
@end deftypefn
