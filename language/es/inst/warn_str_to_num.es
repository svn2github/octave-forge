md5="58b3482cd21ff10fd81e067013df8427";rev="7241";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@defvr {Variable incorporada} warn_str_to_num
Si el valor de @code{warn_str_to_num} es distinto de cero, muestra una 
advertencia para la coversiones implícitas de cadenas en su ASCII numérico 
equivalente. Por ejemplo, 
@example
@group
"abc" + 0
     @result{} 97 98 99
@end group
@end example
muestra una advertencia si @code{warn_str_to_num} es distinto de cero. 
Valor predeterminado es 0. 
@end defvr
