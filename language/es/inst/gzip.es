md5="4df3c09074bbed52e3fd1dcd93cce194";rev="7230";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {@var{entries} =} gzip (@var{files})
@deftypefnx {Archivo de función} {@var{entries} =} gzip (@var{files}, @var{outdir})
Comprime una lista de archivos y/o directorios especificados en @var{files}. 
Cada archivo se comprime separadamente y se crea un archivo nuevo de 
extensión '.gz'. El archivo original no se toca. Si se define @var{rootdir}, 
se ubica la versión comprimida de los archivos en este directorio.
@seealso{gunzip, zip, tar}
@end deftypefn
