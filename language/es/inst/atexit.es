md5="7e029052f477865e397935c9776b66a3";rev="7201";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci�n incorporada} {} atexit (@var{fcn})
Registra una funci�n para ser llamada cuando Octave finalice. Por ejemplo,

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
mostrar� un mensaje cuando Octave termine su ejecuci�n.
@end deftypefn
