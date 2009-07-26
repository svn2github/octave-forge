md5="5dcb4b0aa397a56ab64f14fc9da3e211";rev="5693";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Arhivo de funci@'on} {} axis2dlim (@var{axdata})
Determina el l@'imite del eje para datos 2-D (vectores columna); 
deja un 10% de margen alrededor de las gr@'aficas.
Inserta margenes de +/- 0.1 si los datos son unidimensionales
(o un @'unico punto).

@strong{Input}
@table @var
@item axdata
Matriz de @var{n} por 2 de datos [@var{x}, @var{y}].
@end table

@strong{Output}
@table @var
@item axvec
Vector de l@'imites de ejes apropiado para el llamado a la funci@'on @command{axis}.
@end table
@end deftypefn
