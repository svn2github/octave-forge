md5="a5762eac6628015e683da49dd6ab32f8";rev="6287";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on de mapeo} {} rem (@var{x}, @var{y})
Retorna el residuo de @code{@var{x} / @var{y}}, calculado 
mediante la expresi@'on

@example
x - y .* fix (x ./ y)
@end example

Si las dimensiones de los argumentos no coinciden o si alguno es 
un n@'umero complejo, se muestra un mensje de error.
@seealso{mod, round}
@end deftypefn
