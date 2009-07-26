md5="7df3d41bd4ae9a9aa78e58469795cc90";rev="5715";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {@var{x} =} bitset (@var{a}, @var{n})
@deftypefnx {Archivo de funci@'on} {@var{x} =} bitset (@var{a}, @var{n}, @var{v})
Establece o reinicializa @var{n} bits del entero sin signo @var{a}.
@var{v} = 0 reinicializa y @var{v} = 1 establece los bits.
El estado del bit menos significativo se obtiene con @var{n} = 1.

@example
dec2bin (bitset (10, 1))
@result{} 1011
@end example
@seealso{bitand, bitor, bitxor, bitget, bitcmp, bitshift, bitmax}
@end deftypefn
