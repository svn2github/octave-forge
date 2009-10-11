md5="2d83522a56f7f37abd73d726c3922ead";rev="6301";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} isprime (@var{n})
Retorna 1 si @var{n} es un n@'umero primo, 0 en otro caso.

El siguiente ejemplo es m@'as r@'apido para probar si varios n@'umeros 
peque@~{n}os son primos:

@example
@var{t} = ismember (@var{n}, primes (max (@var{n} (:))));
@end example

Si max(n) es muy grande, se deber@'ia usar un c@'odigo especipal para 
realizar la feactorizaci@'on.

@seealso{primes, factor, gcd, lcm}
@end deftypefn
