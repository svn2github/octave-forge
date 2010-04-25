md5="2add23839ea9916ed92aed43b7218daf";rev="7239";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} savepath (@var{file})
Guardar la actual ruta de búsqueda de la función @var{file}. Si 
se omite @var{file}, se usa @file{~/.octaverc}. Si la ejecución 
es exitosa, @code{savepath} retorna 0.
@seealso{path, addpath, rmpath, genpath, pathdef, pathsep}
@end deftypefn
