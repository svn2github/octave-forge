md5="ee130f1a12b7c84009fee4e0370a4cb1";rev="7225";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función cargable} {@var{p} =} ccolamd (@var{s})
@deftypefnx {Función cargable} {@var{p} =} ccolamd (@var{s}, @var{knobs})
@deftypefnx {Función cargable} {@var{p} =} ccolamd (@var{s}, @var{knobs}, @var{cmember})
@deftypefnx {Función cargable} {[@var{p}, @var{stats}] =} ccolamd (@dots{})

Grado mínimo de permutación de columna restringida aproximada. @code{@var{p} =
ccolamd (@var{s})} retorna el vector de grado mínimo de permutación de columna para la matriz dispersa @var{s}. Para una matriz no simétrica @var{s},
@code{@var{s} (:, @var{p})} tiende a tener factores de dispersión LU de @var{s}.
@code{chol (@var{s} (:, @var{p})' * @var{s} (:, @var{p}))} también tiende a ser 
dispersor de @code{chol (@var{s}' * @var{s})}. @code{@var{p} = ccolamd
(@var{s}, 1)} optimiza el ordenamiento para @code{lu (@var{s} (:, @var{p}))}.
El ordenamiento es seguido por una eliminación de columnas en postorden.

@var{knobs} es un vector de entradas opcional de uno a cinco elementos, con
valores predetermiandos @code{[0 10 10 1 0]} si no está presente o vacio.  
Las entadas no presentes se establecen de acuerdo con sus valores 
predeterminados.

@table @code
@item @var{knobs}(1)
si es distinto de cero, el ordenamiento es optimizado para @code{lu (S (:, p))}. 
Será un ordenamiento pobre para @code{chol (@var{s} (:, @var{p})' * @var{s} (:,
@var{p}))}. Esto es lo más importante para proyección de ccolamd.

@item @var{knob}(2)
Si @var{s} es una matriz de m por n, las filas con mas de @code{max (16, 
@var{knobs} (2) * sqrt (n))} entradas son ignoradas.

@item @var{knob}(3)
Columnas con mas de @code{max (16, @var{knobs} (3) * sqrt (min (@var{m},
@var{n})))} entradas son ignoradas y organizadas al final de la salida de 
permutación (subjeta a las restricciones cmember).

@item @var{knob}(4)
Si es distinto de cero, se aplica absorción agresiva.

@item @var{knob}(5)
Si es distinto de cero, se imprimen estadísticas y proyecciones.

@end table

@var{cmember} es un vector óptimo de logitud n.  Define las restricciones
sobre la columna a ordenar. Si @code{@var{cmember} (j) = @var{c}}, la columna
@var{j} está en el conjunto de restricciones @var{c} (@var{c} debe estar en el 
rago de 1 a @var{n}). En la permutación de salida @var{p}, todas las columnas 
en el conjunto 1 aparecen primero, seguidas por todas las columnas en el conjunto 
2, y así sucesivamente. @code{@var{cmember} = ones(1,n)} si no está presente 
o vacío. @code{ccolamd (@var{s}, [], 1 : @var{n})} retorna @code{1 : @var{n}}.

@code{@var{p} = ccolamd (@var{s})} es similar a @code{@var{p} =
colamd (@var{s})}. @var{knobs} y sus valores predeterminados difieren. 
@code{colamd} siempre realiza absorción agresiva, y encuentra un ordenamiento 
apropiado para ambos @code{lu (@var{s} (:, @var{p}))} and @code{chol (@var{S} (:, 
@var{p})' * @var{s} (:, @var{p}))}; no puede optimizar su ordenamiento para 
@code{lu (@var{s} (:, @var{p}))} en el sentido que puede 
@code{ccolamd (@var{s}, 1)}.

@var{stats} es un vector de salida opcional de 20 elementos que suministra datos
acerca del ordenamiento y la validez de la matriz de entrada @var{s}. Las 
estadísticas de ordenamiento están en @code{@var{stats} (1 : 3)}. @code{@var
{stats} (1)} y @code{@var{stats} (2)} son el número de filas densas y vacias y 
columnas ignoradas por CCOLAMD y @code{@var{stats} (3)} es el número de 
recolecciones de basura ejecutadas por la estructura de datos interna usada por  
CCOLAMD (aproximadamente del tama@~{n}o de @code{2.2 * nnz (@var{s}) + 4 * 
@var{m} + 7 * @var{n}} enteros).

@code{@var{stats} (4 : 7)} suministra información si CCOLAMD fue capaz de 
continuar. La matriz es apropiada si @code{@var{stats} (4)} es cero, o 1 si
es inválida. @code{@var{stats} (5)} es el índice de la columna ubicada al 
extremo derecho la cual no está ordena o que contiene entradas duplicatas, o 
cero no existe tal columna. @code{@var{stats} (6)} es el índice de la última 
fila duplicada o fuera de orden en el índice de columnas dado por @code{
@var{stats} (5)}, o cero si no existe tal índice de columna. @code{@var{stats} 
(7)} es el número de índices de fila duplicados o fuera de orden. @code{
@var{stats} (8 : 20)} siempre es cero en la versión actual de CCOLAMD (reservado para uso futuro).

Los autores del código son S. Larimore, T. Davis (Uni. of Florida)
y S. Rajamanickam en colaboración con J. Bilbert y E. Ng. Fianaciados por 
National Science Foundation (DMS-9504974, DMS-9803599, CCR-0203270),
y una subvención de Sandia National Lab. Véase 
@url{http://www.cise.ufl.edu/research/sparse} para ccolamd, csymamd, amd,
colamd, symamd, y otros ordenamientos relacionados.
@seealso{colamd, csymamd}
@end deftypefn
