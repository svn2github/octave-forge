md5="f988f15053aa227019c0a521bae76c83";rev="6284";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on de mapeo} {} isnan (@var{x})
Retorna 1 para los elementos de @var{x} que son valores NaN y 0 
en otro caso. Los valores NA se consideran como valores NaN. Por 
ejemplo, 

@example
@group
isnan ([13, Inf, NA, NaN])
     @result{} [ 0, 0, 1, 1 ]
@end group
@end example
@end deftypefn
