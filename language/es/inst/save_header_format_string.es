md5="de1cc664220ccf1704ff0c076bf0f864";rev="7239";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {@var{val} =} save_header_format_string ()
@deftypefnx {Función incorporada} {@var{old_val} =} save_header_format_string (@var{new_val})
Consulta o establece la variable interna que especifica el formato
string usado para las líneas de comentario escrito en al principio
de los archivos de datos text-format almacenados por Octave. el formato
string es pasado por @code{strftime} y debe comenzar con el carácter
@samp{#} y además no contiene caracteres de nueva línea. Si el valor 
de @code{save_header_format_string} es una cadena vacia, el comentario
de cabecera será omitido del texto de archivo de formato de datos.
El valor por defecto es

@example
"# Created by Octave VERSION, %a %b %d %H:%M:%S %Y %Z <USER@@HOST>"
@end example
@seealso{strftime}
@end deftypefn