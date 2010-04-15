md5="ae1a34fc5ca51c739c509f2f06e5b86d";rev="7201";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci�n incorporada} {} argv ()
Retorna los argumentos de la l�nea de comandos pasados a Octave. Por ejemplo,
si invoc� Octave usando el comando

@example
octave --no-line-editing --silent
@end example

@noindent
@code{argv} retornar�a una celda del vector de cadena de caracteres 
con los elementos @code{--no-line-editing} y @code{--silent}.

Si escribe una script ejecutable con Octave, @code{argv} retornar� la 
lista de argumentos pasados al script. Para un ejemplo de c�mo crear 
un script ejecutable con Octave, v�ase @xref{Executable Octave Programs}.
@end deftypefn
