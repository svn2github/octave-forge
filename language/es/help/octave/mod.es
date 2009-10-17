md5="ac6cc32b943502f56960d4f43cd069b1";rev="6315";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on de mapeo} {} mod (@var{x}, @var{y})
Calcula la funci@'on m@'odulo, usando 

@example
x - y .* floor (x ./ y)
@end example

N@'otese que esta funci@'on maneja los n@'umeros negativos 
correctamente: @code{mod (-1, 3)} es 2, no -1 como retorna 
@code{rem (-1, 3)}. Tambi@'en, @code{mod (@var{x}, 0)} retorna 
@var{x}.

Si las dimensiones de los arreglos no coinciden o alguno de los 
argumentos es un n@'umero complejo, se imprime un mensaje de error.
@seealso{rem, round}
@end deftypefn
