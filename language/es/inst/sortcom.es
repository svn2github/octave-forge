md5="18749d613b934df5608217e04289b9ed";rev="7239";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{yy}, @var{idx}] =} sortcom (@var{xx}[, @var{opt}])
Ordena un vector de números complejos.

@strong{Entradas}
@table @var
@item xx
Vector de números complejos.
@item opt
Opción de ordenamiento:
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
Vector de permutación: @code{yy = xx(idx)}
@end table
@end deftypefn
