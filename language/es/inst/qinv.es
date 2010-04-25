md5="f351b7f66c363d0f7fcc76da3c2f04a5";rev="7238";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} qinv (@var{q})
Retorna el inverso de un cuaternion.

@example
q = [w, x, y, z] = w*i + x*j + y*k + z
qmult (q, qinv (q)) = 1 = [0 0 0 1]
@end example
@end deftypefn