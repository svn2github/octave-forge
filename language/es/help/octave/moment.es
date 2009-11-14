md5="0edcba907b52d234569dbe7ad917205c";rev="6466";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} moment (@var{x}, @var{p}, @var{opt}, @var{dim})

Si @var{x} es un vector, calcula el @var{p}-@'esio momento de @var{x}.

Si @var{x} es una matriz, retorna ek vector fila con el @var{p}-@'esimo 
momento de cada columna.

Si se especifica el argumento opcional @var{opt}, se puede especificar 
el tipo de momento computado. Si la variable @var{opt} contiene @code{"c"} 
o @code{"a"}, se retornan los momentos central y/o absoluto. Por ejemplo, 

@example
moment (x, 3, "ac")
@end example

@noindent
calcula el tercer momento central absoluto de @var{x}.

Si se suministra el argumento opcional @var{dim}, realiza el c@'alculo a 
lo largo de la dimensi@'on @var{dim}.

@end deftypefn
