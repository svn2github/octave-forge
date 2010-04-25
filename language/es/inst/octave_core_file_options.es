md5="bc9ef46f34f8764038e062bf18d30fcc";rev="7238";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {@var{val} =} octave_core_file_options ()
@deftypefnx {Función incorporada} {@var{old_val} =} octave_core_file_options (@var{new_val})
Consulta o establece el valor de la variable interna que especifica las 
opciones usadas para guardar los datos del espacio de trabajo en caso de 
que Octave termine en forma inesperada. El valor de 
@code{octave_core_file_options} debería seguir el mismo formato que las 
opciones para la función @code{save} function. El valor predeterminado 
es el formato binario de Octave.
@seealso{crash_dumps_octave_core, octave_core_file_name, octave_core_file_limit}
@end deftypefn
