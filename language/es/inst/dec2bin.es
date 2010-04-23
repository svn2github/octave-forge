md5="9b9977019680b02df74e8b0c4b4a470a";rev="7226";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} dec2bin (@var{n}, @var{len})
Retorna un número binario correspondiente al númeor decimal no negativo 
@var{n}, como una cadena de unos y ceros. Por ejemplo,

@example
dec2bin (14)
@result{} "1110"
@end example

Si @var{n} es un vector, retorna una matriz de cadenas con una fila por valor,
ajustada con ceros iniciales hasta completar la longitud del valor mas largo.

El segundo argumento opcional, @var{len}, especifica el número 
mínimo de dígitos en el resultado.
@seealso{bin2dec, dec2base, base2dec, hex2dec, dec2hex}
@end deftypefn
