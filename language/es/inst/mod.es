md5="ac6cc32b943502f56960d4f43cd069b1";rev="7236";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función de mapeo} {} mod (@var{x}, @var{y})
Calcula la función módulo, usando 

@example
x - y .* floor (x ./ y)
@end example

Nótese que esta función maneja los números negativos 
correctamente: @code{mod (-1, 3)} es 2, no -1 como retorna 
@code{rem (-1, 3)}. También, @code{mod (@var{x}, 0)} retorna 
@var{x}.

Si las dimensiones de los arreglos no coinciden o alguno de los 
argumentos es un número complejo, se imprime un mensaje de error.
@seealso{rem, round}
@end deftypefn
