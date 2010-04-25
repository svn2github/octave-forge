md5="33441071a050259457bffafdb94fdde2";rev="7239";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {} rethrow (@var{err})
Vuelve a mostrar el error definido en @var{err}. El argumento @var{err} es 
una estructura que debe contener los campos 'message' e 'identifier'. 
El argumento @var{err} también puede contener el campo 'stack' que 
suministra la información acerca de la ubicación del error. Típicamente 
se retorna @var{err} a partir de @code{lasterror}.
@seealso{lasterror, lasterr, error}
@end deftypefn
