md5="320d18f1fae954721d0546eaaa103020";rev="7239";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {@var{s} =} rat (@var{x}, @var{tol})
@deftypefnx {Archivo de función} {[@var{n}, @var{d}] =} rat (@var{x}, @var{tol})
Encuentra una aproximación racional a @var{x} dentro de la tolerancia 
definida por @var{tol} mediante la expansión continua de fracciones. 
Por ejemplo, 

@example
rat(pi) = 3 + 1/(7 + 1/16) = 355/113
rat(e) = 3 + 1/(-4 + 1/(2 + 1/(5 + 1/(-2 + 1/(-7))))) 
       = 1457/536
@end example

Cuando se invoca con dos argumentos, retorna el numerador y el denominador 
separamente como dos matrices.
@end deftypefn
@seealso{rats}
