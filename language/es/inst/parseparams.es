md5="e5bd9af6975214757084813b73f5e5d7";rev="7238";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {[@var{reg}, @var{prop}] =} parseparams (@var{params})

Retorna las celdas de elementos de @var{param} hasta el primer elemento 
de tipo cadena en @var{reg} y todos los elementos restantes comenzando 
con el primer elemento cadena en @var{prop}. Por ejemplo 

@example
@group
[reg, prop] = parseparams (@{1, 2, "linewidth", 10@})
reg =
@{
  [1,1] = 1
  [1,2] = 2
@}
prop =
@{
  [1,1] = linewidth
  [1,2] = 10
@}
@end group
@end example

La función @code{parseparams} puede ser usada para separar argumentos 
'regular' y argumentos adicionales dados como parejas propiedad valor del 
arreglo de celdas @var{varargin}.

@seealso{varargin}
@end deftypefn
