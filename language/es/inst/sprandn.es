md5="28e063286a466c981917da4943bed5ce";rev="7240";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} sprandn (@var{m}, @var{n}, @var{d})
@deftypefnx {Archivo de función} {} sprandn (@var{s})

Genera una matriz dispersa aleatoria. El tama@~{n}o de la matriz es 
@var{m} por @var{n}, con densidad @var{d} de valores. La variable 
@var{d} debería estar entre 0 y 1. Los valores estan distribuidos 
normalmente con media cero y variaza 1.

Nota: algunas veces la densidad real puede ser menor que @var{d}. 
Esto resultado es poco probable para matrices grandes.

Si se llama con una matriz como argumento, genera una matriz dispersa 
aleatoria en donde quiera que la matriz @var{S} es distinta de cero.

@seealso{sprand}
@end deftypefn
