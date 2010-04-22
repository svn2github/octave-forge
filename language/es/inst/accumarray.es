md5="71f0c67dcebd6c9f347c2c2377671df6";rev="7223";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funciÃ³n} {} accumarray (@var{subs}, @var{vals}, @var{sz}, @var{fun}, @var{fillval}, @var{issparse})
@deftypefnx {Archivo de funciÃ³n} {} accumarray (@var{csubs}, @var{vals}, @dots{})


Crea una matriz de acumulaciÃ³n de los elementos de un vector en las 
posiciones definidas por sus subÃ­ndices. Los subÃ­ndices estÃ¡n definidos 
por las filas de la matriz @var{subs} y los valores por @var{vals}. Cada 
fila de @var{subs} corresponde a uno de los valores en @var{vals}.

El tamaÃ±o de la matriz serÃ¡ determinado por los subÃ­ndices mismos. 
Sin embargo, si @var{sz} estÃ¡ definido, determina el tamaÃ±o de la 
matriz. La longitud de @var{sz} debe corresponder con el nÃºmero de columnas en @var{subs}.

La acciÃ³n predeterminada de @code{accumarray} es sumar los elementos con 
los mismos subÃ­ndices. Este comportamiento puede ser modificado definiendo 
la funciÃ³n @var{fun}. Ãsta deberÃ­a ser una funciÃ³n o un apuntador de funciÃ³n 
que acepta un vector columna y retorna un escalar. El resultado de la funciÃ³n 
no debe depender del orden de los subÃ­ndices.

Los elementos del arreglo retornado que no tienen subÃ­ndices asociados con 
ellos se ponen en cero. Definiendo @var{fillval} como otro valor permite 
que estos valores definidos.

En forma perdeterminada @code{accumarray} retorna una matriz completa. Si @var{issparse} 
es verdadero lÃ³gicamente, entonces una matriz dispersa es retornada en su lugar.

Un ejemplo del uso de @code{accumarray} es:

@example
@group
accumarray ([1,1,1;2,1,2;2,3,2;2,1,2;2,3,2], 101:105)
@result{} ans(:,:,1) = [101, 0, 0; 0, 0, 0]
   ans(:,:,2) = [0, 0, 0; 206, 0, 208]
@end group
@end example
@end deftypefn
