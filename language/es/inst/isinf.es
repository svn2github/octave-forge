md5="06738fe9cdeb399005cda5a6ab560e48";rev="6274";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on de mapeo} {} isinf (@var{x})
Retorna 1 para los elementos de @var{x} que son infinito y 0 
en otro caso. Por ejemplo, 

@example
@group
isinf ([13, Inf, NA, NaN])
     @result{} [ 0, 1, 0, 0 ]
@end group
@end example
@end deftypefn
