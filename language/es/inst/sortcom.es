md5="18749d613b934df5608217e04289b9ed";rev="6433";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {[@var{yy}, @var{idx}] =} sortcom (@var{xx}[, @var{opt}])
Ordena un vector de n@'umeros complejos.

@strong{Entradas}
@table @var
@item xx
Vector de n@'umeros complejos.
@item opt
Opci@'on de ordenamiento:
@table @code
@item "re"
Parte real (predeterminado);
@item "mag"
Magnitud;
@item "im"
Parte imaginaria.
@end table
Si no se selecciona @var{opt} como @code{"im"}, entonces se agrupan 
los complejos conjugados, @math{a - jb} segido por @math{a + jb}.
@end table

@strong{Salidas}
@table @var
@item yy
Valores ordenados
@item idx
Vector de permutaci@'on: @code{yy = xx(idx)}
@end table
@end deftypefn
