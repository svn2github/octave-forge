md5="28136893878334aecce26ee0112a295d";rev="5971";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Funci@'on cargable} {@var{p} =} csymamd (@var{s})
@deftypefnx {Funci@'on cargable} {@var{p} =} csymamd (@var{s}, @var{knobs})
@deftypefnx {Funci@'on cargable} {@var{p} =} csymamd (@var{s}, @var{knobs}, @var{cmember})
@deftypefnx {Funci@'on cargable} {[@var{p}, @var{stats}] =} csymamd (@dots{})

Para una matriz sim@'etrica definida positiva @var{s}, retorna el vector de 
permutaci@'on @var{p} tal que @code{@var{s}(@var{p},@var{p})} tiende a tener un
factor Cholesky m@'as disperso que @var{s}. Algunas veces @code{csymamd} funciona bien 
para matrices sim@'etricas indefinidas tambi@'en. Se asume que la matriz @var{s} es 
sim@'etrica; solamente se referencia la parte triangular inferior.
@var{s} debe ser cuadrada. El ordenamiento es seguido por la eliminaci@'on del 
@'arbol en posorden.

@var{knobs} es vector de entrada de uno a tres elementos, con
valores predeterminados @code{[10 1 0]} si est@'a presente o vacio. 
Los elementos no presentes se establecen con los valores predeterminados.

@table @code
@item @var{knobs}(1)
Si @var{s} es @var{n} por @var{n}, las filas y columnas con m@'as de 
@code{max(16,@var{knobs}(1)*sqrt(n))} elementos se ignoran, y se ordenan 
al final en la permuntaci@'on de salida (sujeta a las restricciones @var{cmember}).

@item @var{knobs}(2)
Si es distinto de cero, se realiza una absorci@'on agresiva.

@item @var{knobs}(3)
Si es distinto de cero, se imprimen las estad@'isticas nodos.

@end table

@var{cmember} es un vector opcional de longitud @var{s}. Define las restricciones 
en el ordenamiento. Si @code{@var{cmember}(j) = @var{s}}, la fila/columna @var{j}
en el conjunto de restricci@'on @var{c} (@var{c} debe estar en el rango 1 a @var{n}). En la 
permutaci@'on de salida @var{p}, filas/columnas en el conjunto 1 aparecen primero, seguidas 
por todas las filas/columna en el conjunto 2, y asi sucesivamente. @code{@var{cmember} = ones(1,n)}
si no esta presente o vacio. @code{csymamd(@var{s},[],1:n)} retorna @code{1:n}.

@code{@var{p} = csymamd(@var{s})} es aproximadamente igual a @code{@var{p} =
symamd(@var{s})}. @var{knobs} y sus valores predeterminados difieren.

@code{@var{stats} (4:7)} suministra informaci@'on si CCOLAMD fue capaz 
de continuar. La matriz es correcta si @code{@var{stats} (4)} es cero, o 1 si
es inv@'alida. @code{@var{stats} (5)} es el @'indice de la columna m@'as a la derecha 
que no est'a ordenada o contiene elemento duplicados, o cero si no existe tal columna.
@code{@var{stats} (6)} es el @'indice de la @'ultima duplicada o no ordenada
en la columna cuyo @'indice est@'a dado por @code{@var{stats} (5)}, o cero si no
existe tal fila. @code{@var{stats} (7)} es el n@'umero de @'indices de fila 
duplicados o no ordenados. @code{@var{stats} (8:20)} es siempre cero en
la versi@'on actual de CCOLAMD (reservado para uso futuro).

Los autores del c@'odifo mismo son S. Larimore, T. Davis (Uni of Florida)
y S. Rajamanickam en colaboraci@'on con J. Bilbert y E. Ng. Financiados por 
National Science Foundation (DMS-9504974, DMS-9803599, CCR-0203270),
y Sandia National Lab.  V@'ease
@url{http://www.cise.ufl.edu/research/sparse} para ccolamd, csymamd, amd,
colamd, symamd, y otros ordenamientos relacionados.
@seealso{symamd, ccolamd}
@end deftypefn
