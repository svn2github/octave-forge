md5="5aa61402503f85d1750cc63d988e4e92";rev="6461";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deffn {Comando} type options name @dots{}
Muesta la defininici@'on de cada nombre @var{name} que se refiere a una 
funci@'on.

Normalmente tambi@'en muestra si cada nombre @var{name} es definido por 
el usuario o incorporado; la opci@'on @code{-q} suprime este comportamiento. 

Actualmente, Octave puede mostrar solo las funciones que se pueden compilar 
limpiamente, debido a que usa la representaci@'on interna de la funci@'on para 
recrearla en un programa el texto.

Los comentarios no se muestran porque el analizador sint@'actico de Octave 
actualmente los descarta mientras que convierte el texto de un archivo de 
funci@'on en su representaci@'on interna. Este problema puede ser solucionado 
en versiones posteriores.
@end deffn
