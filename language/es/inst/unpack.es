md5="139524fd1eec33f4cfa16e63ba46a86e";rev="7241";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {@var{files} =} unpack (@var{file}, @var{dir})
@deftypefnx {Archivo de función} {@var{files} =} unpack (@var{file}, @var{dir}, @var{filetype})

Descomprime el archivo @var{file} basado en su extensión en el 
directorio @var{dir}. Si @var{file} es un @code{cellstr}, entonces 
todos los archivos son manipulados individualmente. Si no se especifica 
@var{dir}, el valor predeterminado es el directorio actual. La función 
@code{unpack} retorna una lista de los archivos  @var{files} descomprimidos. 
Si un directorio está dentro de la lista de archivos, entonces la variable 
@var{filetype} debe ser especificada también.

La variable @var{files} incluye la ruta completa a los archivos de salida.

@seealso{bzip2,bunzip2,tar,untar,gzip,gunzip,zip,unzip}
@end deftypefn