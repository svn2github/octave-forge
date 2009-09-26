md5="057a15991b25697b35f899811746a4b7";rev="6253";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Funci@'on incorporada} {} feval (@var{name}, @dots{})
Evalua la funci@'on llamada @var{name}. Cualquier argumento despu@'es del primero 
se pasa dentro de la funci@'on. Por ejemplo, 

@example
feval ("acos", -1)
     @result{} 3.1416
@end example

@noindent
llama la funci@'on @code{acos} con el argumento @samp{-1}.

La funci@'on @code{feval} es necesaria para escribir funciones 
que llaman funciones definidas por el usuario, puesto que Octave no permite 
declarar apuntadores a funciones (como es C) o declarar un tipo especial de 
variable que pueda ser usada para contener el nombre de una funci@'on 
(como la funci@'on @code{EXTERNAL} en Fortran). En cambio, se puede referir a funciones 
por el nombre, y use @code{feval} para llamarlas.
@end deftypefn
