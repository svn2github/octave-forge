md5="3b7591a9c2e07e7121be9ba72d67213b";rev="7231";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {} kbhit ()
Lee la pulsación de una tecla del teclado. Si se llama con un 
parámetro, no espera por otra pulsación del teclado. Por ejemplo,

@example
x = kbhit ();
@end example

@noindent
guardará en @var{x} el siguiente caracter digitado en el teclado tan pronto 
como es digitado.

@example
x = kbhit (1);
@end example

@noindent
idéntico al ejemplo anterior, excepto que no espera por otra pulsación del teclado,
retornando una cadena vacia si la tecla no está disponible.
@end deftypefn
