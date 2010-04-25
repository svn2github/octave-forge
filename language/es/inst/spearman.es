md5="16a94f335b19639d090489fb28011aee";rev="7239";by="Javier Enciso <j4r.e4o@gmail.com>"
-*- texinfo -*-
@deftypefn {Archivo de función} {} spearman (@var{x}, @var{y})
Calcula el coeficiente de correlación de rangos @var{rho} para cada
una de las variables especificadas por los argumentos de entrada.

Para matrices, cada fila es una observación y cada columna una variable;
vectores siempre son las observaciones y pueden ser vectores filas o columnas.

@code{spearman (@var{x})} es equivalente a @code{spearman (@var{x},
@var{x})}.

Para dos vectores de datos @var{x} y @var{y}, Spearman's @var{rho} es
la correlación de los rangos de @var{x} and @var{y}.

Si @var{x} y @var{y} se extraen de la distribución independiente,
@var{rho} tiene media cero y varianza @code{1 / (n - 1)}, y es
asintóticamente una distribución normal.
@end deftypefn
