md5="12c83fe7fe399d91666843346d4c8c6a";rev="6301";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {@var{val} =} makeinfo_program ()
@deftypefnx {Funci@'on incorporada} {@var{old_val} =} makeinfo_program (@var{new_val})
Consulta o establece el valor de la variable interna que especifica el 
nombre del programa @code{makeinfo} que ejecuta Octave para darle formato 
al texto contenido dentro de las etiquetas del comando Texinfo. El valor 
inicial es @code{"makeinfo"}.
@seealso{info_file, info_program, doc, help}
@end deftypefn
