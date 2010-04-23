md5="1824c04f631b2934cf9fae993e1737db";rev="7226";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {@var{val} =} debug_on_error ()
@deftypefnx {Función incorporada} {@var{old_val} =} debug_on_error (@var{new_val})
Consulta o establece la variable interna que controla si Octave intentará 
entrar en el depurador cuando se encuentra un error. Esto también inhibirá 
la impresión del mensaje normal de rastreo (únicamente se verá el mensaje 
de error del nivel superior).
@end deftypefn
