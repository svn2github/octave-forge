md5="8b8dad26d387448d2901fcae496d13ed";rev="6312";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} primes (@var{n})
Retorna todos los n@'umeros primos hasta @var{n}. 

N@'otese que si se necesita un n@'umero espec@'ifico de primos, 
se puede usar el hecho de que la distancia entre un primo y el 
siguiente es, en promedio, proporcional al logaritmo del primo. 
Integrando, se encuentra que existen aproximadamente @math{k} primos 
menores que @math{k \log ( 5 k )}.

El algoritmo usado es llamado la criba de Erat@'ostenes.
@end deftypefn
