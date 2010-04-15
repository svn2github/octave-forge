md5="71f0c67dcebd6c9f347c2c2377671df6";rev="7199";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} accumarray (@var{subs}, @var{vals}, @var{sz}, @var{fun}, @var{fillval}, @var{issparse})
@deftypefnx {Archivo de función} {} accumarray (@var{csubs}, @var{vals}, @dots{})


Crea una matriz de acumulación de los elementos de un vector en las 
posiciones definidas por sus subíndices. Los subíndices están definidos 
por las filas de la matriz @var{subs} y los valores por @var{vals}. Cada 
fila de @var{subs} corresponde a uno de los valores en @var{vals}.

El tamaño de la matriz será determinado por los subíndices mismos. 
Sin embargo, si @var{sz} está definido, determina el tamaño de la 
matriz. La longitud de @var{sz} debe corresponder con el número de columnas en @var{subs}.

La acción predeterminada de @code{accumarray} es sumar los elementos con 
los mismos subíndices. Este comportamiento puede ser modificado definiendo 
la función @var{fun}. Ésta debería ser una función o un apuntador de función 
que acepta un vector columna y retorna un escalar. El resultado de la función 
no debe depender del orden de los subíndices.

Los elementos del arreglo retornado que no tienen subíndices asociados con 
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
