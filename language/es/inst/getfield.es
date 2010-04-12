md5="d20417b4ec2cc475a02abb5320024dfb";rev="6408";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {[@var{v1}, @dots{}] =} getfield (@var{s}, @var{key}, @dots{}) 
Extraw los campos de la estructura. Por ejemplo 

@example
@group
ss(1,2).fd(3).b=5;
getfield (ss, @{1,2@}, "fd", @{3@}, "b")
@result{} ans = 5
@end group
@end example

N@'otese que el llamado de la funci@'on en el ejemplo anterior es 
equivalente a la expresi@'on 

@example
         i1= @{1,2@}; i2= "fd"; i3= @{3@}; i4= "b";
         ss(i1@{:@}).(i2)(i3@{:@}).(i4)
@end example
@seealso{setfield, rmfield, isfield, isstruct, fieldnames, struct}
@end deftypefn
