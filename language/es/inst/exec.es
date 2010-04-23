md5="b97eefb2050be8bb4c681178db047135";rev="7228";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {[@var{err}, @var{msg}] =} exec (@var{file}, @var{args})
Reemplaza el proceso actual con un proceso nuevo. Si se llama @code{exec} antes 
que @code{fork} terminará  el proceso actual de Octave y lo reemplaza 
con el programa llamado @var{file}. Por ejemplo, 

@example
exec ("ls" "-l")
@end example

@noindent
ejecuta @code{ls} y lo retorna al prompt shell.

Si es exitoso, @code{exec} no retorna.  Si @code{exec} retorna, 
@var{err} será diferente de cero, y @var{msg} contendrá un mensaje de 
error dependiente del sistema.
@end deftypefn
