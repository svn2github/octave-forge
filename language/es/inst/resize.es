md5="2eeb44b94c184a5cca912851d4b0fa00";rev="7239";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {} resize (@var{x}, @var{m})
@deftypefnx {Función incorporada} {} resize (@var{x}, @var{m}, @var{n})
Redimensiona destructivamente @var{x}.

@strong{Los valores en @var{x} no se preservan después de aplicar 
@code{reshape}.}

Si solo se suministra @var{m} y es escalar, la dimensión del 
resultado es @var{m} por @var{m}. Si @var{m} es un vector, las 
dimensiones del resultado están dadas por los elementos de @var{m}. 
Si @var{m} y @var{n} son escalares, las dimensiones del resultado son 
@var{m} por @var{n}.
@seealso{reshape}
@end deftypefn
