md5="d81f0450f0cccc172e68e99a06205895";rev="7226";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} dec2base (@var{n}, @var{b}, @var{len})
Retorna una cadena de símbolos en base @var{b} correspondiente al 
entero no negativo @var{n}.

@example
dec2base (123, 3)
@result{} "11120"
@end example

Si @var{n} es un vector, retorna una matriz de cadenas con una fila por valor,
ajustada con ceros iniciales hasta completar la longitud del valor mas largo.

Si @var{b} es una cadena, los caracteres de @var{b} se usan como los 
símbolos para los dígitos de @var{n}.  El espacio (' ') puede ser usado 
como símbolo.

@example
dec2base (123, "aei")
@result{} "eeeia"
@end example

El tercer argumento opcional, @var{len}, especifica el número 
mínimo de dígitos en el resultado.
@seealso{base2dec, dec2bin, bin2dec, hex2dec, dec2hex}
@end deftypefn
