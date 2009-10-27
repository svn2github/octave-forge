md5="290028fde817e1d090c8162f4488bbc9";rev="6405";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {[@var{t}, @var{p}] =} orderfields (@var{s1}, @var{s2})
Retorna una estructura con los campos organizados alfab@'eticamente
o como se especifica en @var{s2} y un vector de permutaci@'on 
correspondiente. 

Dada una estructura, organiza los nombres de los campos de @var{s1} 
alfab@'eticamente. 

Dadas dos estructuras, organiza los nombres de los campos de @var{s1} 
como aparecen en @var{s2}. El segundo argumento puede tambi@'en 
especificar el orden en un vector de permutaci@'on o un arreglo de 
celdas de cadenas.
@seealso{getfield, rmfield, isfield, isstruct, fieldnames, struct}
@end deftypefn
