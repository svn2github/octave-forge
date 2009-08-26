md5="4aaafb64b0943d4db855537a9ea6d21f";rev="6125";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {[@var{pval}, @var{chisq}, @var{df}] =} bartlett_test (@var{x1}, @dots{}) 
Realiza una prueba de Bartlett para la homogeniedad de las variazas en los vectores 
de datos @var{x1}, @var{x2}, @dots{}, @var{xk}, donde @var{k} > 1.

En virtud de la nulidad de igualdad de varianzas, la prueba 
estad@'istica @var{chisq} aproximadamente sigue una distribuci@'on 
chi-cuadrado con @var{df} grados de libertad.

El valor p (1 menos la función de distribución acumulada de esta distribuci@'on 
en @var{chisq}) es retornado en @var{pval}.

Si ning@'un argumento de salida es dado, el valor p es mostrado.
@end deftypefn
