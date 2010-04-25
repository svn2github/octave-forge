md5="4f6319e1510e81d4832758c667930cb7";rev="7240";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} str2mat (@var{s_1}, @dots{}, @var{s_n})
Retorna una matriz con las cadenas @var{s_1}, @dots{}, @var{s_n} como 
sus filas. Cada cadena es emparejada con espacios en blanco para formar 
una matriz válida.

Esta función está modelada según @sc{Matlab}.  En Octave, se puede 
crear una matriz de cadenas @code{[@var{s_1}; @dots{}; @var{s_n}]} incluso 
si las cadenas tienes longitudes diferentes.
@end deftypefn
