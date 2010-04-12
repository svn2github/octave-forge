md5="f351b7f66c363d0f7fcc76da3c2f04a5";rev="6166";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} qinv (@var{q})
Retorna el inverso de un cuaternion.

@example
q = [w, x, y, z] = w*i + x*j + y*k + z
qmult (q, qinv (q)) = 1 = [0 0 0 1]
@end example
@end deftypefn