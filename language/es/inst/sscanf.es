md5="c97b1c62c0ab920bcd05b8f510588e1d";rev="7240";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {[@var{val}, @var{count}] =} sscanf (@var{string}, @var{template}, @var{size})
@deftypefnx {Función incorporada} {[@var{v1}, @var{v2}, @dots{}, @var{count}] = } sscanf (@var{string}, @var{template}, "C")
Esta función es similar a @code{fscanf}, excepto que los caracteres 
se toman de la cadena @var{string} en lugar del flujo de entrada. El 
final de la cadena se trata como una condición end-of-file.
@seealso{fscanf, scanf, sprintf}
@end deftypefn
