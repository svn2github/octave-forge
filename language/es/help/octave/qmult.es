md5="d9b831c837f53681fdb13849a10db2be";rev="6166";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} qmult (@var{a}, @var{b})
Multiplica dos cuaterniones.

@example
[w, x, y, z] = w*i + x*j + y*k + z
@end example

@noindent
identidades:

@example
i^2 = j^2 = k^2 = -1
ij = k                 jk = i
ki = j                 kj = -i
ji = -k                ik = -j
@end example
@end deftypefn