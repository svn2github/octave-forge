md5="defdbabc4e3b8461526c15fdef7110b8";rev="7236";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{n}, @var{c}] =} normest (@var{a}, @var{tol})
Estima la norma 2 de la matriz @var{a} mediante análisis de 
series de potencias. Este método se usa para matrices grandes, 
donde el costo de calcular @code{norm (@var{a})} es prohibido y una 
aproximación a la norma 2 es aceptable.

La variable @var{tol} es la tolerancia con la cual se calcula la 
norma 2. El valor predetermiando de @var{tol} es 1e-6. La variable 
@var{c} retorna el número de iteraciones requeridas por @code{normest} 
para converger.
@end deftypefn
