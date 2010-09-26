-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {@var{s} =} mat2str (@var{x}, @var{n})
@deftypefnx {Archivo de funci@'on} {@var{s} =} mat2str (@dots{}, 'class')
Formato real/complejo de matrices num�ricas como cadenas. Esta funci�n
devuelve valores que son convenientes para el uso de la funci�n @code{eval}.

La precisi�n de los valores est� dada por @var{n}. Si @var{n} es un
escalar entonces ambas partes real e imaginaria de la matriz se imprimen
en la misma precisi�n. De lo contrario @code{@var{n} (1)} define la 
precisi�n de la parte real y @code{@var{n} (2)} define la precisi�n 
de la parte imaginaria. El valor predeterminado de @var{n} is 17.

Si el argumento de 'class' se da, entonces la clase de @var{x} est� 
incluido en la cadena de tal forma que la funci�n eval se traducir�
en la construcci�n de una matriz de la misma clase.

@example
@group
   mat2str( [ -1/3 + i/7; 1/3 - i/7 ], [4 2] )
@result{} '[-0.3333+0.14i;0.3333-0.14i]'
   mat2str( [ -1/3 +i/7; 1/3 -i/7 ], [4 2] )
@result{} '[-0.3333+0i,0+0.14i;0.3333+0i,-0-0.14i]'
   mat2str( int16([1 -1]), 'class')
@result{} 'int16([1,-1])'
@end group
@end example

@seealso{sprintf, int2str}
@end deftypefn
