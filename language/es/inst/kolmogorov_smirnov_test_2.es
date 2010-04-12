md5="4bb71a1f748b4d38c572194a7c36f6e9";rev="6166";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {[@var{pval}, @var{ks}, @var{d}] =} kolmogorov_smirnov_test_2 (@var{x}, @var{y}, @var{alt})
Realiza una prueba de dos muestras Kolmogorov-Smirnov de hip@'otesis nula 
tal que las muestras @var{x} y @var{y} provienen de la misma distribuci@'on (continua). 
Por ejemplo, Si F y G son las CDFs correspondientes a las muestras 
@var{x} y @var{y}, respectivamente, entonces la hip@'otesis nula es F == G.

Mediante la cadena de argumento opcional @var{alt}, se puede seleccionar la
alternativa de interes. Si @var{alt} es @code{"!="} o
@code{"<>"}, la hip@'otesis nula es probada con la alternativa bilatereal F != G. 
En este caso, el estad@'istico de prueba @var{ks} sigue una distribuci@'on  
Kolmogorov-Smirnov bilateral. Si @var{alt} es @code{">"}, se considera la 
alternativa unilateral F > G. De maneda simialr, para @code{"<"},
se considera la alternativa unilateral F < G. En este caso, el 
estad@'istico de prueba @var{ks} tiene una distribuci@'on Kolmogorov-Smirnov
unilateral. El valor predeterminada es el caso bilateral.

El valor p de la prueba se retorna en @var{pval}.

El tercer valor retornado, @var{d}, es el estad@'istico de prueba que representa la
m@'axima distancia vertical entre las dos funciones de distribuci@'on acumulada.

Si no se especifican argumentos de salida, se muestra el valor p.
@end deftypefn
