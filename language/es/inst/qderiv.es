md5="071495ed0419dc50bb08d46e04020aba";rev="6166";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {} qderiv (omega)
Calcula la derivada de un cuaternion.

Sea Q un cuaternion para transformar un vector de un marco fijo a 
un marco rotativo. Si el marco rotativo est@'a rotando en torno al eje 
[x, y, z] a una tasa angular [wx, wy, wz], la derivada de 
Q est@'a dada por 

@example
Q' = qderivmat (omega) * Q
@end example

Si se usa la convenci@'on pasiva (rotaci@'on del marco, no del vector), 
entonces 

@example
Q' = -qderivmat (omega) * Q
@end example
@end deftypefn