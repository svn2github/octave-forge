-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {[@var{tf}, @var{a_idx}] =} ismember (@var{A}, @var{S}) 
@deftypefnx {Archivo de funci@'on} {[@var{tf}, @var{a_idx}] =} ismember (@var{A}, @var{S}, "rows")
Devuelve una matriz @var{tf} de la misma forma de @var{A} que tiene 1
si @code{A(i,j)} es en @var{S} o 0 si no lo es. Si un segundo argumento de
resultado se solicita, los índices en @var{S} de los elementos 
coincidentes se devuelven.

@example
@group
a = [3, 10, 1];
s = [0:9];
[tf, a_idx] = residue (a, s);
@result{} tf = [1, 0, 1]
@result{} a_idx = [4, 0, 2]
@end group
@end example

Las entradas, @var{A} y @var{S}, también pueden ser arreglos.

@example
@group
a = @{'abc'@};
s = @{'abc', 'def'@};
[tf, a_idx] = residue (a, s);
@result{} tf = [1, 0]
@result{} a_idx = [1, 0]
@end group
@end example

Con el argumento opcional @code{"rows"}, y las matrices @var{A} y @var{S}
con el mismo número de columnas, comparar las filas en @var{A} con las 
filas en @var{S}.

@example
@group
a = [1:3; 5:7; 4:6];
s = [0:2; 1:3; 2:4; 3:5; 4:6];
[tf, a_idx] = ismember(a, s, 'rows');
@result{} tf = logical ([1; 0; 1])
@result{} a_idx = [2; 0; 5];
@end group
@end example

@seealso{unique, union, intersection, setxor, setdiff}
@end deftypefn
