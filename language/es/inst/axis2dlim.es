md5="5dcb4b0aa397a56ab64f14fc9da3e211";rev="7223";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Arhivo de función} {} axis2dlim (@var{axdata})
Determina el límite del eje para datos 2-D (vectores columna); 
deja un 10% de margen alrededor de las gráficas.
Inserta margenes de +/- 0.1 si los datos son unidimensionales
(o un único punto).

@strong{Input}
@table @var
@item axdata
Matriz de @var{n} por 2 de datos [@var{x}, @var{y}].
@end table

@strong{Output}
@table @var
@item axvec
Vector de límites de ejes apropiado para el llamado a la función @command{axis}.
@end table
@end deftypefn
