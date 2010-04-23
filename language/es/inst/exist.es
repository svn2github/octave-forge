md5="b81d612610a7711ddbf3e0af273ab62a";rev="7228";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {} exist (@var{name}, @var{type})
Retorna 1 si el nombre @var{name} existe como una variable, 2 si el nombre 
(después de a@~{n}adir @samp{.m}) es un archivo de función dentro del @code{path} 
de Octave, 3 si el nombre es un archivo @samp{.oct} o @samp{.mex}, 5 si el nombre es 
una función incorporada, 7 si es el nombre de un directorio, o 103 si el nombre 
es una función no asociada con un archivo (digitado en la línea de comandos). En 
otro caso, retorna 0.

Esta función también retorna 2 si un archivo regutar llamado @var{name}
existe dentro de la ruta de búsqueda de Octave. Si necesita información 
acerca de otros tipos de archivos, se debería usar alguna combinación de 
las funciones @code{file_in_path} y @code{stat} en reemplazo.

Si se suministra el parámetro opcional @var{type}, verifica solo 
los símbolos del tipo especificado. Los tipos válidos son 

@table @samp
@item "var"
Verifica solo variables.
@item "builtin"
Verifica solo funciones incorporadas.
@item "file"
Verifica solo archivos.
@item "dir"
Verifica solo direcotrios.
@end table
@end deftypefn
