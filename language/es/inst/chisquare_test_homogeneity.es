md5="5ba7130c66e8631796f88c77343ee946";rev="7225";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{pval}, @var{chisq}, @var{df}] =} chisquare_test_homogeneity (@var{x}, @var{y}, @var{c})
Dadas dos muestas @var{x} y @var{y}, realiza una prueba Chi cuadrado de 
homogeneidad de la hipótesis nula tal que @var{x} y @var{y} que vienen de 
la misma distribución, basad en una partición inducida por las
(estrictamente crecientes) entradas de @var{c}.

Para muestras grandes, el estadístico de prueba @var{chisq} sigue 
aproximadamente una distribución Chi cuadrado con @var{df} = @code{length (@var{c})} grados de libertad.

El valor p (1 menos la CDF de esta distribución en @var{chisq}) se
retorna en @var{pval}.

Si no se dán argumentos de salida, el valor p se muestra en la pantalla.
@end deftypefn
