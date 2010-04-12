md5="de1cc664220ccf1704ff0c076bf0f864";rev="6893";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {@var{val} =} save_header_format_string ()
@deftypefnx {Funci@'on incorporada} {@var{old_val} =} save_header_format_string (@var{new_val})
Consulta o establece la variable interna que especifica el formato
string usado para las l@'ineas de comentario escrito en al principio
de los archivos de datos text-format almacenados por Octave. el formato
string es pasado por @code{strftime} y debe comenzar con el car@'acter
@samp{#} y adem@'as no contiene caracteres de nueva l@'inea. Si el valor 
de @code{save_header_format_string} es una cadena vacia, el comentario
de cabecera ser@'a omitido del texto de archivo de formato de datos.
El valor por defecto es

@example
"# Created by Octave VERSION, %a %b %d %H:%M:%S %Y %Z <USER@@HOST>"
@end example
@seealso{strftime}
@end deftypefn