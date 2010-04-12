md5="bc9ef46f34f8764038e062bf18d30fcc";rev="6408";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {@var{val} =} octave_core_file_options ()
@deftypefnx {Funci@'on incorporada} {@var{old_val} =} octave_core_file_options (@var{new_val})
Consulta o establece el valor de la variable interna que especifica las 
opciones usadas para guardar los datos del espacio de trabajo en caso de 
que Octave termine en forma inesperada. El valor de 
@code{octave_core_file_options} deber@'ia seguir el mismo formato que las 
opciones para la funci@'on @code{save} function. El valor predeterminado 
es el formato binario de Octave.
@seealso{crash_dumps_octave_core, octave_core_file_name, octave_core_file_limit}
@end deftypefn
