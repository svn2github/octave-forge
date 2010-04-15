md5="cb33f75dcf669b787c1219719936a44a";rev="7201";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{pval}, @var{f}, @var{df_b}, @var{df_w}] =} anova (@var{y}, @var{g})
Realiza un análisis unidireccional de la varianza (ANOVA). El objetivo es probar
si las medias de población de datos tomados de @var{k} grupos 
diferentes son todas iguales.

Los datos podrán presentarse en un único vector @var{y} con grupos especinficados por
un correspondiente vector de etiquetas de grupo @var{g} (p.e., números de 1
a @var{k}). Esta es la forma general la cual no impone ninguna 
restricción en el número de datos en cada grupo o grupo de etiquetas.

Si @var{y} es una matriz y @var{g} es omitido, cada columna de @var{y}
es tratada como un grupo. Esta forma solo es apropiada para ANOVA balanceada
en el cual los números de las muestras de cada grupo son todos iguales.

En caso de ausencia de medias constantes, la estadística @var{f} sigue una 
distribución F con @var{df_b} y @var{df_w} grados de libertad.

El valor p (1 menos la CDF de esta distribución en @var{f}) es
retornado en @var{pval}.

Si ningún argumento de salida es dado, la tabla estandar unidireccional ANOVA
es impresa.
@end deftypefn
