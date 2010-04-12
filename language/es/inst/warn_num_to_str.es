md5="10c049fd81f17029d6753f476016bc83";rev="6346";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@defvr {Variable incorporada} warn_num_to_str
Si el valor de @code{warn_num_to_str} es distinto de cero, se imprime 
una advertencia para la conversiones impl@'icitas de n@'umeros en sus 
caracteres ASCII equivalentes cuando se construyen cadenas usando 
combinaciones de cadenas y n@'umeros en notaci@'on de matrices. Por 
ejemplo, 

@example
@group
[ "f", 111, 111 ]
     @result{} "foo"
@end group
@end example
produce una advertencia si @code{warn_num_to_str} es distinto de cero. 
El valor predeterminado es 1.
@end defvr
