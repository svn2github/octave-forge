md5="ab49b466361b1c461f9a1131b8bf718c";rev="7231";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {} ipermute (@var{a}, @var{iperm})
Retorna la inversa de la función @code{permute}. La expresión 

@example
ipermute (permute (a, perm), perm)
@end example
retorna el arreglo original @var{a}.
@seealso{permute}
@end deftypefn
