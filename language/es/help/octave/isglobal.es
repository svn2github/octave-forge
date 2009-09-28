md5="a0f502629f9c9acfde4fc9a73b2e877d";rev="6274";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {} isglobal (@var{name})
Retorna 1 si @var{name} es visible globalmente. En otro caso, retorna 0. 
Por ejemplo, 

@example
@group
global x
isglobal ("x")
     @result{} 1
@end group
@end example
@end deftypefn
