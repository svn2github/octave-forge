md5="800e127a2f2acc959570a96609f9dd2c";rev="7230";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {@var{val} =} info_file ()
@deftypefnx {Función incorporada} {@var{old_val} =} info_file (@var{new_val})
Consulta o establece el valor de la variable interna que especifica 
el nombre del archivo info de Octave. El valor predetermiando es 
@code{"@var{octave-home}/info/octave.info"}, en donde @var{octave-home} 
es el directorio de instalación de Octave.
@seealso{info_program, doc, help, makeinfo_program}
@end deftypefn
