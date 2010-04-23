md5="509707f87dfc5ec48b1df6827c0cdbef";rev="7230";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} hex2dec (@var{s})
Retorna el entero correspondiente al número hexadecimal almacenado 
en la cadena @var{s}. Por ejemplo, 

@example
hex2dec ("12B")
@result{} 299
hex2dec ("12b")
@result{} 299
@end example

Si @var{s} es una matriz de cadenas, retorna un vector columna de los 
números convertidos, uno por fila de @var{s}. Las filas inválidas 
son evaluadas como NaN.
@seealso{dec2hex, base2dec, dec2base, bin2dec, dec2bin}
@end deftypefn
