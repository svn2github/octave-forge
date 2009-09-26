md5="f1d8a7ad2b6864fbea562aa3b616f2de";rev="6253";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on de mapeo} {} finite (@var{x})
Retorna 1 para los elementos de @var{x} que tiene valores finitos y 0 en 
otro caso. Por ejemplo, 

@example
@group
finite ([13, Inf, NA, NaN])
     @result{} [ 1, 0, 0, 0 ]
@end group
@end example
@end deftypefn
