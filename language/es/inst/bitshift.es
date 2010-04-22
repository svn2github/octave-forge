md5="6baf89dd63014f7b43dc3e9264e7ff13";rev="7224";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función incorporada} {} bitshift (@var{a}, @var{k})
@deftypefnx {Función incorporada} {} bitshift (@var{a}, @var{k}, @var{n})
Retorna un corrimiento de @var{k} bits de @var{n} dígitos del entero
 sin signo @var{a}. 
 
Si @var{k} es positivo, conduce al corrimiento a la izquierda. Si 
@var{k} es negativo, se realiza el corrimiento a la derecha. Si @var{n} 
es omitido, el valor predeterminado es log2(bitmax)+1.

El valor de @var{n} debe estar en el intervalo [1, log2(bitmax)+1], usualmente [1, 33]

@example
bitshift (eye (3), 1)
@result{}
@group
2 0 0
0 2 0
0 0 2
@end group

bitshift (10, [-2, -1, 0, 1, 2])
@result{} 2   5  10  20  40
@c FIXME -- restore this example when third arg is allowed to be an array.
@c 
@c 
@c bitshift ([1, 10], 2, [3,4])
@c @result{} 4  8
@end example
@seealso{bitand, bitor, bitxor, bitset, bitget, bitcmp, bitmax}
@end deftypefn
