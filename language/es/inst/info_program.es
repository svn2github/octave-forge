md5="8852bd7a485f76696a80a1a7b63c6315";rev="7230";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {@var{val} =} info_program ()
@deftypefnx {Función incorporada} {@var{old_val} =} info_program (@var{new_val})

Consulta o establece la variable interna que especifica el nombre del
programa de información a ejecutarse. el valor inicial por defecto es
@code{"@var{octave-home}/libexec/octave/@var{version}/exec/@var{arch}/info"}
en el que @var{octave-home} es el directorio donde está instalado todo 
Octave, @var{version} es el número de versión de Octave, y @var{arch}
es el tipo de sistema (por ejemplo, @code{i686-pc-linux-gnu}). El valor 
inicial por defecto puede ser anulado por la variable de entorno 
@code{OCTAVE_INFO_PROGRAM}, o el argumento de línea de comandos
@code{--info-program NAME}.
@seealso{info_file, doc, help, makeinfo_program}
@end deftypefn