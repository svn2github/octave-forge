md5="e0acdaae6506bc36238eba07a7d49261";rev="7230";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {@var{val} =} history_timestamp_format_string ()
@deftypefnx {Función incorporada} {@var{old_val} =} history_timestamp_format_string (@var{new_val})
Consulta o establece el valor de la varible interna que especifica 
la cadena de formato para la línea de comando que se escribe en el 
historial cuando Octave termina su ejecución. El formato de la cadena 
se pasa a @code{strftime}. El valor predeterminado es 

@example
"# Octave VERSION, %a %b %d %H:%M:%S %Y %Z <USER@@HOST>"
@end example
@seealso{strftime, history_file, history_size, saving_history}
@end deftypefn
