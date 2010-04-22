md5="5518b961e8e2778ebffcb0a12ae083bf";rev="7224";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Function File} {} base2dec (@var{s}, @var{b})
Convierte la cadena de dígitos @var{s} de base @var{b} en un 
entero.

@example
base2dec ("11120", 3)
@result{} 123
@end example

Si @var{s} es una matriz, returna un vector columna con un valor por
fila de @var{s}. Si una columna contiene símbolos inválidos, entonces el 
correspondiente valor será NaN. Las filas son justificadas de la derecha antes
de convertirse de tal forma que los espacios son ignorados.

Si @var{b} es una cadena, los caracteres de @var{b} son usados como los 
símbolos para los dígitos de @var{s}. El espacio en blanco (' ') no puede ser usado 
como un símbolo.

@example
base2dec ("yyyzx", "xyz")
@result{} 123
@end example
@seealso{dec2base, dec2bin, bin2dec, hex2dec, dec2hex}
@end deftypefn
