md5="22b64ba9c9f852c57d9d0490b7d61fe0";rev="6231";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} dir (@var{directory})
@deftypefnx {Archivo de funci@'on} {[@var{list}] =} dir (@var{directory})
Muestra un listado de los archivos en el directorio @var{directory}. Si 
se solicita un valor de retorno, retorna una estructura con los campos 

@example
@group
name
bytes
date
isdir
statinfo
@end group
@end example

@noindent
donde @code{statinfo} es la estructura retornada por @code{stat}.

Si @var{directory} no es un directorio, retorna la informaci@'on acerca del 
archivo @var{filename}. El directorio @var{directory} puede ser una lista de 
directorios especificados por un nombre o un comod@'in (p.e., * y/o ?).

Observe que para enlaces simb@'olicos, @code{dir} retorna informaci@'on acerca 
del archivo hacia donde apunta el enlace simb@'olico en lugar del enlace mismo.
No obstante, si el enlace apunta hacia un archivo que no existe, @code{dir} 
retorna la informaci@'on acerca del enlace.
@seealso{ls, stat, lstat, readdir, glob, filesep}
@end deftypefn
