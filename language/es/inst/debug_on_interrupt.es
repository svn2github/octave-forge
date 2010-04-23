md5="4dda01351ed9d917b65d1bd24b7b4b15";rev="7226";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {@var{val} =} debug_on_interrupt ()
@deftypefnx {Función incorporada} {@var{old_val} =} debug_on_interrupt (@var{new_val})
Consulta o establece la variable interna que controla si Octave intentará 
entrar en el depurador cuando recibe una se@~{n}al de interrupción (típicamente 
generado con @kbd{C-c}). Si se recibe una segunda se@~{n}al de interrupción 
anstes de alcanzar el modo de depuración, ocurrirá una interrupción normal.
@end deftypefn
