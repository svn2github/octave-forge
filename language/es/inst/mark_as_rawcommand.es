md5="545866546b0aa328a4bd56befb61da12";rev="6466";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {} mark_as_rawcommand (@var{name})

Ingresa el comando @var{name} en la lista de comandos de entrada sin 
procesar y a la lista de funciones de estilo comando. 

Los comandos de entrada sin procesar son como funciones de estilo comando 
normal, pero ellos reciben sus entradas sin procesar (p.e., cadenas que 
todavia contienen comillas y caracteres de escape). Sin embargo, los 
comentarios y los caracteres de continuaci@'os son manejados de forma usual, 
no se puede pasar un una cadena comenzando con un caracter de comentario ('#' o '%') 
a la funci@'on, y el @'ultimo caracter no puede ser un caracter de continuaci@'on 
('\' o '...').

@seealso{unmark_rawcommand, israwcommand, iscommand, mark_as_command}
@end deftypefn
