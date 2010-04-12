md5="4c69e732dbbe132bd18f8beadaebf52a";rev="6253";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} fail (@var{code},@var{pattern})
@deftypefnx {Archivo de funci@'on} {} fail (@var{code},'warning',@var{pattern})
Retorna true si @var{code} falla con un mensaje de error que coincide con 
el patr@'on @var{pattern}, en otro caso produce un error. N@'otese que @var{code} 
es una cadena y si @var{code} se ejecuta exitosamente, el error que se produce es:

@example
          expected error but got none  
@end example

Si el c@'odigo falla con un error diferente, el mensaje que se produce es:

@example
          expected <pattern>
          but got <text of actual error>
@end example

Los par@'entesis angulares no son parte de la salida.

Cuando se llama con tres argumentos, el comportamiento es similar a 
@code{fail(@var{code}, @var{pattern})}, pero produce un error si no se presenta 
ninguna advertencia durante la ejecuci@'on del c@'odigo o si el c@'odigo falla.
@end deftypefn
