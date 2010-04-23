md5="4bc112258827d0c6d4f3517048f53729";rev="7226";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} dec2hex (@var{n}, @var{len})
Retorna la cadena hexadecimal correspondiente al entero no negativo 
@var{n}. Por ejemplo,

@example
dec2hex (2748)
@result{} "ABC"
@end example

Si @var{n} es un vector, retorna una matriz de cadenas con una fila por valor,
ajustada con ceros iniciales hasta completar la longitud del valor mas largo.

El segundo argumento opcional, @var{len}, especifica el número 
mínimo de dígitos en el resultado.
@seealso{hex2dec, dec2base, base2dec, bin2dec, dec2bin}
@end deftypefn
