md5="36f7776ea57902af036d64f46cff5b78";rev="7224";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} bitcmp (@var{a}, @var{k})
Retorna el @var{k}-bit complemento de enteros en @var{a}. Si 
@var{k} es omitido @code{k = log2 (bitmax) + 1} es asumido.

@example
bitcmp(7,4)
@result{} 8
dec2bin(11)
@result{} 1011
dec2bin(bitcmp(11, 6))
@result{} 110100
@end example
@seealso{bitand, bitor, bitxor, bitset, bitget, bitcmp, bitshift, bitmax}
@end deftypefn
