md5="b81d612610a7711ddbf3e0af273ab62a";rev="6241";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {} exist (@var{name}, @var{type})
Retorna 1 si el nombre @var{name} existe como una variable, 2 si el nombre 
(despu@'es de a@~{n}adir @samp{.m}) es un archivo de funci@'on dentro del @code{path} 
de Octave, 3 si el nombre es un archivo @samp{.oct} o @samp{.mex}, 5 si el nombre es 
una funci@'on incorporada, 7 si es el nombre de un directorio, o 103 si el nombre 
es una funci@'on no asociada con un archivo (digitado en la l@'inea de comandos). En 
otro caso, retorna 0.

Esta funci@'on tambi@'en retorna 2 si un archivo regutar llamado @var{name}
existe dentro de la ruta de b@'usqueda de Octave. Si necesita informaci@'on 
acerca de otros tipos de archivos, se deber@'ia usar alguna combinaci@'on de 
las funciones @code{file_in_path} y @code{stat} en reemplazo.

Si se suministra el par@'ametro opcional @var{type}, verifica solo 
los s@'imbolos del tipo especificado. Los tipos v@'alidos son 

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
