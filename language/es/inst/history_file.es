md5="ce5b099e5795d516c03547a8a379164e";rev="7230";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {@var{val} =} history_file ()
@deftypefnx {Función incorporada} {@var{old_val} =} history_file (@var{new_val})
Consulta o establece el valor de la variable interna que especifica el nombre 
del archivo usado para almacenar el historial de comandos. El valor predeterminados 
es @code{"~/.octave_hist"}, pero se puede sobre escribir con la variable interna 
@code{OCTAVE_HISTFILE}.
@seealso{history_size, saving_history, history_timestamp_format_string}
@end deftypefn
