md5="c97b1c62c0ab920bcd05b8f510588e1d";rev="6351";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {[@var{val}, @var{count}] =} sscanf (@var{string}, @var{template}, @var{size})
@deftypefnx {Funci@'on incorporada} {[@var{v1}, @var{v2}, @dots{}, @var{count}] = } sscanf (@var{string}, @var{template}, "C")
Esta funci@'on es similar a @code{fscanf}, excepto que los caracteres 
se toman de la cadena @var{string} en lugar del flujo de entrada. El 
final de la cadena se trata como una condici@'on end-of-file.
@seealso{fscanf, scanf, sprintf}
@end deftypefn
