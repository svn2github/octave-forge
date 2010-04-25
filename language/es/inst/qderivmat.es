md5="9269a33e4b5a3af10d6da5d4bc913566";rev="7238";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} qderivmat (omega)
Calcula la derivada de un cuaternion.

Sea Q un cuaternion para transformar un vector de un marco fijo a 
un marco rotativo. Si el marco rotativo está rotando en torno al eje 
[x, y, z] a una tasa angular [wx, wy, wz], la derivada de 
Q está dada por 

@example
Q' = qderivmat (omega) * Q
@end example

Si se usa la convención pasiva (rotación del marco, no del vector), 
entonces 

@example
Q' = -qderivmat (omega) * Q
@end example
@end deftypefn