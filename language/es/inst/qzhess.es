md5="295c5b26dfd25ea3fe84bc5a085d8d69";rev="7136";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {[@var{aa}, @var{bb}, @var{q}, @var{z}] =} qzhess (@var{a}, @var{b})
Calcule la descomposici@'on Hessenberg-triangular de la matriz de l@'apiz
@code{(@var{a}, @var{b})}, regresando
@code{@var{aa} = @var{q} * @var{a} * @var{z}},
@code{@var{bb} = @var{q} * @var{b} * @var{z}}, con @var{q} y @var{z}
ortogonales. Por ejemplo,

@example
@group
[aa, bb, q, z] = qzhess ([1, 2; 3, 4], [5, 6; 7, 8])
@result{} aa = [ -3.02244, -4.41741;  0.92998,  0.69749 ]
@result{} bb = [ -8.60233, -9.99730;  0.00000, -0.23250 ]
@result{}  q = [ -0.58124, -0.81373; -0.81373,  0.58124 ]
@result{}  z = [ 1, 0; 0, 1 ]
@end group
@end example

la descomposici@'on Hessenberg-triangular es el primer paso en 
Moler y el algoritmo de descomposici@'on de Stewart's QZ

Algoritmo tomado de Golub y Van Loan, @cite{Matrix Computations, 2nd
edition}.
@end deftypefn