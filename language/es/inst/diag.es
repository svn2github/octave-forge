md5="b2a0579f00fc61497ef4275c058402de";rev="7226";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {} diag (@var{v}, @var{k})
Retorna una matriz diagonal con el vector @var{v} en la diagonal @var{k}. El 
segundo argumento es opcional. Si es positivo, el vector es ubicado en 
la @var{k}-ésima superdiagonal. Si es negativo, es ubicado en la 
@var{-k}-ésima  subdiagonal. El valor predetermiando de @var{k} es 0, 
en este caso el vector se ubica en la diagona principal. Por ejemplo, 

@example
@group
diag ([1, 2, 3], 1)
     @result{}  
		 0  1  0  0
         0  0  2  0
         0  0  0  3
         0  0  0  0
@end group
@end example

@noindent
Si se da una matriz como argumento, en lugar de un vector, @code{diag} extrae la 
@var{k}-ésima diagonal de la matriz.
@end deftypefn
