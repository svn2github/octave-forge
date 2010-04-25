md5="105fea4b81a5bd434831a188e69dc0b0";rev="7239";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{pval}, @var{chisq}] =} run_test (@var{x})
Realiza un prueba chi-cuadrado con 6 grados de libertad basada en 
el recorrido hacia arriba de las columnas de @var{x}. Esta función puede ser usada para probar si @var{x} contiene datos independientes.

El valor p de la prueba se retorna en  @var{pval}.

Si no se especifican argumentos de salida, se muestra el valor p.
@end deftypefn
