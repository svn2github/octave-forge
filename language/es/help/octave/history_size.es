md5="50071fa2454ccadbcbd14bc6ea58d656";rev="6312";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {@var{val} =} history_size ()
@deftypefnx {Funci@'on incorporada} {@var{old_val} =} history_size (@var{new_val})
Consulta o establece el valor de la variable interna que especifica 
cuantas entradas son almacenadas en el archivo de historial. El valor 
predeterminado es @code{1024}, pero se puede sobreescribir mediante la 
variable de entorno @code{OCTAVE_HISTSIZE}.
@seealso{history_file, history_timestamp_format, saving_history}
@end deftypefn
