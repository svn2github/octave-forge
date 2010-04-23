md5="fa61c60e58ea0bd2aa427e95d27d030f";rev="7230";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deffn {Comando} history options
Si se invoca sin argumentos, @code{history} muestra una lista de comandos
que se han ejecutado. Las opciones válidas son:

@table @code
@item -w @var{file}
Escribir la historia actual en el archivo @var{file}. Si se omite el nombre,
utiliza el archivo de la historia por defecto (normalmente 
@file{~/.octave_hist}).

@item -r @var{file}
Lea el archivo archivo @var{file}, remplazando la lista de historia actual
con su contenido. Si se omite el nombre, utilice el archivo de la 
historia por defecto (normalmente @file{~/.octave_hist}).

@item @var{n}
Solo muestra las más recientes @var{n} líneas de la historia.

@item -q
No muestra el número de las líneas de la historia. Esto es útil para
cortar y pegar los comandos si está utilizando el X Window System.
@end table

Por ejemplo, para mostrar los cinco comandos más recientes que ha escrito
sin mostrar números de línea, utilice el comando
@kbd{history -q 5}.
@end deffn