md5="f1bfcf92628cde00116c77a4b1a06ade";rev="7240";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} sprandsym (@var{n}, @var{d})
@deftypefnx {Archivo de función} {} sprandsym (@var{s})
Genera una matriz dispersa aleatoria simétrica. El tama@~{n}o de la
matriz pude ser @var{n} por @var{n}, con una densidad de valores dados 
por @var{d}. @var{d} debe estar entre 0 y 1. Los valores serán 
normalmente distribuidos con media de 0 y varianza 1.

Nota: algunas veces la densidad puede ser un bit mas peque@~{n}o que @var{d}.
Esto es poco probable que suceda para matrices dispersas muy grandes.

Si es llamada con un solo argumento de la matriz, una matriz dispersa 
aleatoria es generada donde la matriz @var{S} es distinta de cero en su 
parte triangular más baja.
@seealso{sprand, sprandn}
@end deftypefn
