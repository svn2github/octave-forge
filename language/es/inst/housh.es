md5="5c119238d84ddd5f77d61bfda692f41c";rev="7230";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{housv}, @var{beta}, @var{zer}] =} housh (@var{x}, @var{j}, @var{z})
Calcula la reflexión de un vector propietario @var{housv} a reflejar
@var{x} para ser la j-ava columna de indentidad, i.e.,

@example
@group
(I - beta*housv*housv')x =  norm(x)*e(j) if x(1) < 0,
(I - beta*housv*housv')x = -norm(x)*e(j) if x(1) >= 0
@end group
@end example

@noindent
Entradas

@table @var
@item x
vector
@item j
índice en vector
@item z
Umbral para el cero (generalmente debe ser el número 0)
@end table

@noindent
Salidas (Vea Golub y Van Loan))
@table @var
@item beta
Si beta = 0, Entonces no es necesário aplicar una reflexción (Zeta será 0)
@item housv
vector propietario
@end table
@end deftypefn
