md5="58e122ddc8b4c48a5e893bc0b97a935c";rev="7236";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {@var{idx} =} lookup (@var{table}, @var{y})
Los valores de búsqueda en una tabla ordenada. Normalmente se
usa como un preludio a la interpolación.

si la tabla estrictamente creciente y @code{idx = lookup (table, y)},
entonces @code{table(idx(i)) <= y(i) < table(idx(i+1))} para todos
@code{y(i)} dentro de la tabla. Si @code{y(i)} esta antes de la tabla,
entonces @code{idx(i)} es 0. Si @code{y(i)} esta después de la tabla,
entonces @code{idx(i)} es @code{table(n)}.

Si la tabla les estrictamente decresiente, entonces las pruebas son 
revertidas.
No hay garantías para las tablas que no son monótonas o no son
estrictamente monótonas.

Para obtener un valor índice que se encuentra en un intervalo de
la tabla, utilice:

@example
idx = lookup (table(2:length(table)-1), y) + 1
@end example

@noindent
Esta expresión pone los valores antes de la tabla en el primer
intervalo, y después los valores de la tabla en el último
intervalo.
@end deftypefn