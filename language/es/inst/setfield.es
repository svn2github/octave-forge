md5="b45a6e50195d0a58e9f031d3f49345ea";rev="6408";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {[@var{k1}, @dots{}, @var{v1}] =} setfield (@var{s}, @var{k1}, @var{v1}, @dots{})
Establece el n@'umero de campos en una estructura.

@example
@group
oo(1,1).f0= 1;
oo = setfield(oo,@{1,2@},'fd',@{3@},'b', 6);
oo(1,2).fd(3).b == 6
@result{} ans = 1
@end group
@end example

N@'otese que esta funci@'on se podr@'ia escribir como 

@example
         i1= @{1,2@}; i2= 'fd'; i3= @{3@}; i4= 'b';
         oo( i1@{:@} ).( i2 )( i3@{:@} ).( i4 ) == 6;
@end example
@seealso{getfield, rmfield, isfield, isstruct, fieldnames, struct}
@end deftypefn
