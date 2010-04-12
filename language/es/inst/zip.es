md5="27e775baaecb3b4289ca5d6575754c52";rev="6346";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {@var{entries} =} zip (@var{zipfile}, @var{files})
@deftypefnx {Archivo de funci@'on} {@var{entries} =} zip (@var{zipfile}, @var{files}, @var{rootdir})
Comprime la lista de archivos y/o directorios especificados en @var{files} 
en un archivo @var{zipfiles} dentro del mismo directorio. Si se define 
@var{rootdir}, los archivos @var{files} son puestos en una ubicación relativa 
a @var{rootdir} en lugar del directorio actual.
@seealso{unzip,tar}
@end deftypefn
