md5="ae1a34fc5ca51c739c509f2f06e5b86d";rev="7201";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {} argv ()
Retorna los argumentos de la línea de comandos pasados a Octave. Por ejemplo,
si invocó Octave usando el comando

@example
octave --no-line-editing --silent
@end example

@noindent
@code{argv} retornaría una celda del vector de cadena de caracteres 
con los elementos @code{--no-line-editing} y @code{--silent}.

Si escribe una script ejecutable con Octave, @code{argv} retornará la 
lista de argumentos pasados al script. Para un ejemplo de cómo crear 
un script ejecutable con Octave, véase @xref{Executable Octave Programs}.
@end deftypefn
