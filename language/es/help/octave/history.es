md5="fa61c60e58ea0bd2aa427e95d27d030f";rev="7136";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deffn {Comando} history options
Si se invoca sin argumentos, @code{history} muestra una lista de comandos
que se han ejecutado. Las opciones v@'alidas son:

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
Solo muestra las m@'as recientes @var{n} l@'ineas de la historia.

@item -q
No muestra el n@'umero de las l@'ineas de la historia. Esto es @'util para
cortar y pegar los comandos si est@'a utilizando el X Window System.
@end table

Por ejemplo, para mostrar los cinco comandos m@'as recientes que ha escrito
sin mostrar n@'umeros de l@'inea, utilice el comando
@kbd{history -q 5}.
@end deffn