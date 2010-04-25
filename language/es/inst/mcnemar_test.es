md5="2101e785be3424b422ec648a8faed5cf";rev="7236";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{pval}, @var{chisq}, @var{df}] =} mcnemar_test (@var{x})
Para una tabla cuadrada de contingencia de @var{x} de los datos 
clasificados en las variables de las filas y columnas, la prueba de 
McNemar prueba la hipótesis nula de simetría de las probabilidades 
de clasificación. 

En caso de la hipótesis nula, la variable @var{chisq} se distribuye 
aproximadamente como una chi cuadrado con @var{df} grados de libertad.

El valor @var{p} (1 menos la CDF de esta distribución en @var{chisq}) 
se retorna en  @var{pval}.

Si no se suministran argumentos, se muestra el valor @var{p} de la pueba.
@end deftypefn
