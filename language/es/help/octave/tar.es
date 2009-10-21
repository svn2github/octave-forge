md5="f06683dd932c55160f567205fe22ec80";rev="6351";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {@var{entries} =} tar (@var{tarfile}, @var{files}, @var{root})
Empaqueta los archivos @var{files} en un archivo TAR @var{tarfile}. La 
lista de archivos debe ser una cadena o un arreglo de celdas de cadenas.

El argumento opcional @var{root} cambia la ruta relativa de los archivos 
@var{files} del directorio actual.

Si se solicita un argumento de salida, se retorna un arreglo de celdas 
con los nombres de los archivos.
@seealso{untar, gzip, gunzip, zip, unzip}
@end deftypefn
