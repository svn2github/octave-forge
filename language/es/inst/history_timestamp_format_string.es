md5="e0acdaae6506bc36238eba07a7d49261";rev="6420";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {@var{val} =} history_timestamp_format_string ()
@deftypefnx {Funci@'on incorporada} {@var{old_val} =} history_timestamp_format_string (@var{new_val})
Consulta o establece el valor de la varible interna que especifica 
la cadena de formato para la l@'inea de comando que se escribe en el 
historial cuando Octave termina su ejecuci@'on. El formato de la cadena 
se pasa a @code{strftime}. El valor predeterminado es 

@example
"# Octave VERSION, %a %b %d %H:%M:%S %Y %Z <USER@@HOST>"
@end example
@seealso{strftime, history_file, history_size, saving_history}
@end deftypefn
