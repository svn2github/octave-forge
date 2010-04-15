md5="cb33f75dcf669b787c1219719936a44a";rev="7201";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci�n} {[@var{pval}, @var{f}, @var{df_b}, @var{df_w}] =} anova (@var{y}, @var{g})
Realiza un an�lisis unidireccional de la varianza (ANOVA). El objetivo es probar
si las medias de poblaci�n de datos tomados de @var{k} grupos 
diferentes son todas iguales.

Los datos podr�n presentarse en un �nico vector @var{y} con grupos especinficados por
un correspondiente vector de etiquetas de grupo @var{g} (p.e., n�meros de 1
a @var{k}). Esta es la forma general la cual no impone ninguna 
restricci�n en el n�mero de datos en cada grupo o grupo de etiquetas.

Si @var{y} es una matriz y @var{g} es omitido, cada columna de @var{y}
es tratada como un grupo. Esta forma solo es apropiada para ANOVA balanceada
en el cual los n�meros de las muestras de cada grupo son todos iguales.

En caso de ausencia de medias constantes, la estad�stica @var{f} sigue una 
distribuci�n F con @var{df_b} y @var{df_w} grados de libertad.

El valor p (1 menos la CDF de esta distribuci�n en @var{f}) es
retornado en @var{pval}.

Si ning�n argumento de salida es dado, la tabla estandar unidireccional ANOVA
es impresa.
@end deftypefn
