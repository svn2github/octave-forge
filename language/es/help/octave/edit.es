md5="4a38838282ee2c119eaa1e136288e608";rev="6241";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Comando} edit @var{name}
@deftypefnx {Comando} edit @var{field} @var{value}
@deftypefnx {Comando} @var{value} = edit get @var{field}
Edita la funci@'on llamada, o cambia la configuraci@'on del editor.

Si se llama @code{edit} con el nombre de un archivo o funci@'on como 
argumento, abre el archivo o funci@'on en un editor de texto.

@itemize @bullet
@item
Si la funci@'on @var{name} est@'a disponible en un archivo dentro entorno y 
el archivo es modificable, el archivo se edita en ubicaci@'on actual. Si es 
una funci@'on del sistema, el archivo se copia en el directorio @code{HOME} 
(v@'ease a continuaci@'on) se edita.

@item
Si @var{name} es el nombre de una funci@'on definida en el int@'erprete pero  
no en un archivo m, se crea un archivo m en @code{HOME} con la funci@'on 
actual.

@item
Si se espedifica @code{name.cc}, se busca @code{name.cc} en el entorno 
de trabajo y se modifica, en otro caso, se crea un nuevo archivo 
@file{.cc} en @code{HOME}. Si @var{name} es una funci@'on definida en un 
archivo m o en el int@'erprete, se inserta el texto de la funci@'on dentro 
del archivo .cc como un comentario.

@item
Si @var{name.ext} est@'a dentro del entorno de trabajo, se edita. En otro 
caso, el editor crea y abre el archivo @file{HOME/name.ext}. Si  
@file{name.ext} es no modificable, se copia en el directorio 
@code{HOME} antes de ser editado.

@strong{ADVERTENCIA!} Es probable que deba eliminar el contenido de 
@var{name} antes de que la nueva definici@'on est@'e disponible. Si se edita 
un archivo .cc, se debe ejecutar el comando @code{mkoctfile @file{name.cc}} 
antes de que la definici@'on est@'e disponible.
@end itemize

Si se llama @code{edit} con la variables @var{field} y @var{value}, 
el valor del campo de control @var{field} es @var{value}. Si se solicita 
un argumento de salida y el primer argumento es @code{get}, @code{edit} 
retorna el valor del campo de control @var{field}.

Se usan los siguientes campos:

@table @samp
@item editor
Este es el nombre del editor usado para modificar los funciones. En forma 
predetermina, Octave usa la funci@'on incorporada @code{EDITOR}, la cual 
toma su valor desde @code{getenv("EDITOR")} y es @code{emacs}. Use @code{%s} 
en lugar del nombre de la funci@'on. Por ejemplo,
@table @samp
@item [EDITOR, " %s"]
Use el editor predefinido en Octave para @code{bug_report}.
@item "xedit %s &"           
Muestra un editor sencilla basado en X11 en una ventana separada
@item "gnudoit -q \"(find-file \\\"%s\\\")\""   
Lo envia al Emacs actual; debe tener @code{(gnuserv-start)} en @file{.emacs}.
@end table

En cygwin, se debe convertir la ruta de cygwin en una ruta tipo windows
si se est@'a usando un editor nativo de Windows. Por ejemplo 
@example
'"C:/Program Files/Good Editor/Editor.exe" "$(cygpath -wa %s)"'
@end example

@item home
Ubicaci@'on de los archivos m locales del usuario. Aseg@'usre de estar 
en la direcotrio del usuario actual. El valor predetermiando es 
@file{~/octave}.

@item author
Nombre que se pondr@'a despu@'es del campo "## Author:" de la funciones 
nuevas. El valor predeterminado es tomado del campo @code{gecos} de la base 
de datos de contrase@~{n}as.

@item email
Direcci@'on de e-mail que se pondr@'a depu@'es del nombre en el campo autor. 
El valor predeterminado es tomado de @code{<$LOGNAME@@$HOSTNAME>}, y si no 
est@'a definido @code{$HOSTNAME}, usa el comando @code{uname -n}. 
Probalemente sea necesario sobreescribir esta funci@'on. Aseg@'usere de usar 
el formato @code{<user@@host>}.

@item license
@table @samp
@item gpl
GNU General Public License (predeterminado).
@item bsd
Licencia estilo BSD sin anuncios de publicidad.
@item pd
Public domain.
@item "text"
Derechos de autor y licencia definidos por el usuario.
@end table

@item mode
Determina si el editor deber@'ia iniciar en modo as@'incrono o modo 
s@'incrono. Use "async" para iniciar el editor en modo as@'incrono. El 
valor predeterminado es "sync" (v@'ease tambi@'en "system").

A menos que se especifique @samp{pd}, el comando @code{edit} agrega la 
sentencia de derechos de autor "Copyright (C) yyyy Function Author".
@end table
@end deftypefn
