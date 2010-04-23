md5="0d0e75ef340fd672b1dd56e7b0a5fb40";rev="7226";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deffn {Comando} diary options
Crea una lista de todos los comandos @emph{y} la salida que producen, 
justo como aparecen en la terminal. Las opciones válidas son:

@table @code
@item on
Inicia la grabación de la sesión en un archivo llamado @file{diary} en 
el directorio actual de trabajo.

@item off
Detiene la grabación de la sesión en el archivo de diario.

@item @var{file}
Graba la sesión en el archivo llamado @var{file}.
@end table

Sin argumentos, @code{diary} intercambia el estado actual del diario.
@end deffn
