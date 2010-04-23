md5="2d83522a56f7f37abd73d726c3922ead";rev="7231";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} isprime (@var{n})
Retorna 1 si @var{n} es un número primo, 0 en otro caso.

El siguiente ejemplo es más rápido para probar si varios números 
peque@~{n}os son primos:

@example
@var{t} = ismember (@var{n}, primes (max (@var{n} (:))));
@end example

Si max(n) es muy grande, se debería usar un código especipal para 
realizar la feactorización.

@seealso{primes, factor, gcd, lcm}
@end deftypefn
