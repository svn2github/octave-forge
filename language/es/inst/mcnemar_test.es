md5="2101e785be3424b422ec648a8faed5cf";rev="6433";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {[@var{pval}, @var{chisq}, @var{df}] =} mcnemar_test (@var{x})
Para una tabla cuadrada de contingencia de @var{x} de los datos 
clasificados en las variables de las filas y columnas, la prueba de 
McNemar prueba la hip@'otesis nula de simetr@'ia de las probabilidades 
de clasificaci@'on. 

En caso de la hip@'otesis nula, la variable @var{chisq} se distribuye 
aproximadamente como una chi cuadrado con @var{df} grados de libertad.

El valor @var{p} (1 menos la CDF de esta distribuci@'on en @var{chisq}) 
se retorna en  @var{pval}.

Si no se suministran argumentos, se muestra el valor @var{p} de la pueba.
@end deftypefn
