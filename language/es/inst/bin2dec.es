md5="92ee27b63691d1ef5f247275554d0d5a";rev="6125";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} bin2dec (@var{s})
Retorna n@'umero decimal correspondiente al n@'umero binario almacenado
en la cadena @var{s}. Por ejemplo,

@example
bin2dec ("1110")
@result{} 14
@end example

Si @var{s} es una matriz de cadenas, retorna un vector columna de n@'umeros 
convertidos, uno por row of @var{s}.  Invalid rows evaluate to NaN.
@seealso{dec2hex, base2dec, dec2base, hex2dec, dec2bin}
@end deftypefn
