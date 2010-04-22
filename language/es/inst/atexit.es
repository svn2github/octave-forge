md5="7e029052f477865e397935c9776b66a3";rev="7223";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {} atexit (@var{fcn})
Registra una función para ser llamada cuando Octave finalice. Por ejemplo,

@example
@group
function print_fortune ()
  printf ("\n%s\n", system ("fortune"));
  fflush (stdout);
endfunction
atexit ("print_fortune");
@end group
@end example

@noindent
mostrará un mensaje cuando Octave termine su ejecución.
@end deftypefn
