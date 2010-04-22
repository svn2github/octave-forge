md5="fa53e3bb3eda8239ffae278a0c8b3c61";rev="7225";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{pval}, @var{chisq}, @var{df}] =} chisquare_test_independence (@var{x})
realiza una prueba de independencia chi-cuadrado basada en la tabla de 
contingencia @var{x}. En virtud de la hiótesis de independencia,
@var{chisq} tiene aproximadamente una distribución chi-cuadrado con
@var{df} grados de libertad.

El valor p (1 menos la CDF de esta distribución en @var{chisq}) se
retorna en @var{pval}.

Si no se dán argumentos de salida, el valor p se muestra en la pantalla.
@end deftypefn
