md5="3b7591a9c2e07e7121be9ba72d67213b";rev="6166";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {} kbhit ()
Lee la pulsaci@'on de una tecla del teclado. Si se llama con un 
par@'ametro, no espera por otra pulsaci@'on del teclado. Por ejemplo,

@example
x = kbhit ();
@end example

@noindent
guardar@'a en @var{x} el siguiente caracter digitado en el teclado tan pronto 
como es digitado.

@example
x = kbhit (1);
@end example

@noindent
id@'entico al ejemplo anterior, excepto que no espera por otra pulsaci@'on del teclado,
retornando una cadena vacia si la tecla no est@'a disponible.
@end deftypefn
