md5="290028fde817e1d090c8162f4488bbc9";rev="7238";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{t}, @var{p}] =} orderfields (@var{s1}, @var{s2})
Retorna una estructura con los campos organizados alfabéticamente
o como se especifica en @var{s2} y un vector de permutación 
correspondiente. 

Dada una estructura, organiza los nombres de los campos de @var{s1} 
alfabéticamente. 

Dadas dos estructuras, organiza los nombres de los campos de @var{s1} 
como aparecen en @var{s2}. El segundo argumento puede también 
especificar el orden en un vector de permutación o un arreglo de 
celdas de cadenas.
@seealso{getfield, rmfield, isfield, isstruct, fieldnames, struct}
@end deftypefn
