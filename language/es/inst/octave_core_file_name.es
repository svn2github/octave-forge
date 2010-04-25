md5="92b5264aa756eb8ef91be813a3ba7d35";rev="7238";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {@var{val} =} octave_core_file_name ()
@deftypefnx {Función incorporada} {@var{old_val} =} octave_core_file_name (@var{new_val})
Consulta o establece el valor de la variable interna que especifica el nombre 
del archivo usado para guardar los datos del espacio de trabajo del nivel superior 
si Octave termina en forma inesperada.

El valor predeterminado es @code{"octave-core"}.
@seealso{crash_dumps_octave_core, octave_core_file_name, octave_core_file_options}
@end deftypefn
