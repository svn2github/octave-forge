-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {} atexit (@var{fcn})
Registra una funci@'on para ser llamada cuando Octave finalice. Por ejemplo,

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
mostrar@'a un mensaje cuando Octave termine su ejecuci@'on.
@end deftypefn
