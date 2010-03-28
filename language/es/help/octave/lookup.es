md5="58e122ddc8b4c48a5e893bc0b97a935c";rev="7136";by="Javier Enciso <j4r.e4o@gmail.com> and Edwin Moreno <edwinmoreno1@hotmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de funci@'on} {@var{idx} =} lookup (@var{table}, @var{y})
Los valores de b@'usqueda en una tabla ordenada. Normalmente se
usa como un preludio a la interpolaci@'on.

si la tabla estrictamente creciente y @code{idx = lookup (table, y)},
entonces @code{table(idx(i)) <= y(i) < table(idx(i+1))} para todos
@code{y(i)} dentro de la tabla. Si @code{y(i)} esta antes de la tabla,
entonces @code{idx(i)} es 0. Si @code{y(i)} esta despu@'es de la tabla,
entonces @code{idx(i)} es @code{table(n)}.

Si la tabla les estrictamente decresiente, entonces las pruebas son 
revertidas.
No hay garant@'ias para las tablas que no son mon@'otonas o no son
estrictamente mon@'otonas.

Para obtener un valor @'indice que se encuentra en un intervalo de
la tabla, utilice:

@example
idx = lookup (table(2:length(table)-1), y) + 1
@end example

@noindent
Esta expresi@'on pone los valores antes de la tabla en el primer
intervalo, y despu@'es los valores de la tabla en el @'ultimo
intervalo.
@end deftypefn