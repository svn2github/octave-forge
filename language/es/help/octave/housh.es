md5="5c119238d84ddd5f77d61bfda692f41c";rev="6893";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {[@var{housv}, @var{beta}, @var{zer}] =} housh (@var{x}, @var{j}, @var{z})
Calcula la reflexi@'on de un vector propietario @var{housv} a reflejar
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
@'indice en vector
@item z
Umbral para el cero (generalmente debe ser el n@'umero 0)
@end table

@noindent
Salidas (Vea Golub y Van Loan))
@table @var
@item beta
Si beta = 0, Entonces no es neces@'ario aplicar una reflexci@'on (Zeta ser@'a 0)
@item housv
vector propietario
@end table
@end deftypefn
