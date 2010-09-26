-*- texinfo -*-
@deftypefn {Funci@'on cargable} {@var{s} =} urlread(@var{url})
@deftypefnx {Funci@'on cargable} {[@var{s}, @var{success}] =} urlread (@var{url})
@deftypefnx {Funci@'on cargable} {[@var{s}, @var{success}, @var{message}] =} urlread(@var{url})
@deftypefnx {Funci@'on cargable} {[...] =} urlread (@var{url}, @var{method}, @var{param})
Descargar un archivo remoto especificado por su @var{URL} y devolver sus
contenidos en la cadena @var{s}. Por ejemplo,

@example
s = urlread ('ftp://ftp.octave.org/pub/octave/README');
@end example

La variable @var{success} es 1 si la descarga se ha realizado 
correctamente, de lo contrario es 0, en cuyo caso @var{message}
contiene un mensaje de error. Si no hay ningún argumento de salida
especificado y si se produce un error, entonces el error es señalado
por el mecanismo de control de errores de Octave.

Esta función utiliza libcurl. Curl soporta, entre otros, los protocolos
HTTP, FTP y protocolos ARCHIVO. Nombre de usuario y contraseña puede ser
especificado en la URL. Por ejemplo,

@example
s = urlread ('http://username:password@@example.com/file.txt');
@end example

Peticiones GET y POST puede ser especificadas por @var{method} y @var{param}.
El parámetro @var{method} es 'get' o 'post' y @var{param} es un conjunto de
celdas de los parámetros y pares de valores. Por ejemplo,

@example
s = urlread ('http://www.google.com/search', 'get', @{'query', 'octave'@});
@end example
@seealso{urlwrite}
@end deftypefn
