md5="0f7df3a29a0027ebac56aa928220824f";rev="6253";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {} file_in_loadpath (@var{file})
@deftypefnx {Funci@'on incorporada} {} file_in_loadpath (@var{file}, "all")

Retorna el nombre absoluto de @var{file} si se puede encontrar en 
la lista de directorios especificados en @code{path}. Si no se encuentra 
ning@'un archivo, retorna una matriz vacia. 

Si el primer argumento es un arreglo de celdas de cadenas, busca en cada 
directorio de @code{loadpath} para elementos del arreglo de celdas y retorna 
el primero que coincide. 

Si se suministra el segungo argumento opcional @code{"all"}, retorna 
un arreglo de celdas con la lista de todos los archivos con el mismo 
nombre en la ruta. Si no se encuentran archivos, retorna un arreglo de 
de celdas vacias.
@seealso{file_in_path, path}
@end deftypefn
