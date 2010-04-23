md5="d20417b4ec2cc475a02abb5320024dfb";rev="7230";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{v1}, @dots{}] =} getfield (@var{s}, @var{key}, @dots{}) 
Extraw los campos de la estructura. Por ejemplo 

@example
@group
ss(1,2).fd(3).b=5;
getfield (ss, @{1,2@}, "fd", @{3@}, "b")
@result{} ans = 5
@end group
@end example

Nótese que el llamado de la función en el ejemplo anterior es 
equivalente a la expresión 

@example
         i1= @{1,2@}; i2= "fd"; i3= @{3@}; i4= "b";
         ss(i1@{:@}).(i2)(i3@{:@}).(i4)
@end example
@seealso{setfield, rmfield, isfield, isstruct, fieldnames, struct}
@end deftypefn
