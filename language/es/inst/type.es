md5="5aa61402503f85d1750cc63d988e4e92";rev="7241";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deffn {Comando} type options name @dots{}
Muesta la defininición de cada nombre @var{name} que se refiere a una 
función.

Normalmente también muestra si cada nombre @var{name} es definido por 
el usuario o incorporado; la opción @code{-q} suprime este comportamiento. 

Actualmente, Octave puede mostrar solo las funciones que se pueden compilar 
limpiamente, debido a que usa la representación interna de la función para 
recrearla en un programa el texto.

Los comentarios no se muestran porque el analizador sintáctico de Octave 
actualmente los descarta mientras que convierte el texto de un archivo de 
función en su representación interna. Este problema puede ser solucionado 
en versiones posteriores.
@end deffn
