md5="7b00374118610eef3fff2c9c8237b6a4";rev="6944";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {@var{val} =} octave_core_file_limit ()
@deftypefnx {Funci@'on incorporada} {@var{old_val} =} octave_core_file_limit (@var{new_val})
Consulta o establece la variable interna que especifica la cantidad 
m@'axima de memoria (en kilobytes) del nivel-superior del @'area
de trabajo que Octave intentar@'a salvar al escribir datos en el 
archivo de volcado (el nombre del archivo es especificado por 
@var{octave_core_file_name}). Si el inidcador @var{octave_core_file_options}
especifica un formato binario, entoces @var{octave_core_file_limit} ser@'a
de aproximadamente el tama@~{n}o m@'aximo del archivo. Si se utiliza un 
formato de archivo de texto, el archivo podr@'ia ser mucho mayor que el 
l@'imite. El valor predeterminado es -1 (ilimitada).
@seealso{crash_dumps_octave_core, octave_core_file_name, octave_core_file_options}
@end deftypefn