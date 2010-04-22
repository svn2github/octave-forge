md5="d5223776b257cd1db4ca849e16f43b74";rev="7225";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Función cargable} {@var{p} =} colamd (@var{s})
@deftypefnx {Función cargable} {@var{p} =} colamd (@var{s}, @var{knobs})
@deftypefnx {Función cargable} {[@var{p}, @var{stats}] =} colamd (@var{s})
@deftypefnx {Función cargable} {[@var{p}, @var{stats}] =} colamd (@var{s}, @var{knobs})

Permutaci'on de mínimo grado de aproximación de columna. @code{@var{p} = colamd
(@var{s})} retorna el vector permutación de mínimo grado de aproximación de columna 
para la matriz dispersa @var{s}. Para una matriz no simétrica @var{s},
@code{@var{s} (:,@var{p})} tiende a tener más factores dispersos LU que @var{s}.
La factorización Cholesky de @code{@var{s} (:,@var{p})' * @var{s}
(:,@var{p})} también tiende a ser más disperso que @code{@var{s}' * @var{s}}.

@var{knobs} es un vector de entrada opcional, de uno a tres elementos.  
Si @var{s} es m por n, las filas con más de @code{max(16,@var{knobs}(1)*sqrt(n))} 
entradas se ignoran. Las columnas con más de @code{max(16,knobs(2)*sqrt(min(m,n)))} 
entradas se eliminan antes del ordenamiento, y se ordenadan después en la 
permutación de salida @var{p}. Solo se remueven las filas o columnas complemente 
densas si @code{@var{knobs} (1)} y @code{@var{knobs} (2)} son < 0, respectivamente.
Si @code{@var{knobs} (3)} es distinto de cero, se imprime @var{stats} y @var{knobs}. 
El valor predetermiando es @code{@var{knobs} = [10 10 0]}. Nótese que
@var{knobs} difiere de las versiones previas de colamd.

@var{stats} es un vector de salida opcional con 20 elementos que suministra datos
acerca del ordenamiento y la validez de la matriz de entrada @var{s}. Las 
estadísticas del ordenamiento estan en @code{@var{stats} (1:3)}. @code{@var{stats} (1)} y
@code{@var{stats} (2)} es el número de filas y columnas densas o vacias 
ignoradas por COLAMD y @code{@var{stats} (3)} es el número de recolecciones de basura 
realizadas en la estructura interna usada por COLAMD
(aproximadamente del tama@~{n}o de @code{2.2 * nnz(@var{s}) + 4 * @var{m} + 7 * @var{n}}
enteros).

Las funciones incorporadas de Octave están destinadas a generar matrices 
dispersas válidas, sin elementos duplicados, con ídices de filas 
ascendentes de los elementos distintos de cero en cada columna, con número 
no negativo de entradas en cada una de las columnas (!), 
y así sucesivamente. Si una matriz no es válida, COLAMD puede o no ser 
capaz de continuar. Si existen entradas duplicadas (un índice de fila 
aparece dos o más veces en la misma columna) o si los índices de de las 
filas en una columna están desordenados, COLAMD puede corregir estos 
errores ignarando las entradas duplicadas y ordena cada columna de su copia 
interna de la matriz @var{s} (la matriz de entrada @var{s} no se modifica). 
Si una matriz no es válida en otras formas, COLAMD no puede continuar, un 
mensaje de error se imprime, ni argumentos de salida (@var{p} o @var{stats}) 
se retornan. COLAMD es asi una simple forma de verificar si una matriz 
dispersa es válida.

@code{@var{stats} (4:7)} suministra información si COLAMD fue capaz de 
continuar. La matriz es válida si @code{@var{stats} (4)} es cero, o 1 si es
inválida. @code{@var{stats} (5)} es el índice de la columna extrema 
derecha que no esta ordenado o contiene entradas duplicadas, o cero si no 
existen tales columnas . 

@code{@var{stats} (6)} es el índice de la última fila duplicada o 
desordenada en el índice de columnas dado por @code{@var{stats} (5)}, o 
cero si no existen tales filas. @code{@var{stats} (7)} es el número de  
indices de filas duplicadas o desordenadas. @code{@var{stats} (8:20)} es 
siempre cero en la versión actual de COLAMD (reservado para futuro uso).

El ordenamiento es seguido por una eliminación de columnas en posorden.

Los autores del código mismo son Stefan I. Larimore y Timothy A.
Davis (davis@@cise.ufl.edu), University of Florida. El algoritmo fue 
desarrollado en colaboración con John Gilbert, Xerox PARC, y Esmond
Ng, Oak Ridge National Laboratory. (Véase
@url{http://www.cise.ufl.edu/research/sparse/colamd})
@seealso{colperm, symamd}
@end deftypefn
