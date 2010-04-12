md5="71f0c67dcebd6c9f347c2c2377671df6";rev="6125";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} accumarray (@var{subs}, @var{vals}, @var{sz}, @var{fun}, @var{fillval}, @var{issparse})
@deftypefnx {Archivo de funci@'on} {} accumarray (@var{csubs}, @var{vals}, @dots{})


Crea una matriz de acumulaci@'on de los elementos de un vector en las 
posiciones definidas por sus sub@'indices. Los sub@'indices est@'an definidos 
por las filas de la matriz @var{subs} y los valores por @var{vals}. Cada 
fila de @var{subs} corresponde a uno de los valores en @var{vals}.

El tama@~no de la matriz ser@'a determinado por los sub@'indices mismos. 
Sin embargo, si @var{sz} est@'a definido, determina el tama@~no de la 
matriz. La longitud de @var{sz} debe corresponder con el n@'umero de columnas en @var{subs}.

La acci@'on predeterminada de @code{accumarray} es sumar los elementos con 
los mismos sub@'indices. Este comportamiento puede ser modificado definiendo 
la funci@'on @var{fun}. @'Esta deber@'ia ser una funci@'on o un manejador de funci@'on 
que acepta un vector columna y retorna un escalar. El resultado de la funci@'on 
no debe depender del orden de los sub@'indices.

Los elementos del arreglo retornado que no tienen sub@'indices asociados con 
ellos se ponen en cero. Definiendo @var{fillval} como otro valor permite 
que estos valores definidos.

En forma perdeterminada @code{accumarray} retorna una matriz completa. Si @var{issparse} 
es verdadero lógicamente, entonces una matriz dispersa es retornada en su lugar.

Un ejemplo del uso de @code{accumarray} es:

@example
@group
accumarray ([1,1,1;2,1,2;2,3,2;2,1,2;2,3,2], 101:105)
@result{} ans(:,:,1) = [101, 0, 0; 0, 0, 0]
   ans(:,:,2) = [0, 0, 0; 206, 0, 208]
@end group
@end example
@end deftypefn
