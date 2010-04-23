md5="31ce22784f04cc99a7b5612e08a3d552";rev="7231";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función de mapeo} {} isna (@var{x})
Retorna 1 para los elementos de @var{x} que son valores NA (no aplica) y 0 
en otro caso. Por ejemplo, 

@example
@group
isna ([13, Inf, NA, NaN])
     @result{} [ 0, 0, 1, 0 ]
@end group
@end example
@end deftypefn
