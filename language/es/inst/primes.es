md5="8b8dad26d387448d2901fcae496d13ed";rev="7238";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} primes (@var{n})
Retorna todos los números primos hasta @var{n}. 

Nótese que si se necesita un número específico de primos, 
se puede usar el hecho de que la distancia entre un primo y el 
siguiente es, en promedio, proporcional al logaritmo del primo. 
Integrando, se encuentra que existen aproximadamente @math{k} primos 
menores que @math{k \log ( 5 k )}.

El algoritmo usado es llamado la criba de Eratóstenes.
@end deftypefn
