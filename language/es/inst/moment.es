md5="0edcba907b52d234569dbe7ad917205c";rev="7236";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} moment (@var{x}, @var{p}, @var{opt}, @var{dim})

Si @var{x} es un vector, calcula el @var{p}-ésio momento de @var{x}.

Si @var{x} es una matriz, retorna ek vector fila con el @var{p}-ésimo 
momento de cada columna.

Si se especifica el argumento opcional @var{opt}, se puede especificar 
el tipo de momento computado. Si la variable @var{opt} contiene @code{"c"} 
o @code{"a"}, se retornan los momentos central y/o absoluto. Por ejemplo, 

@example
moment (x, 3, "ac")
@end example

@noindent
calcula el tercer momento central absoluto de @var{x}.

Si se suministra el argumento opcional @var{dim}, realiza el cálculo a 
lo largo de la dimensión @var{dim}.

@end deftypefn
