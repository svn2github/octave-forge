md5="83e89d8ed302f5fc2b48cf0c89238c15";rev="7229";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{pval}, @var{f}, @var{df_num}, @var{df_den}] =} f_test_regression (@var{y}, @var{x}, @var{rr}, @var{r})
Realiza una prueba F de hipótesis nula @code{rr * b = r} en un modelo 
de regresión normal @code{y = X * b + e}.

Bajo la hipótesis nula, el estadístico de prueba @var{f} sigue una 
distribución F con @var{df_num} y @var{df_den} grados de libertad. 

El valor p (1 menos la CDF de esta distribución en @var{f}) se 
retorna en @var{pval}.

Si no se da explícitamente, se asume que @var{r} = 0.

Si no se da argumentos de salida, se muestra el valor p.
@end deftypefn
