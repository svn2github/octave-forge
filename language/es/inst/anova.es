md5="cb33f75dcf669b787c1219719936a44a";rev="6125";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {[@var{pval}, @var{f}, @var{df_b}, @var{df_w}] =} anova (@var{y}, @var{g})
Realiza un an@'alisis unidireccional de la varianza (ANOVA). El objetivo es probar
si las medias de poblaci@'on de datos tomados de @var{k} grupos 
diferentes son todas iguales.

Los datos podr@'an presentarse en un @'unico vector @var{y} con grupos especinficados por
un correspondiente vector de etiquetas de grupo @var{g} (p.e., n@'umeros de 1
a @var{k}). Esta es la forma general la cual no impone ninguna 
restricci@'on en el n@'umero de datos en cada grupo o grupo de etiquetas.

Si @var{y} es una matriz y @var{g} es omitido, cada columna de @var{y}
es tratada como un grupo. Esta forma solo es apropiada para ANOVA balanceada
en el cual los n@'umeros de las muestras de cada grupo son todos iguales.

En caso de ausencia de medias constantes, la estad@'istica @var{f} sigue una 
distribuci@'on F con @var{df_b} y @var{df_w} grados de libertad.

El valor p (1 menos la CDF de esta distribuci@'on en @var{f}) es
retornado en @var{pval}.

Si ning@'un argumento de salida es dado, la tabla estandar unidireccional ANOVA
es impresa.
@end deftypefn
