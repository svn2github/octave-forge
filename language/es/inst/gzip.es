md5="4df3c09074bbed52e3fd1dcd93cce194";rev="6367";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {@var{entries} =} gzip (@var{files})
@deftypefnx {Archivo de funci@'on} {@var{entries} =} gzip (@var{files}, @var{outdir})
Comprime una lista de archivos y/o directorios especificados en @var{files}. 
Cada archivo se comprime separadamente y se crea un archivo nuevo de 
extensi@'on '.gz'. El archivo original no se toca. Si se define @var{rootdir}, 
se ubica la versi@'on comprimida de los archivos en este directorio.
@seealso{gunzip, zip, tar}
@end deftypefn
