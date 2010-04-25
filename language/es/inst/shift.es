md5="c574565a1b5a37a725e343f7df707f1d";rev="7239";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} shift (@var{x}, @var{b})
@deftypefnx {Archivo de función} {} shift (@var{x}, @var{b}, @var{dim})
Si @var{x} es un vector, realiza un corrimiento circular de longitud @var{b} 
sobre los elementos de @var{x}.

Si @var{x} es una matriz, realiza lo mismo para cada columna de @var{x}. Si 
se suministrar el argumento opcional @var{dim}, realiza el corrimiento a lo 
largo de esta dimensión.
@end deftypefn
