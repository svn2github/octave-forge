md5="2a7ac6c92fb5875f27e1335f2e11b18f";rev="6300";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {[@var{num}, @var{den}] =} zp2tf (@var{zer}, @var{pol}, @var{k})
Convierte los ceros / polos en una funci@'on de transferencia.

@strong{Entradas}
@table @var
@item zer
@itemx pol
Vectores de polos y ceros (posiblemente complejos) de una funci@'on 
de transferencia. Los valores complejos deben aparecer con sus complejos 
conjudaos.
@item k
Escalr real (coeficiente inicial).
@end table
@end deftypefn
