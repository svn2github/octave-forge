md5="33441071a050259457bffafdb94fdde2";rev="6300";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {} rethrow (@var{err})
Vuelve a mostrar el error definido en @var{err}. El argumento @var{err} es 
una estructura que debe contener los campos 'message' e 'identifier'. 
El argumento @var{err} tambi@'en puede contener el campo 'stack' que 
suministra la informaci@'on acerca de la ubicaci@'on del error. T@'ipicamente 
se retorna @var{err} a partir de @code{lasterror}.
@seealso{lasterror, lasterr, error}
@end deftypefn
