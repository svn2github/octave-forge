md5="2d13831de9df01c29164a5ab19b8383f";rev="6166";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {[@var{pval}, @var{k}, @var{df}] =} kruskal_wallis_test (@var{x1}, @dots{})
Realiza el "an@'alisis de variaza" Kruskal-Wallis de un factor.

Suponga una variable es observada para @var{k} > 1 grupos diferentes, y 
sea @var{x1}, @dots{}, @var{xk} los correspondientes vectores de datos.

Bajo la hip@'otesis nula de que el rango en la muestra colectiva no es 
afectado por la pertenencia a grupos, el estad@'istico de prueba @var{k} es
aproximadamente chi-cuadrada con @var{df} = @var{k} - 1 grados de libertad.

El valor p (1 menos la CDF de esta distribuci@'on en @var{k}) es
retornado en @var{pval}.

Si no se especifica argumento de salida, se muestra el valor p.
@end deftypefn
