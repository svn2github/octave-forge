md5="4c69e732dbbe132bd18f8beadaebf52a";rev="7229";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} fail (@var{code},@var{pattern})
@deftypefnx {Archivo de función} {} fail (@var{code},'warning',@var{pattern})
Retorna true si @var{code} falla con un mensaje de error que coincide con 
el patrón @var{pattern}, en otro caso produce un error. Nótese que @var{code} 
es una cadena y si @var{code} se ejecuta exitosamente, el error que se produce es:

@example
          expected error but got none  
@end example

Si el código falla con un error diferente, el mensaje que se produce es:

@example
          expected <pattern>
          but got <text of actual error>
@end example

Los paréntesis angulares no son parte de la salida.

Cuando se llama con tres argumentos, el comportamiento es similar a 
@code{fail(@var{code}, @var{pattern})}, pero produce un error si no se presenta 
ninguna advertencia durante la ejecución del código o si el código falla.
@end deftypefn
