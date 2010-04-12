md5="7bd5adb4eebd5b7ff41f712d5c7ac7e5";rev="6461";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} sprand (@var{m}, @var{n}, @var{d})
@deftypefnx {Archivo de funci@'on} {} sprand (@var{s})
Genera una matriz dispersa aleatoria. El tama@~{n}o de la matriz es 
@var{m} por @var{n}, con una densidad @var{d} de valores. La variable 
@var{d} deber@'ia estar entre 0 y 1. Los valores son distribuidos 
uniformemente entre 0 y 1.

Nota: algunas veces la densidad real puede ser un poco menor que @var{d}. 
Es improbable que suceda esto para matrices grandes. 

Si se llama con una matriz como argumento, se produce una matriz dispersa 
aleatoria en cualquier lugar que @var{S} sea distinto de cero.
@seealso{sprandn}
@end deftypefn
