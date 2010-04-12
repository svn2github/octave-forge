md5="2c7a2c3f705f7274860a91d2665faf8e";rev="6166";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} qtransv (@var{v}, @var{q})
Transforma el vector 3-D @var{v} mediante el cuaternion unitario @var{q}.
Retorna un vector columna.

@example
vi = (2*real(q)^2 - 1)*vb + 2*imag(q)*(imag(q)'*vb) 
   + 2*real(q)*cross(imag(q),vb)
@end example

@noindent
donde imag(q) es un vector columna de longitud 3.
@end deftypefn
