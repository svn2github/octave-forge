md5="4dda01351ed9d917b65d1bd24b7b4b15";rev="6125";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {@var{val} =} debug_on_interrupt ()
@deftypefnx {Funci@'on incorporada} {@var{old_val} =} debug_on_interrupt (@var{new_val})
Consulta o establece la variable interna que controla si Octave intentar@'a 
entrar en el depurador cuando recibe una se@~{n}al de interrupci@'on (t@'ipicamente 
generado con @kbd{C-c}). Si se recibe una segunda se@~{n}al de interrupci@'on 
anstes de alcanzar el modo de depuraci@'on, ocurrir@'a una interrupci@'on normal.
@end deftypefn
