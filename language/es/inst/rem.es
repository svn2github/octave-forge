md5="a5762eac6628015e683da49dd6ab32f8";rev="7239";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función de mapeo} {} rem (@var{x}, @var{y})
Retorna el residuo de @code{@var{x} / @var{y}}, calculado 
mediante la expresión

@example
x - y .* fix (x ./ y)
@end example

Si las dimensiones de los argumentos no coinciden o si alguno es 
un número complejo, se muestra un mensje de error.
@seealso{mod, round}
@end deftypefn
