md5="ee130f1a12b7c84009fee4e0370a4cb1";rev="5851";by="Javier Enciso <encisomo@in.tum.de>"
-*- texinfo -*-
@deftypefn {Funci@'on cargable} {@var{p} =} ccolamd (@var{s})
@deftypefnx {Funci@'on cargable} {@var{p} =} ccolamd (@var{s}, @var{knobs})
@deftypefnx {Funci@'on cargable} {@var{p} =} ccolamd (@var{s}, @var{knobs}, @var{cmember})
@deftypefnx {Funci@'on cargable} {[@var{p}, @var{stats}] =} ccolamd (@dots{})

Grado m@'inimo de permutaci@'on de columna restringida aproximada. @code{@var{p} =
ccolamd (@var{s})} retorna el vector de grado m@'inimo de permutaci@'on de columna para la matriz dispersa @var{s}. Para una matriz no sim@'etrica @var{s},
@code{@var{s} (:, @var{p})} tiende a tener factores de dispersi@'on LU de @var{s}.
@code{chol (@var{s} (:, @var{p})' * @var{s} (:, @var{p}))} tambi@'en tiende a ser 
dispersor de @code{chol (@var{s}' * @var{s})}. @code{@var{p} = ccolamd
(@var{s}, 1)} optimiza el ordenamiento para @code{lu (@var{s} (:, @var{p}))}.
El ordenamiento es seguido por una eliminaci@'on de columnas en postorden.

@var{knobs} es un vector de entradas opcional de uno a cinco elementos, con
valores predetermiandos @code{[0 10 10 1 0]} si no est@'a presente o vacio.  
Las entadas no presentes se establecen de acuerdo con sus valores 
predeterminados.

@table @code
@item @var{knobs}(1)
si es distinto de cero, el ordenamiento es optimizado para @code{lu (S (:, p))}. 
Ser@'a un ordenamiento pobre para @code{chol (@var{s} (:, @var{p})' * @var{s} (:,
@var{p}))}. Esto es lo m@'as importante para proyecci@'on de ccolamd.

@item @var{knob}(2)
Si @var{s} es una matriz de m por n, las filas con mas de @code{max (16, 
@var{knobs} (2) * sqrt (n))} entradas son ignoradas.

@item @var{knob}(3)
Columnas con mas de @code{max (16, @var{knobs} (3) * sqrt (min (@var{m},
@var{n})))} entradas son ignoradas y organizadas al final de la salida de 
permutaci@'on (subjeta a las restricciones cmember).

@item @var{knob}(4)
Si es distinto de cero, se aplica absorci@'on agresiva.

@item @var{knob}(5)
Si es distinto de cero, se imprimen estad@'isticas y proyecciones.

@end table

@var{cmember} es un vector @'optimo de logitud n.  Define las restricciones
sobre la columna a ordenar. Si @code{@var{cmember} (j) = @var{c}}, la columna
@var{j} est@'a en el conjunto de restricciones @var{c} (@var{c} debe estar en el 
rago de 1 a @var{n}). En la permutaci@'on de salida @var{p}, todas las columnas 
en el conjunto 1 aparecen primero, seguidas por todas las columnas en el conjunto 
2, y as@'i sucesivamente. @code{@var{cmember} = ones(1,n)} si no est@'a presente 
o vac@'io. @code{ccolamd (@var{s}, [], 1 : @var{n})} retorna @code{1 : @var{n}}.

@code{@var{p} = ccolamd (@var{s})} es similar a @code{@var{p} =
colamd (@var{s})}. @var{knobs} y sus valores predeterminados difieren. 
@code{colamd} siempre realiza absorci@'on agresiva, y encuentra un ordenamiento 
apropiado para ambos @code{lu (@var{s} (:, @var{p}))} and @code{chol (@var{S} (:, 
@var{p})' * @var{s} (:, @var{p}))}; no puede optimizar su ordenamiento para 
@code{lu (@var{s} (:, @var{p}))} en el sentido que puede 
@code{ccolamd (@var{s}, 1)}.

@var{stats} es un vector de salida opcional de 20 elementos que suministra datos
acerca del ordenamiento y la validez de la matriz de entrada @var{s}. Las 
estad@'isticas de ordenamiento est@'an en @code{@var{stats} (1 : 3)}. @code{@var
{stats} (1)} y @code{@var{stats} (2)} son el n@'umero de filas densas y vacias y 
columnas ignoradas por CCOLAMD y @code{@var{stats} (3)} es el n@'umero de 
recolecciones de basura ejecutadas por la estructura de datos interna usada por  
CCOLAMD (aproximadamente del tama@~{n}o de @code{2.2 * nnz (@var{s}) + 4 * 
@var{m} + 7 * @var{n}} enteros).

@code{@var{stats} (4 : 7)} suministra informaci@'on si CCOLAMD fue capaz de 
continuar. La matriz es apropiada si @code{@var{stats} (4)} es cero, o 1 si
es inv@'alida. @code{@var{stats} (5)} es el @'indice de la columna ubicada al 
extremo derecho la cual no est@'a ordena o que contiene entradas duplicatas, o 
cero no existe tal columna. @code{@var{stats} (6)} es el @'indice de la @'ultima 
fila duplicada o fuera de orden en el @'indice de columnas dado por @code{
@var{stats} (5)}, o cero si no existe tal @'indice de columna. @code{@var{stats} 
(7)} es el n@'umero de @'indices de fila duplicados o fuera de orden. @code{
@var{stats} (8 : 20)} siempre es cero en la versi@'on actual de CCOLAMD (reservado para uso futuro).

Los autores del c@'odigo son S. Larimore, T. Davis (Uni. of Florida)
y S. Rajamanickam en colaboraci@'on con J. Bilbert y E. Ng. Fianaciados por 
National Science Foundation (DMS-9504974, DMS-9803599, CCR-0203270),
y una subvenci@'on de Sandia National Lab. V@'ease 
@url{http://www.cise.ufl.edu/research/sparse} para ccolamd, csymamd, amd,
colamd, symamd, y otros ordenamientos relacionados.
@seealso{colamd, csymamd}
@end deftypefn
