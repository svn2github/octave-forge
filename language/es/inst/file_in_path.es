md5="d502f7164279cfb73c3d45a1248ef674";rev="6253";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {} file_in_path (@var{path}, @var{file})
@deftypefnx {Funci@'on incorporada} {} file_in_path (@var{path}, @var{file}, "all")
Retorna el nombre absoluto de @var{file} si se encuentra en @var{path}. El valor 
es @var{path} deber@'ia ser una lista separada por dos puntos de 
directorios en el formato descrito por @code{path}. Si ning@'un archivo se 
encuentra, retorna una matriz vacia. Por ejemplo, 

@example
file_in_path (EXEC_PATH, "sh")
     @result{} "/bin/sh"
@end example

Si el segundo argumento es un arreglo de celdas de cadenas, busca en 
cada directorio de la ruta por elementos del arreglo de celdas y retorna 
el primero que coincide. 

Si se suministra el tercer argumento opcional @code{"all"}, retorna 
un arreglo de celdas con la lista de todos los archivos que tienen el 
mismo nombre en la ruta. Si no se encuentra ning@'un archivo, retorna un 
arreglo de celdas vacio. 
@seealso{file_in_loadpath}
@end deftypefn
