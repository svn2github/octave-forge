md5="eb69f0a6327e967d430781f6af9e24d8";rev="6312";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {[@var{files}, @var{err}, @var{msg}] =} readdir (@var{dir})
Retorna el nombre de los archivos en el directorio @var{dir} como un arreglo 
de celdas de cadenas. Si ocurre un error, retorna un arreglo de celdas vacio 
en @var{files}.

Si la ejecuci@'on es exitosa, @var{err} es 0 y @var{msg} es una cadena vacia. 
En otro caso, @var{err} es dinstinto de cero y @var{msg} contiene un mensaje 
de error dependiente del sistema.
@seealso{dir, glob}
@end deftypefn
