md5="61301fab7ffcc21bed6d4dbfc4bc0a3b";rev="7225";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {@var{val} =} crash_dumps_octave_core ()
@deftypefnx {Función incorporada} {@var{old_val} =} crash_dumps_octave_core (@var{new_val})
Consulta o establece la variable interna que controla si Octave 
intenta guardar todas las variables actuales en el archivo "octave-core" en caso de 
colapsar o recibir una se@~{n}al de interrupción.
@seealso{octave_core_file_limit, octave_core_file_name, octave_core_file_options}
@end deftypefn
