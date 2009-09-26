md5="83e89d8ed302f5fc2b48cf0c89238c15";rev="6253";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {[@var{pval}, @var{f}, @var{df_num}, @var{df_den}] =} f_test_regression (@var{y}, @var{x}, @var{rr}, @var{r})
Realiza una prueba F de hip@'otesis nula @code{rr * b = r} en un modelo 
de regresi@'on normal @code{y = X * b + e}.

Bajo la hip@'otesis nula, el estad@'istico de prueba @var{f} sigue una 
distribuci@'on F con @var{df_num} y @var{df_den} grados de libertad. 

El valor p (1 menos la CDF de esta distribuci@'on en @var{f}) se 
retorna en @var{pval}.

Si no se da expl@'icitamente, se asume que @var{r} = 0.

Si no se da argumentos de salida, se muestra el valor p.
@end deftypefn
